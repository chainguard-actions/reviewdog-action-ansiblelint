#!/bin/sh
# Fake curl: serves the fake reviewdog install script, honoring both
# "curl URL | sh" (stdout) and "curl -o FILE URL" (write to file) forms.
out=""
prev=""
for arg in "$@"; do
  case "$prev" in
    -o|--output) out="$arg" ;;
  esac
  prev="$arg"
done
case "$*" in
  *reviewdog*)
    PAYLOAD="${FAKE_REVIEWDOG_INSTALL_SCRIPT}"
    if [ -n "$out" ]; then
      cat "$PAYLOAD" > "$out"
    else
      cat "$PAYLOAD"
    fi
    exit 0
    ;;
esac
exec /usr/bin/curl "$@"
