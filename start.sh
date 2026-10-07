#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
/usr/bin/time -p mkdir -p dist
/usr/bin/time -p cp -f index.html dist/index.html
/usr/bin/time -p bash -c 'PROJECT_DIR="$(pwd)"; DIST_DIR="$PROJECT_DIR/dist"; WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"; mkdir -p "$WEB_DIR"; printf "{\"project\":\"%s\",\"directory\":\"%s\"}" "$PROJECT_DIR" "$DIST_DIR" > "$WEB_DIR/deployment-output.json"; cat "$WEB_DIR/deployment-output.json"; echo'
PORT="${PORT:-3000}"
export PORT
/usr/bin/time -p bash -c 'echo "Serving $PWD/dist on port ${PORT:-3000}"'
/usr/bin/time -p python3 -m http.server "$PORT" --directory dist --bind 0.0.0.0
