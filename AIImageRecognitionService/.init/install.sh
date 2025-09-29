#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/recipe-finding-app-98606-98493/AIImageRecognitionService"
cd "$WORKSPACE"
[ -f package.json ] || { echo "package.json missing; run scaffold first" >&2; exit 12; }
PKGMGR="${PKG_MANAGER:-}"
if [ -z "$PKGMGR" ]; then
  if [ -f yarn.lock ]; then PKGMGR="yarn"; else PKGMGR="npm"; fi
fi
SUMFILE=".install_sum"
TMPSUMFILE=".install_sum.tmp.$$"
CURSUM="$(sha256sum package.json 2>/dev/null | awk '{print $1}' || true)"
[ -f yarn.lock ] && CURSUM="$CURSUM-$(sha256sum yarn.lock 2>/dev/null | awk '{print $1}')"
if [ -f package-lock.json ] && [ "$PKGMGR" = "npm" ]; then CURSUM="$CURSUM-$(sha256sum package-lock.json 2>/dev/null | awk '{print $1}')"; fi
[ -n "$CURSUM" ] || { echo "failed to compute checksum" >&2; exit 13; }
OLDSUM=""
[ -f "$SUMFILE" ] && OLDSUM=$(cat "$SUMFILE" || true)
REINSTALL=0
if [ ! -d node_modules ] || [ "$CURSUM" != "$OLDSUM" ]; then REINSTALL=1; fi
if [ "$REINSTALL" -eq 1 ]; then
  if [ "$PKGMGR" = "yarn" ]; then
    command -v yarn >/dev/null || { echo "yarn required but missing" >&2; exit 14; }
    yarn install --silent || { echo "yarn install failed" >&2; exit 15; }
  else
    command -v npm >/dev/null || { echo "npm required but missing" >&2; exit 16; }
    if [ -f package-lock.json ]; then
      npm ci --no-audit --no-fund --silent || { echo "npm ci failed" >&2; exit 17; }
    else
      npm i --no-audit --no-fund --silent || { echo "npm install failed" >&2; exit 18; }
    fi
  fi
  printf "%s" "$CURSUM" > "$TMPSUMFILE" && mv "$TMPSUMFILE" "$SUMFILE"
fi
MISSING_BIN=0
if node -e "try{const p=require('./package.json'); process.exit((p.dependencies&&p.dependencies['react-scripts'])|| (p.devDependencies&&p.devDependencies['react-scripts'])?0:1);}catch(e){process.exit(1)}" >/dev/null 2>&1; then
  [ -x node_modules/.bin/react-scripts ] || MISSING_BIN=1
fi
if node -e "try{const p=require('./package.json'); if((p.dependencies&&p.dependencies.serve)||(p.devDependencies&&p.devDependencies.serve)) process.exit(0); process.exit(1);}catch(e){process.exit(1)}" >/dev/null 2>&1; then
  [ -x node_modules/.bin/serve ] || MISSING_BIN=1
fi
if [ "$MISSING_BIN" -eq 1 ]; then
  if [ "$PKGMGR" = "yarn" ]; then
    yarn add --dev serve@14.0.1 --silent || { echo "yarn add serve failed" >&2; exit 19; }
  else
    npm i --no-audit --no-fund --save-dev serve@14.0.1 --silent || { echo "npm install serve failed" >&2; exit 20; }
  fi
fi
[ -d node_modules ] || { echo "node_modules missing after install" >&2; exit 21; }
if [ -f package.json ] && node -e "try{const p=require('./package.json'); process.exit((p.dependencies&&p.dependencies['react-scripts'])|| (p.devDependencies&&p.devDependencies['react-scripts'])?0:1);}catch(e){process.exit(1)}" >/dev/null 2>&1; then
  [ -x node_modules/.bin/react-scripts ] || { echo "react-scripts binary missing" >&2; exit 22; }
fi
[ -x node_modules/.bin/serve ] || echo "note: serve not present locally" > /dev/null
