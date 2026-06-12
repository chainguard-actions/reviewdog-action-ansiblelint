<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-ansiblelint/v1.17.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **reviewdog--action-ansiblelint/v1.17.0** was hardened automatically. 2 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes a remote install script directly to `sh` via curl without first downloading and verifying it. The pattern `curl -sfL https://raw.githubusercontent.com/.../install.sh | sh -s -- ...` executes whatever content is served at that URL in the runner shell. Even though the URL is pinned to a commit SHA in the path, the content is still executed without any integrity check before running.

Locations:

- `script.sh:9`

### script-injection (severity: high)

sub-rule (b): Two unquoted shell variable expansions of workflow-controllable inputs in script.sh allow shell metacharacter injection. (1) Line 18: `ansible-lint -p ${INPUT_ANSIBLELINT_FLAGS}` — INPUT_ANSIBLELINT_FLAGS is sourced from inputs.ansiblelint_flags and is unquoted, so an attacker-controlled value containing spaces, semicolons, pipes, or other shell metacharacters will be word-split and interpreted by the shell. (2) Line 25: `${INPUT_REVIEWDOG_FLAGS}` — similarly unquoted at the end of the reviewdog invocation, sourced from inputs.reviewdog_flags. Both should be double-quoted: `"${INPUT_ANSIBLELINT_FLAGS}"` and `"${INPUT_REVIEWDOG_FLAGS}"`.

Locations:

- `script.sh:18`
- `script.sh:25`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection

**Notes:**

Fixed script.sh: (1) Replaced the unsafe curl-pipe-to-sh pattern with a two-step download-then-execute approach — the install script is now saved to a temp file with `curl -sfL -o "${TEMP_PATH}/install.sh" ...` and then executed with `sh "${TEMP_PATH}/install.sh" ...`. (2) Double-quoted both unquoted variable expansions: `${INPUT_ANSIBLELINT_FLAGS}` on line 18 and `${INPUT_REVIEWDOG_FLAGS}` on line 25 to prevent shell word-splitting and metacharacter injection.

