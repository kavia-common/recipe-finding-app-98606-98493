#!/usr/bin/env bash
set -euo pipefail
WORKSPACE="/home/kavia/workspace/code-generation/recipe-finding-app-98606-98493/AIImageRecognitionService"
mkdir -p "${WORKSPACE}" && cd "${WORKSPACE}"
[ -f package.json ] && exit 0
# safe emptiness check
shopt -s nullglob dotglob
entries=("${WORKSPACE}"/*)
count=0
for p in "${entries[@]:-}"; do
  base=$(basename "${p}")
  [ "${base}" = ".git" ] && continue
  count=$((count+1))
done
if [ "${count}" -gt 0 ]; then echo "workspace not empty (except .git); refusing to scaffold" >&2; exit 6; fi
# prefer npx if available, otherwise use npm exec to invoke create-react-app
if command -v npx >/dev/null 2>&1; then
  npx --yes create-react-app . --use-npm || npx --yes create-react-app . --use-npm
else
  npm exec --yes create-react-app . -- --use-npm || { echo 'create-react-app invocation failed' >&2; exit 7; }
fi
# minimal .env example for API keys
cat > .env.example <<EOF
REACT_APP_API_URL=
REACT_APP_API_KEY=
EOF
