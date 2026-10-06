#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
PORT="${PORT:-3000}"
PROJECT_ROOT="$(/usr/bin/time -p pwd)"
DIST="$PROJECT_ROOT/dist"
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
/usr/bin/time -p mkdir -p "$DIST" "$WEB_DIR"
if /usr/bin/time -p test -f "$PROJECT_ROOT/package.json"; then
  if /usr/bin/time -p test -f "$PROJECT_ROOT/package-lock.json"; then
    /usr/bin/time -p npm ci --no-audit --no-fund
  else
    /usr/bin/time -p npm install --no-audit --no-fund
  fi
  if /usr/bin/time -p npm run --silent build --if-present; then
    true
  fi
fi
/usr/bin/time -p test -f "$DIST/index.html"
export PROJECT_ROOT DIST WEB_DIR
/usr/bin/time -p python3 -c 'import json,os; open(os.path.join(os.environ["WEB_DIR"],"deployment-output.json"),"w").write(json.dumps({"project":os.environ["PROJECT_ROOT"],"directory":os.environ["DIST"]}))'
/usr/bin/time -p cat "$WEB_DIR/deployment-output.json"
/usr/bin/time -p python3 -m http.server "$PORT" --directory "$DIST" --bind 0.0.0.0
