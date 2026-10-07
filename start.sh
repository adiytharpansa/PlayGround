#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
PORT="${PORT:-3000}"
/usr/bin/time -p echo "PORT=$PORT"
/usr/bin/time -p bash -c 'echo "project dir: $(pwd)"'
PROJECT_ROOT="$(/usr/bin/time -p pwd)"
PROJECT_ROOT="$(cd "$PROJECT_ROOT" && /usr/bin/time -p pwd -P)"
DIST_DIR="$PROJECT_ROOT/dist"
/usr/bin/time -p mkdir -p "$DIST_DIR"
/usr/bin/time -p test -f "$DIST_DIR/index.html"
if /usr/bin/time -p test -f "$PROJECT_ROOT/package.json"; then
  /usr/bin/time -p bash -c 'cd "$0" && if test -f package-lock.json; then npm ci --no-audit --no-fund; else npm install --no-audit --no-fund; fi' "$PROJECT_ROOT"
  if /usr/bin/time -p bash -c 'cd "$0" && node -e "const p=require(\"./package.json\"); process.exit(p.scripts&&p.scripts.build?0:1)"' "$PROJECT_ROOT"; then
    /usr/bin/time -p bash -c 'cd "$0" && npm run build' "$PROJECT_ROOT"
  fi
fi
/usr/bin/time -p test -f "$DIST_DIR/index.html"
OPENCODE_WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
/usr/bin/time -p mkdir -p "$OPENCODE_WEB_DIR"
/usr/bin/time -p bash -c 'printf "%s" "$0" > "$1/deployment-output.json"' "{\"project\":\"$PROJECT_ROOT\",\"directory\":\"$DIST_DIR\"}" "$OPENCODE_WEB_DIR"
/usr/bin/time -p cat "$OPENCODE_WEB_DIR/deployment-output.json"
/usr/bin/time -p echo "serving $DIST_DIR on $PORT"
/usr/bin/time -p python3 -m http.server "$PORT" --directory "$DIST_DIR"
