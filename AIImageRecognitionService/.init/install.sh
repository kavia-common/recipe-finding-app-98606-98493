#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/recipe-finding-app-98606-98493/AIImageRecognitionService"
PROFILE=/etc/profile.d/dev_node_path.sh
command -v node >/dev/null 2>&1 || { echo "node not found" >&2; exit 2; }
command -v npm >/dev/null 2>&1 || { echo "npm not found" >&2; exit 3; }
NODE_V=$(node -v 2>/dev/null || echo "v0")
NODE_MAJOR=$(echo "${NODE_V}" | sed -E 's/^v([0-9]+).*/\1/' || echo 0)
if [ "${NODE_MAJOR:-0}" -lt 16 ]; then echo "node >=16 required, found ${NODE_V}" >&2; exit 4; fi
NPM_PREFIX=$(npm config get prefix 2>/dev/null || true)
NPM_BIN=""
if [ -n "${NPM_PREFIX}" ] && [ -d "${NPM_PREFIX}/bin" ]; then NPM_BIN="${NPM_PREFIX}/bin"; fi
TMP=$(mktemp)
cat > "${TMP}" <<EOF
# added by dev setup - only adds npm global bin if present
[ -d "${NPM_BIN}" ] && export PATH="${NPM_BIN}:$PATH"
EOF
if ! sudo test -f "${PROFILE}" || ! sudo cmp -s "${TMP}" "${PROFILE}"; then
  sudo mv "${TMP}" "${PROFILE}"
  sudo chown root:root "${PROFILE}"
  sudo chmod 644 "${PROFILE}"
else
  rm -f "${TMP}"
fi
# immediate local effect where possible
source "${PROFILE}" || true
# validate PATH contains npm global bin if it exists
if [ -n "${NPM_BIN}" ] && [ -d "${NPM_BIN}" ]; then
  echo "npm_prefix=${NPM_PREFIX} npm_bin=${NPM_BIN}"
  command -v npm >/dev/null 2>&1 || true
fi
# provide runtime versions
echo "node=${NODE_V} npm=$(npm -v 2>/dev/null || echo 'unknown')"
