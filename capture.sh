#!/usr/bin/env bash
# Capture desktop + mobile screenshots of CAPTURE_URL into CAPTURE_DIR.
# Exit 75 = temporary navigation/browser infra failure, exit 1 = script/rendering defect.
set -euo pipefail
/usr/bin/time -p bash -c 'true'
cd "$(dirname "$0")"
PROJECT_ROOT="$(pwd)"
if [[ -z "${CAPTURE_URL:-}" ]]; then echo "CAPTURE_URL is required" >&2; exit 1; fi
if [[ -z "${CAPTURE_DIR:-}" ]]; then echo "CAPTURE_DIR is required" >&2; exit 1; fi
/usr/bin/time -p echo "capturing $CAPTURE_URL -> $CAPTURE_DIR"
case "$CAPTURE_DIR" in
  "$PROJECT_ROOT"/*) echo "CAPTURE_DIR must stay outside project source: $CAPTURE_DIR" >&2; exit 1;;
esac
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p bash -n "$PROJECT_ROOT/capture.sh"
/usr/bin/time -p node "${RUNTIME_DIR:?}/scripts/default-capture.mjs"
status=$?
/usr/bin/time -p echo "capture engine exited with $status"
if [[ $status -ne 0 ]]; then exit "$status"; fi
/usr/bin/time -p test -f "$CAPTURE_DIR/final-desktop.png"
/usr/bin/time -p test -f "$CAPTURE_DIR/final-mobile.png"
/usr/bin/time -p test -s "$CAPTURE_DIR/final-desktop.png"
/usr/bin/time -p test -s "$CAPTURE_DIR/final-mobile.png"
/usr/bin/time -p ls -la "$CAPTURE_DIR"
