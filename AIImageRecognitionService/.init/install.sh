#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/recipe-finding-app-98606-98493/AIImageRecognitionService"
cd "$WORKSPACE"
mkdir -p "$WORKSPACE/mock_api/uploads" "$WORKSPACE/.logs"
# If node_modules exists, check key package dirs
if [ -d node_modules ] && [ -d node_modules/react ] && [ -d node_modules/react-dom ] && [ -d node_modules/react-scripts ]; then
  echo "install-03: dependencies present, skipping install"
  exit 0
fi
export CI=1
if [ -f package-lock.json ]; then
  npm ci --silent --no-audit --no-fund --no-optional
else
  npm i --silent --no-audit --no-fund --no-optional
fi
# verify install
[ -d node_modules ] || { echo "npm install failed: node_modules missing" >&2; exit 8; }
[ -d node_modules/react ] || { echo "npm install failed: react missing" >&2; exit 9; }
[ -d node_modules/react-scripts ] || { echo "npm install failed: react-scripts missing" >&2; exit 10; }
echo "install-03: install complete"
