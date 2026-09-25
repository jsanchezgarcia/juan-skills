#!/usr/bin/env bash
# One-time setup on a machine: harness settings, git hooks, then link.sh.
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"

set_json() {
  local file="$1" filter="$2"
  mkdir -p "$(dirname "$file")"
  [ -f "$file" ] || echo '{}' >"$file"
  jq "$filter" "$file" >"$file.tmp" && mv "$file.tmp" "$file"
}

# Claude Code: account-synced skills and the CE plugin would duplicate the repo's skills.
set_json "$HOME/.claude/settings.json" \
  '.syncClaudeAiSkills = false | .enabledPlugins["compound-engineering@compound-engineering-plugin"] = false'
# Amp: stop reading ~/.claude (plugin cache, synced skills); it gets the same skills from ~/.agents/skills.
set_json "$HOME/.config/amp/settings.json" '.["amp.skills.disableClaudeCodeSkills"] = true'

git -C "$repo" config core.hooksPath scripts/hooks
# Amp's hosted skills repo; the pre-push hook publishes to it.
git -C "$repo" remote get-url amp >/dev/null 2>&1 ||
  git -C "$repo" remote add amp https://ampcode.com/git/@user_01K7GADV8KTQSS4JVD80N66GNF/-/skills
"$repo/scripts/link.sh"
