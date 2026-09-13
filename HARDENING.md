<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-ansiblelint/v1.19.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-ansiblelint/v1.19.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes a remote install script directly to `sh` via curl: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1`. Even though the URL is pinned to a commit SHA, piping remote content directly to a shell interpreter is a dangerous pattern — the script should be downloaded to a file first, verified, and then executed separately.

Locations:

- `script.sh:9`

### script-injection (severity: high)

Rule (b) violation: Two unquoted shell variable expansions of workflow-controllable inputs in script.sh allow shell metacharacter injection. (1) Line 19: `ansible-lint -p ${INPUT_ANSIBLELINT_FLAGS}` — INPUT_ANSIBLELINT_FLAGS is sourced from `inputs.ansiblelint_flags` (set in action.yml env: block) and is unquoted, allowing an attacker to inject shell metacharacters (`;`, `|`, `&`, etc.). (2) Line 27: `${INPUT_REVIEWDOG_FLAGS}` — INPUT_REVIEWDOG_FLAGS is sourced from `inputs.reviewdog_flags` and is also unquoted. Both variables must be double-quoted: `"${INPUT_ANSIBLELINT_FLAGS}"` and `"${INPUT_REVIEWDOG_FLAGS}"`.

Locations:

- `script.sh:19`
- `script.sh:27`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed script.sh: (1) unsafe-shell: Replaced `curl ... | sh -s -- -b ...` with download-to-tempfile then execute pattern, dropping the `--` shell option terminator as required. (2) script-injection: Tokenized the list-style inputs INPUT_ANSIBLELINT_FLAGS and INPUT_REVIEWDOG_FLAGS into bash arrays using the xargs/NUL-delimited read loop pattern with proper `if [ -n "$VAR" ]` guards, then expanded them as `"${array[@]}"` to preserve argument boundaries and prevent shell metacharacter injection.

