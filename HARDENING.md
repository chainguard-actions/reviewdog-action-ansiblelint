<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-ansiblelint/v1.18.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-ansiblelint/v1.18.0** was hardened automatically. 3 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes remote content directly to a shell interpreter. The line `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- ...` downloads and immediately executes a remote script without first saving it to disk for inspection. Even though the URL contains a commit SHA, this pattern is still flagged as unsafe-shell because the content is piped directly to `sh`.

Locations:

- `script.sh:9`

### script-injection (severity: high)

Rule (b) violation: Unquoted shell variable expansions of workflow-controllable (untrusted) env vars in script.sh. (1) Line 18: `ansible-lint -p ${INPUT_ANSIBLELINT_FLAGS}` — INPUT_ANSIBLELINT_FLAGS is sourced from `inputs.ansiblelint_flags` and is expanded without double-quotes, allowing an attacker to inject shell metacharacters (`;`, `|`, `&`, `$(...)`, etc.). (2) Line 25: `${INPUT_REVIEWDOG_FLAGS}` — INPUT_REVIEWDOG_FLAGS is sourced from `inputs.reviewdog_flags` and is also expanded without double-quotes at the end of the reviewdog invocation, enabling the same class of injection.

Locations:

- `script.sh:18`
- `script.sh:25`

### missing-permissions (severity: medium)

None of the three workflow files under .github/workflows/ declare a top-level `permissions:` key, and no job within any of these files declares a job-level `permissions:` key either. Without explicit permissions, workflows run with the default (potentially broad) token permissions. All three files are affected: depup.yml, release.yml, and reviewdog.yml.

Locations:

- `.github/workflows/depup.yml:1`
- `.github/workflows/release.yml:1`
- `.github/workflows/reviewdog.yml:1`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell, script-injection, missing-permissions

**Notes:**

Fixed three security findings in hardened/action: (1) unsafe-shell: Replaced `curl | sh` pipe pattern in script.sh with a two-step approach — download install script to a temp file with `curl -sfL -o`, then execute it with `sh`, then remove it. (2) script-injection: Added double-quotes around `${INPUT_ANSIBLELINT_FLAGS}` (line 18) and `${INPUT_REVIEWDOG_FLAGS}` (line 25) in script.sh to prevent shell metacharacter injection. (3) missing-permissions: Added top-level `permissions:` blocks to all three workflow files — depup.yml gets `contents: write` + `pull-requests: write`; release.yml gets `contents: write` + `pull-requests: write`; reviewdog.yml gets `contents: read` + `checks: write` + `pull-requests: write`.

