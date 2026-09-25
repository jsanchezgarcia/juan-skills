#!/usr/bin/env bash
# Zips each skill that changed since the last claude.ai upload into dist/, one zip per skill.
# Upload them at claude.ai → Customize → Skills → Add → Upload skill, then run with --mark.
# Skills deleted from the repo are listed; remove those on claude.ai by hand.
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
tag=claude-ai-uploaded
cd "$repo"

if [ "${1:-}" = --mark ]; then
  git tag -f "$tag" HEAD >/dev/null
  echo "marked HEAD as uploaded to claude.ai"
  exit 0
fi

if git rev-parse -q --verify "refs/tags/$tag" >/dev/null; then
  changed=$(git diff --name-only "$tag" HEAD -- .agents/skills | cut -d/ -f3 | sort -u)
else
  changed=$(ls .agents/skills)
fi

rm -rf dist && mkdir dist
for name in $changed; do
  if [ -d ".agents/skills/$name" ]; then
    (cd .agents/skills && zip -qr "$repo/dist/$name.zip" "$name" -x '*/.DS_Store')
    echo "upload dist/$name.zip"
  else
    echo "delete on claude.ai: $name"
  fi
done
[ -n "$changed" ] || echo "nothing changed since the last upload"
