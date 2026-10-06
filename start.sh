#!/usr/bin/env bash
# OpenCode App launcher: serve static dist/ in foreground on PORT (default 3000).
set -euo pipefail
/usr/bin/time -p bash -c 'true'
cd "$(dirname "$0")"
/usr/bin/time -p pwd
PROJECT_DIR_ABS="$(pwd)"
PORT="${PORT:-3000}"
export PORT
DIST_DIR="$PROJECT_DIR_ABS/dist"
export DIST_DIR
OPENCODE_WEB_FALLBACK="/home/runner/work/_temp/omgithub-web"
WEB_DIR="${OPENCODE_WEB_DIR:-$OPENCODE_WEB_FALLBACK}"
/usr/bin/time -p test -f "$DIST_DIR/index.html"
/usr/bin/time -p test -s "$DIST_DIR/index.html"
if /usr/bin/time -p test -f "$PROJECT_DIR_ABS/package.json"; then
  if /usr/bin/time -p test -f "$PROJECT_DIR_ABS/package-lock.json"; then
    /usr/bin/time -p npm ci --no-audit --no-fund
  else
    /usr/bin/time -p npm install --no-audit --no-fund
  fi
  if /usr/bin/time -p node -e "const p=require('./package.json');process.exit(p.scripts&&p.scripts.build?0:1)"; then
    /usr/bin/time -p npm run build
  fi
  /usr/bin/time -p test -f "$DIST_DIR/index.html"
else
  /usr/bin/time -p echo "no package.json: static site, skipping install/build"
fi
/usr/bin/time -p mkdir -p "$WEB_DIR"
/usr/bin/time -p mkdir -p /home/runner/work/_temp/omgithub-web
DEPLOY_JSON="{\"project\":\"$PROJECT_DIR_ABS\",\"directory\":\"$DIST_DIR\"}"
/usr/bin/time -p bash -c 'printf "%s" "$0" > "$1/deployment-output.json"' "$DEPLOY_JSON" "$WEB_DIR"
/usr/bin/time -p bash -c 'printf "%s" "$0" > "$1/deployment-output.json"' "$DEPLOY_JSON" /home/runner/work/_temp/omgithub-web
/usr/bin/time -p cat "$WEB_DIR/deployment-output.json"
/usr/bin/time -p echo "serving $DIST_DIR on PORT=$PORT"
/usr/bin/time -p node -e "
const http=require('http'),fs=require('fs'),path=require('path');
const root=process.env.DIST_DIR||'$DIST_DIR';
const port=Number(process.env.PORT||'$PORT')||3000;
const mime={'.html':'text/html','.js':'application/javascript','.css':'text/css','.json':'application/json','.svg':'image/svg+xml','.png':'image/png','.jpg':'image/jpeg','.webp':'image/webp','.ico':'image/x-icon','.txt':'text/plain'};
const server=http.createServer((req,res)=>{
  try{
    const url=new URL(req.url,'http://localhost');
    let p=path.resolve(root,'.'+decodeURIComponent(url.pathname));
    if(p!==path.resolve(root)&&!p.startsWith(path.resolve(root)+'/')){res.writeHead(404);res.end();return;}
    let st; try{st=fs.statSync(p);}catch{res.writeHead(404);res.end('Not found');return;}
    const file=st.isDirectory()?path.join(p,'index.html'):p;
    const data=fs.readFileSync(file);
    res.setHeader('Content-Type',mime[path.extname(file)]||'application/octet-stream');
    res.setHeader('Cache-Control','no-cache');
    res.end(data);
  }catch{res.writeHead(404);res.end('Not found');}
});
server.listen(port,'0.0.0.0',()=>console.log('OpenCode App listening on '+port+' serving '+root));
"
