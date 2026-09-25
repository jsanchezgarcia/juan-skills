#!/usr/bin/env bash
# Makes every harness on this machine see exactly the skills in .agents/skills.
# Symlinks into ~/.claude/skills (Claude Code) and ~/.agents/skills (Codex, Amp, Cursor).
# Copies into ~/.cursor/skills, because Cursor's "Sync Skills for Cloud Agents" uploads that folder
# and may not follow symlinks. Safe to re-run; the post-commit and post-merge hooks run it.
set -euo pipefail
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
    if [ -e "$dest/$name" ] && [ ! -f "$dest/$name/$marker" ]; then
      echo "skip $dest/$name: not created by this repo; remove it to copy the repo version" >&2
      continue
    fi
    rm -rf "${dest:?}/$name"
    cp -R "$entry" "$dest/$name"
    touch "$dest/$name/$marker"
  done
}

report_strays() {
  local dest="$1" entry
  for entry in "$dest"/*; do
    [ -e "$entry" ] || [ -L "$entry" ] || continue
    [ -d "$src/$(basename "$entry")" ] && continue
    echo "not from juan-skills: $entry" >&2
  done
}

link_into "$HOME/.claude/skills"
link_into "$HOME/.agents/skills"
copy_into "$HOME/.cursor/skills"
for d in "$HOME/.claude/skills" "$HOME/.agents/skills" "$HOME/.cursor/skills"; do report_strays "$d"; done
echo "linked $(ls "$src" | wc -l | tr -d ' ') skills"
