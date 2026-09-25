#!/usr/bin/env bash
# For each upstream in skills-lock.json, compares the pinned ref with the latest one and reports:
# which installed skills changed, which skills are new upstream, and any ce-* skill that an
# installed CE skill newly references but the repo doesn't have. Prints the update command.
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
lock="${SKILLS_LOCK:-$repo/skills-lock.json}"
work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT

latest_ref() {
  case "$1" in
    EveryInc/compound-engineering-plugin)
      gh api "repos/$1/releases" --jq '[.[] | select(.tag_name | startswith("compound-engineering-v"))][0].tag_name' ;;
    *) gh api "repos/$1/commits/HEAD" --jq .sha ;;
  esac
}

skill_dirs() { git -C "$1" ls-tree -r --name-only "$2" | grep '/SKILL.md$' | xargs -n1 dirname | sort; }

ce_refs() {
  local clone="$1" ref="$2" dir
  for dir in $3; do git -C "$clone" grep -hoP '\bce-[a-z]+(?:-[a-z]+)*' "$ref" -- "$dir" || true; done | sort -u
}

installed=$(ls "$repo/.agents/skills")
for source in $(jq -r '[.skills[].source] | unique[]' "$lock"); do
  pinned=$(jq -r --arg s "$source" '[.skills[] | select(.source == $s) | .ref] | unique | .[0]' "$lock")
  latest=$(latest_ref "$source")
  echo "== $source"
  if [ "$pinned" = "$latest" ]; then echo "up to date at $pinned"; continue; fi
  echo "pinned $pinned, latest $latest"

  clone="$work/$(basename "$source")"
  git clone -q --bare "https://github.com/$source.git" "$clone"
  git -C "$clone" fetch -q origin "$pinned" "$latest" 2>/dev/null || git -C "$clone" fetch -q --tags origin
  old=$(git -C "$clone" rev-parse "$pinned^{commit}")
  new=$(git -C "$clone" rev-parse "$latest^{commit}")

  paths=$(jq -r --arg s "$source" '.skills[] | select(.source == $s) | .skillPath | sub("/SKILL.md$"; "")' "$lock")
  names=$(jq -r --arg s "$source" '.skills | to_entries[] | select(.value.source == $s) | .key' "$lock")
  echo "installed skills that changed:"
  for p in $paths; do
    git -C "$clone" diff --quiet "$old" "$new" -- "$p" 2>/dev/null || echo "  $(basename "$p")"
  done
  git -C "$clone" cat-file -e "$new:$(echo "$paths" | head -1)/SKILL.md" 2>/dev/null || echo "  warning: skill folders moved upstream; check paths"

  echo "new upstream skills:"
  comm -13 <(skill_dirs "$clone" "$old" | xargs -n1 basename | sort) \
           <(skill_dirs "$clone" "$new" | xargs -n1 basename | sort) | sed 's/^/  /'

  if [ "$source" = EveryInc/compound-engineering-plugin ]; then
    echo "ce-* skills newly referenced by installed CE skills and missing here:"
    comm -13 <(ce_refs "$clone" "$old" "$paths") <(ce_refs "$clone" "$new" "$paths") \
      | comm -12 - <(skill_dirs "$clone" "$new" | xargs -n1 basename | sort) \
      | comm -23 - <(echo "$installed") | sed 's/^/  /'
  fi

  echo "update: npx skills add '$source#$latest'$(printf ' -s %s' $names) -a claude-code -a codex -a cursor -a amp -y"
done
