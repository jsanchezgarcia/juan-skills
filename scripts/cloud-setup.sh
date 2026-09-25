#!/usr/bin/env bash
# Clones or updates this repo and links its skills. Cloud environments run the same
# lines from their setup script (see README), so every cloud session starts on the latest push.
set -euo pipefail
dest="$HOME/src/juan-skills"
if [ -d "$dest/.git" ]; then
  git -C "$dest" pull -q --ff-only
else
  git clone -q --depth 1 https://github.com/jsanchezgarcia/juan-skills.git "$dest"
fi
"$dest/scripts/link.sh"
