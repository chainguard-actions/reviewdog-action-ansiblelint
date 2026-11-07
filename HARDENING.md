<!-- markdownlint-disable -->

# Hardening Report: reviewdog--action-ansiblelint/v1.21.0

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **reviewdog--action-ansiblelint/v1.21.0** was hardened automatically. 1 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### unsafe-shell (severity: high)

script.sh pipes a remote script straight into a shell: `curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh | sh -s -- -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}"`. The URL is pinned to a commit, but the content still runs without being saved first or checked. Fix: download it to a file, check its checksum, then run it as a separate step.

Locations:

- `script.sh:9`

## Iteration Notes

### Iteration 1

**Fixes applied:** unsafe-shell

**Notes:**

script.sh now downloads the commit-pinned reviewdog install.sh to a temp file. If the download fails or the file is empty, the script stops with an error. Otherwise it runs the file with 'sh "$file" -b "$TEMP_PATH" "$REVIEWDOG_VERSION"'. The '-s --' from the pipe form was dropped so the installer still gets its arguments starting at $1. No checksum was added because I had no way to get the file's hash safely. The installer URL is pinned to a commit SHA, so its content can't change.

