<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-ansiblelint/v1.20.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-ansiblelint/v1.20.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes a remote install script directly to a shell interpreter via `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- ...`. Even though the URL is pinned to a specific commit SHA in the path, the content is still piped directly to `sh` without being downloaded and inspected first. The script should be downloaded to a temporary file, verified, and then executed separately.

Locations:

- `script.sh:9`

### script-injection (severity: high)

Rule (b) violation: Two unquoted shell variable expansions of workflow-controllable env vars allow shell metacharacter injection. (1) Line 18: `ansible-lint -p ${INPUT_ANSIBLELINT_FLAGS}` — `INPUT_ANSIBLELINT_FLAGS` is sourced from `inputs.ansiblelint_flags` and expanded without double-quotes, so an attacker-controlled value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) will be interpreted by the shell. (2) Line 25: `${INPUT_REVIEWDOG_FLAGS}` — `INPUT_REVIEWDOG_FLAGS` is sourced from `inputs.reviewdog_flags` and is also unquoted, enabling the same injection. Both should be double-quoted: `"${INPUT_ANSIBLELINT_FLAGS}"` and `"${INPUT_REVIEWDOG_FLAGS}"` (or use the guarded form `${VAR:+"$VAR"}` if the argument must be omitted when empty).

Locations:

- `script.sh:18`
- `script.sh:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed script.sh: (1) unsafe-shell: replaced `curl ... | sh -s -- -b ...` with downloading the install script to a mktemp file then executing `sh "$INSTALL_SCRIPT" -b ...` separately (dropped '--' which was the shell's option terminator, not the script's). (2) script-injection: INPUT_ANSIBLELINT_FLAGS and INPUT_REVIEWDOG_FLAGS are list-style inputs; replaced bare unquoted expansions with xargs-based NUL-delimited tokenization into bash arrays (guarded with `if [ -n ... ]`), then expanded as `"${array[@]}"` to preserve argument boundaries and prevent shell metacharacter injection.

