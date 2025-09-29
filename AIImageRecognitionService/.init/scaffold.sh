#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/recipe-finding-app-98606-98493/AIImageRecognitionService"
mkdir -p "$WORKSPACE" && cd "$WORKSPACE"
[ -f package.json ] && exit 0
# Check node major version >=16
NODE_MAJOR=$(node -v | sed 's/v//' | cut -d. -f1)
if [ "${NODE_MAJOR:-0}" -lt 16 ]; then echo "node >=16 required, found $(node -v)" >&2; exit 7; fi
# TypeScript detection: env override or tsconfig or file presence (robust find)
USE_TS=0
if [ -n "${USE_TYPESCRIPT:-}" ] && [ "${USE_TYPESCRIPT}" != "0" ]; then USE_TS=1; fi
if [ -f tsconfig.json ]; then USE_TS=1; fi
if find . -type f \( -name "*.ts" -o -name "*.tsx" \) -print -quit | grep -q .; then USE_TS=1; fi
# Prefer preinstalled create-react-app if available
CRA_CMD=""
if command -v create-react-app >/dev/null 2>&1; then
  CRA_VER=$(create-react-app --version 2>/dev/null || true)
  CRA_CMD="create-react-app"
fi
# Use pinned CRA via npx fallback to 5.x to avoid upstream variability
if [ -n "${CRA_CMD}" ]; then
  if [ "$USE_TS" -eq 1 ]; then
    "$CRA_CMD" . --template typescript --use-npm --silent || { echo "create-react-app failed" >&2; exit 8; }
  else
    "$CRA_CMD" . --use-npm --silent || { echo "create-react-app failed" >&2; exit 9; }
  fi
else
  if [ "$USE_TS" -eq 1 ]; then
    npx --yes create-react-app@5.0.1 . --template typescript --use-npm --silent || { echo "npx create-react-app failed" >&2; exit 10; }
  else
    npx --yes create-react-app@5.0.1 . --use-npm --silent || { echo "npx create-react-app failed" >&2; exit 11; }
  fi
fi
# Fallback minimal scaffold if CRA didn't produce package.json
if [ ! -f package.json ]; then
  cat > package.json <<'JSON'
{
  "name": "ai-image-recognition-service",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "start": "BROWSER=none react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test --watchAll=false --runInBand"
  },
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0",
    "react-scripts": "5.0.1",
    "dotenv": "^16.0.0"
  },
  "devDependencies": {
    "jsdom": "^21.0.0",
    "serve": "^14.0.1"
  }
}
JSON
  mkdir -p public src
  cat > public/index.html <<'HTML'
<!doctype html><html><head><meta charset="utf-8"><title>AI Image Recognition Service</title></head><body><div id="root"></div></body></html>
HTML
  cat > src/index.js <<'JS'
import React from 'react';import { createRoot } from 'react-dom/client';import './index.css';const App=()=>React.createElement('div',null,'AI Image Recognition Service');createRoot(document.getElementById('root')).render(React.createElement(App));
JS
  cat > src/index.css <<'CSS'
body{font-family:Arial,Helvetica,sans-serif}
CSS
fi
# .env example, gitignore, readme, and tmp storage (writable)
cat > .env.example <<'ENV'
REACT_APP_AI_API_URL=https://api.example.com/recognize # set your AI API endpoint
ENV
cat > .gitignore <<'GIT'
node_modules
build
.env
.env.local
tmp_images
validation_evidence.txt
validation_log.txt
validation_versions.txt
GIT
cat > README.md <<'MD'
# AI Image Recognition Service
Scaffolded minimal React app. Copy .env.example -> .env and set REACT_APP_AI_API_URL
Commands: npm install; npm start (dev), npm run build (prod)
MD
mkdir -p tmp_images && chmod 0777 tmp_images
