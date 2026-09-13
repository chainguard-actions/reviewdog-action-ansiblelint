#!/bin/bash

cd "${GITHUB_WORKSPACE}/${INPUT_WORKING_DIRECTORY}" || exit

TEMP_PATH="$(mktemp -d)"
PATH="${TEMP_PATH}:$PATH"

echo '::group::🐶 Installing reviewdog ... https://github.com/reviewdog/reviewdog'
INSTALL_SCRIPT="$(mktemp)"
curl -sfL https://raw.githubusercontent.com/reviewdog/reviewdog/fd59714416d6d9a1c0692d872e38e7f8448df4fc/install.sh -o "$INSTALL_SCRIPT"
sh "$INSTALL_SCRIPT" -b "${TEMP_PATH}" "${REVIEWDOG_VERSION}" 2>&1
echo '::endgroup::'

echo '::group:: Installing ansible-lint ... https://github.com/ansible/ansible-lint'
pip3 install --no-cache-dir ansible-lint=="${INPUT_ANSIBLELINT_VERSION}"
echo '::endgroup::'

export REVIEWDOG_GITHUB_API_TOKEN="${INPUT_GITHUB_TOKEN}"

echo '::group:: Running ansible-lint with reviewdog 🐶 ...'
ansiblelint_flags=()
if [ -n "$INPUT_ANSIBLELINT_FLAGS" ]; then
  while IFS= read -r -d '' t; do ansiblelint_flags+=("$t"); done \
    < <(printf '%s' "$INPUT_ANSIBLELINT_FLAGS" | xargs printf '%s\0')
fi

reviewdog_flags=()
if [ -n "$INPUT_REVIEWDOG_FLAGS" ]; then
  while IFS= read -r -d '' t; do reviewdog_flags+=("$t"); done \
    < <(printf '%s' "$INPUT_REVIEWDOG_FLAGS" | xargs printf '%s\0')
fi

ansible-lint -p "${ansiblelint_flags[@]}" \
  | reviewdog -efm="%f:%l: %m" \
      -name="ansible-lint" \
      -reporter="${INPUT_REPORTER:-github-pr-check}" \
      -level="${INPUT_LEVEL}" \
      -filter-mode="${INPUT_FILTER_MODE}" \
      -fail-level="${INPUT_FAIL_LEVEL}" \
      -fail-on-error="${INPUT_FAIL_ON_ERROR}" \
      "${reviewdog_flags[@]}"
exit_code=$?
echo '::endgroup::'

exit $exit_code
