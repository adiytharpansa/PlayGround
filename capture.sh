#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p bash -c 'test -n "${CAPTURE_URL:?CAPTURE_URL not set}" && test -n "${CAPTURE_DIR:?CAPTURE_DIR not set}" && echo "Capturing $CAPTURE_URL -> $CAPTURE_DIR"'
/usr/bin/time -p mkdir -p "${CAPTURE_DIR:?}"
/usr/bin/time -p node "${RUNTIME_DIR:?}/scripts/default-capture.mjs"
/usr/bin/time -p ls -lh "${CAPTURE_DIR:?}"
