#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
/usr/bin/time -p pwd
/usr/bin/time -p bash -n ./capture.sh
if [[ -z "${CAPTURE_URL:-}" || -z "${CAPTURE_DIR:-}" ]]; then
  echo "Set CAPTURE_URL and CAPTURE_DIR." >&2
  exit 1
fi
/usr/bin/time -p mkdir -p "$CAPTURE_DIR"
/usr/bin/time -p bash -c 'echo "capturing $0 -> $1" "$CAPTURE_URL" "$CAPTURE_DIR"'
export CAPTURE_URL CAPTURE_DIR
/usr/bin/time -p node --input-type=module <<'NODE_EOF'
import { mkdirSync, readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { createRequire } from "node:module";

const url = process.env.CAPTURE_URL;
const output = process.env.CAPTURE_DIR;
if (!url || !output) { console.error("Set CAPTURE_URL and CAPTURE_DIR."); process.exit(1); }
mkdirSync(output, { recursive: true });

const runtime = join(process.env.HOME || "/home/runner", ".local/share/omgithub-playwright");
const require = createRequire(join(runtime, "package.json"));
let chromium;
try {
  chromium = require("playwright").chromium;
} catch (e) { console.error("playwright module missing:", e.message); process.exit(75); }

let config = null;
for (const f of [join(runtime, process.platform === "darwin" ? "metal.json" : "linux.json")]) {
  try { config = JSON.parse(readFileSync(f, "utf8")); break; } catch {}
}
const launchOptions = config?.browser?.launchOptions || { headless: true };
if (process.platform === "linux") {
  try {
    if (!process.env.DISPLAY) {
      const d = readFileSync(join(runtime, "display"), "utf8").trim();
      if (d) process.env.DISPLAY = ":" + d;
    }
  } catch {}
}
const transient = (e) => { const err = e instanceof Error ? e : new Error(String(e)); err.exitCode = 75; throw err; };
let browser;
try {
  browser = await chromium.launch({ ...launchOptions, timeout: 30000 }).catch(transient);
  for (const [name, width, height] of [["desktop", 1440, 900], ["mobile", 390, 844]]) {
    const page = await browser.newPage({ viewport: { width, height } }).catch(transient);
    page.setDefaultTimeout(30000);
    page.on("pageerror", (e) => console.error(e.message));
    const response = await page.goto(url, { waitUntil: "load", timeout: 45000 }).catch(transient);
    if (!response?.ok()) {
      const s = response?.status();
      const code = !response || [408, 429, 500, 502, 503, 504].includes(s) ? 75 : 1;
      throw Object.assign(new Error(`HTTP ${s} loading preview`), { exitCode: code });
    }
    await page.locator("body").waitFor({ state: "visible" });
    await page.waitForFunction(() => document.fonts.status === "loaded").catch(() => {});
    await page.waitForTimeout(1000);
    await page.screenshot({ path: join(output, `final-${name}.png`), timeout: 30000 }).catch((e) => {
      if (e.name === "TimeoutError" || !browser.isConnected()) transient(e);
      throw e;
    });
    console.log(`captured final-${name}.png`);
    await page.close();
  }
} catch (e) { console.error(e); process.exitCode = e.exitCode || 1; }
finally { await browser?.close().catch((e) => { console.error(e); process.exitCode ||= 75; }); }
NODE_EOF
status=$?
/usr/bin/time -p bash -c 'ls -la "$0"' "$CAPTURE_DIR"
exit $status
