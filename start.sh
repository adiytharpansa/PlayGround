#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
PROJECT_DIR="$(pwd)"
STATIC_DIR="$PROJECT_DIR/dist"
PORT="${PORT:-3000}"
export PORT
WEB_DIR="${OPENCODE_WEB_DIR:-/home/runner/work/_temp/omgithub-web}"
export WEB_DIR
/usr/bin/time -p mkdir -p "$WEB_DIR"
/usr/bin/time -p test -f "$STATIC_DIR/index.html"
/usr/bin/time -p bash -c 'test -f ./dist/index.html'
if /usr/bin/time -p test -f ./package.json; then
  if /usr/bin/time -p test -f ./package-lock.json; then
    /usr/bin/time -p npm ci --no-audit --no-fund
  else
    /usr/bin/time -p npm install --no-audit --no-fund
  fi
  if /usr/bin/time -p bash -c 'node -e "const p=require(\"./package.json\"); process.exit(p.scripts&&p.scripts.build?0:1)"'; then
    /usr/bin/time -p npm run build
  fi
fi
/usr/bin/time -p bash -c 'printf "%s" "$0" >/dev/null' "$STATIC_DIR"
/usr/bin/time -p node -e '
const fs = require("fs");
const dir = process.env.WEB_DIR || "/home/runner/work/_temp/omgithub-web";
fs.mkdirSync(dir, { recursive: true });
const out = { project: "/home/runner/work/PlayGround/PlayGround", directory: "/home/runner/work/PlayGround/PlayGround/dist" };
fs.writeFileSync(dir + "/deployment-output.json", JSON.stringify(out));
console.log("deployment-output:", JSON.stringify(out));
'
/usr/bin/time -p cat "$WEB_DIR/deployment-output.json"
/usr/bin/time -p node -e 'console.log("serving " + "/home/runner/work/PlayGround/PlayGround/dist" + " on port " + (process.env.PORT||"3000"))'
exec /usr/bin/time -p node --input-type=module -e '
import { createServer, request } from "node:http";
import { readFileSync, statSync, existsSync } from "node:fs";
import { resolve, join, extname } from "node:path";
const root = "/home/runner/work/PlayGround/PlayGround/dist";
const port = Number(process.env.PORT || "3000");
const mime = { ".html":"text/html; charset=utf-8", ".js":"application/javascript", ".css":"text/css", ".json":"application/json", ".svg":"image/svg+xml", ".png":"image/png", ".jpg":"image/jpeg", ".webp":"image/webp", ".wasm":"application/wasm", ".ico":"image/x-icon" };
const server = createServer((req, res) => {
  try {
    const url = new URL(req.url, "http://localhost");
    let path = resolve(root, "." + decodeURIComponent(url.pathname));
    if (path !== resolve(root) && !path.startsWith(resolve(root) + "/")) { res.writeHead(404); res.end("Not found"); return; }
    try { if (statSync(path).isDirectory()) path = join(path, "index.html"); } catch { path = join(root, "index.html"); }
    if (!existsSync(path)) path = join(root, "index.html");
    res.setHeader("Content-Type", mime[extname(path)] || "application/octet-stream");
    res.setHeader("Cache-Control", "no-cache");
    res.end(readFileSync(path));
  } catch { res.writeHead(404); res.end("Not found"); }
});
server.listen(port, "0.0.0.0", () => console.log("listening on " + port));
'
