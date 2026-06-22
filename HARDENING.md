<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-ansiblelint/v1.18.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-ansiblelint/v1.18.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes a remote install script directly to a shell interpreter: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b ...`. Even though the URL is pinned to a specific commit SHA, piping remote content directly to `sh` is an unsafe pattern — the script should be downloaded to a file first, verified, and then executed separately.

Locations:

- `script.sh:9`

### script-injection (severity: high)

Sub-rule (b): Unquoted shell variable expansions of user-controlled inputs in script.sh. (1) Line 18: `ansible-lint -p ${INPUT_ANSIBLELINT_FLAGS}` — INPUT_ANSIBLELINT_FLAGS is sourced from `inputs.ansiblelint_flags` and is unquoted, allowing an attacker to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.) via the action input. (2) Line 25: `${INPUT_REVIEWDOG_FLAGS}` — INPUT_REVIEWDOG_FLAGS is sourced from `inputs.reviewdog_flags` and is also unquoted, enabling the same class of injection. Both variables should be double-quoted: `"${INPUT_ANSIBLELINT_FLAGS}"` and `"${INPUT_REVIEWDOG_FLAGS}"`.

Locations:

- `script.sh:18`
- `script.sh:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed script.sh: (1) Replaced `curl ... | sh -s` pipe with a two-step approach — download install.sh to ${TEMP_PATH}/install.sh first, then execute it with `sh` separately (unsafe-shell fix). (2) Double-quoted `${INPUT_ANSIBLELINT_FLAGS}` on line 18 and `${INPUT_REVIEWDOG_FLAGS}` on line 25 to prevent shell metacharacter injection from user-controlled inputs (script-injection fix).

