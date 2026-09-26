#!/usr/bin/env bash
# Makes every harness on this machine see exactly the skills in .agents/skills, and links the
# global instructions in global/AGENTS.md.
# Symlinks into ~/.claude/skills (Claude Code) and ~/.agents/skills (Codex, Amp, Cursor).
# Copies into ~/.cursor/skills, because Cursor's "Sync Skills for Cloud Agents" uploads that folder
# and may not follow symlinks. Safe to re-run; the post-commit and post-merge hooks run it.
# --cloud (for cloud agents, see cloud-setup.sh): copies into ~/.claude/skills and ~/.agents/skills
# with the manual-only flags removed, because cloud UIs can't invoke a skill by slash command.
set -euo pipefail
cloud=false
[ "${1:-}" = --cloud ] && cloud=true
repo="$(cd "$(dirname "$0")/.." && pwd)"
src="$repo/.agents/skills"
marker=".juan-skills"

link_into() {
  local dest="$1" entry name
  mkdir -p "$dest"
  for entry in "$dest"/* "$dest"/.[!.]*; do
    [ -L "$entry" ] || continue
    case "$(readlink "$entry")" in "$repo"/*) ;; *) continue ;; esac
    [ -d "$src/$(basename "$entry")" ] || rm "$entry"
  done
  for entry in "$src"/*/; do
    name="$(basename "$entry")"
    if [ -e "$dest/$name" ] && [ ! -L "$dest/$name" ]; then
      echo "skip $dest/$name: a real folder is in the way; remove it to link the repo copy" >&2
      continue
    fi
    ln -sfn "$src/$name" "$dest/$name"
  done
}

copy_into() {
  local dest="$1" entry name
  mkdir -p "$dest"
  for entry in "$dest"/*/; do
    [ -f "$entry$marker" ] || continue
    [ -d "$src/$(basename "$entry")" ] || rm -rf "$entry"
  done
  for entry in "$src"/*/; do
    name="$(basename "$entry")"
    if [ -L "$dest/$name" ]; then
      case "$(readlink "$dest/$name")" in "$repo"/*) rm "$dest/$name" ;; esac
    fi
    if [ -e "$dest/$name" ] && [ ! -f "$dest/$name/$marker" ]; then
      echo "skip $dest/$name: not created by this repo; remove it to copy the repo version" >&2
      continue
    fi
    rm -rf "${dest:?}/$name"
    cp -R "$entry" "$dest/$name"
    touch "$dest/$name/$marker"
    if $cloud; then allow_model_invocation "$dest/$name"; fi
  done
}

allow_model_invocation() {
  sed -i.bak '/^disable-model-invocation: true$/d' "$1/SKILL.md" && rm "$1/SKILL.md.bak"
  [ -f "$1/agents/openai.yaml" ] || return 0
  sed -i.bak 's/allow_implicit_invocation: false/allow_implicit_invocation: true/' "$1/agents/openai.yaml" &&
    rm "$1/agents/openai.yaml.bak"
}

report_strays() {
  local dest="$1" entry
  for entry in "$dest"/*; do
    [ -e "$entry" ] || [ -L "$entry" ] || continue
    [ -d "$src/$(basename "$entry")" ] && continue
    echo "not from juan-skills: $entry" >&2
  done
}

# Global instructions: one file, read by Claude Code as CLAUDE.md and by Codex and Amp as AGENTS.md.
# A symlink is replaced; a real file is left alone with a warning.
link_instructions() {
  local dest
  for dest in "$HOME/.claude/CLAUDE.md" "$HOME/.codex/AGENTS.md" "$HOME/.config/amp/AGENTS.md"; do
    if [ -e "$dest" ] && [ ! -L "$dest" ]; then
      echo "skip $dest: a real file is in the way; move its content into global/AGENTS.md and remove it" >&2
      continue
    fi
    mkdir -p "$(dirname "$dest")"
    ln -sfn "$repo/global/AGENTS.md" "$dest"
  done
}

link_instructions
if $cloud; then
  copy_into "$HOME/.claude/skills"
  copy_into "$HOME/.agents/skills"
  dirs=("$HOME/.claude/skills" "$HOME/.agents/skills")
else
  link_into "$HOME/.claude/skills"
  link_into "$HOME/.agents/skills"
  copy_into "$HOME/.cursor/skills"
  dirs=("$HOME/.claude/skills" "$HOME/.agents/skills" "$HOME/.cursor/skills")
fi
for d in "${dirs[@]}"; do report_strays "$d"; done
echo "linked $(ls "$src" | wc -l | tr -d ' ') skills"
