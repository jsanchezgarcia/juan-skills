#!/usr/bin/env bash
# Pushes .agents/skills to Amp's hosted skills repo with each skill at the top level,
# the layout Amp requires, so Amp in the cloud loads the same set.
# Adds one commit on top of the hosted repo's history; skips the push when nothing changed.
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
cd "$repo"
git remote get-url amp >/dev/null 2>&1 || { echo "no amp remote; skipping Amp publish"; exit 0; }

git fetch -q amp main
tree=$(git rev-parse HEAD:.agents/skills)
if [ "$(git rev-parse amp/main^{tree})" = "$tree" ]; then
  echo "Amp hosted skills already up to date"
  exit 0
fi
commit=$(git commit-tree "$tree" -p amp/main -m "Publish skills from juan-skills $(git rev-parse --short HEAD)")
git push -q amp "$commit:refs/heads/main"
echo "published skills to Amp"
