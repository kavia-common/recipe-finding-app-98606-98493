#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/recipe-finding-app-98606-98493/AIImageRecognitionService"
cd "$WORKSPACE"
[ -f package.json ] && exit 0
USE_CRA=0
if command -v create-react-app >/dev/null 2>&1; then
  CRA_V=$(create-react-app --version 2>/dev/null || echo "0")
  cra_major=${CRA_V%%.*}
  if [ "${cra_major:-0}" -ge 5 ]; then USE_CRA=1; fi
fi
if [ "$USE_CRA" -eq 1 ]; then
  create-react-app . --use-npm >/dev/null
else
  TMP=$(mktemp)
  cat > "$TMP" <<'JSON'
{
  "name": "ai-image-recognition-service",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "start": "react-scripts start",
    "build": "react-scripts build",
    "test": "react-scripts test --watchAll=false --passWithNoTests",
    "mock": "node mock_api/server.js"
  },
  "dependencies": {
    "react": "^18.0.0",
    "react-dom": "^18.0.0",
    "react-scripts": "^5.0.0",
    "dotenv": "^16.0.0",
    "express": "^4.18.0",
    "multer": "^1.4.5"
  }
}
JSON
  mv "$TMP" package.json
  mkdir -p src public mock_api/uploads
  cat > src/index.js <<'JS'
import React from 'react'
import { createRoot } from 'react-dom/client'
import App from './App'
createRoot(document.getElementById('root')).render(<App />)
JS
  cat > src/App.js <<'JS'
import React from 'react'
export default function App(){
  return <div id="app">AI Image Recognition Service (dev)</div>
}
JS
  cat > public/index.html <<'HTML'
<!doctype html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <title>AIImageRecognitionService</title>
</head>
<body>
  <div id="root"></div>
</body>
</html>
HTML
fi
cat > .env.example <<ENV
REACT_APP_API_URL=http://localhost:4000
REACT_APP_UPLOAD_PATH=$WORKSPACE/mock_api/uploads
ENV
TMP2=$(mktemp)
cat > "$TMP2" <<'NODE'
const express = require('express')
const multer = require('multer')
const path = require('path')
const fs = require('fs')
const UPLOAD_DIR = path.resolve(__dirname, 'uploads')
fs.mkdirSync(UPLOAD_DIR, { recursive: true })
const app = express()
app.use(express.json())
app.get('/health', (_, res) => res.json({ ok: true }))
const storage = multer.diskStorage({
  destination: (_, __, cb) => cb(null, UPLOAD_DIR),
  filename: (_, file, cb) => cb(null, Date.now() + '-' + file.originalname)
})
const upload = multer({ storage })
app.post('/recognize', upload.single('image'), (req, res) => {
  res.json({ status: 'stub', file: req.file ? req.file.filename : null })
})
const port = process.env.PORT || 4000
const srv = app.listen(port, () => console.log('mock api listening', port))
module.exports = srv
NODE
mv "$TMP2" mock_api/server.js
