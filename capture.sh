#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
RUNTIME_DIR="${RUNTIME_DIR:-/home/runner/work/_temp/omgithub-runtime}"
/usr/bin/time -p bash -c 'echo "capture url: ${0:-(unset)} dir: ${1:-(unset)}"' "${CAPTURE_URL:?Set CAPTURE_URL to the exact preview URL.}" "${CAPTURE_DIR:?Set CAPTURE_DIR to the output directory.}"
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p test -n "$CAPTURE_URL"
/usr/bin/time -p test -n "$CAPTURE_DIR"
/usr/bin/time -p node "$RUNTIME_DIR/scripts/default-capture.mjs"
/usr/bin/time -p test -f "$CAPTURE_DIR/final-desktop.png"
/usr/bin/time -p test -f "$CAPTURE_DIR/final-mobile.png"
/usr/bin/time -p ls -l "$CAPTURE_DIR/final-desktop.png" "$CAPTURE_DIR/final-mobile.png"
