#!/usr/bin/env bash
# Cloud agents: brings the skills up to date and copies them in with `link.sh --cloud`.
# Cloud environments cache the result of their setup script, so this also installs a Claude Code
# SessionStart hook that re-runs it at the start of every session. See the README's cloud snippet.
set -euo pipefail
repo="$(cd "$(dirname "$0")/.." && pwd)"
settings="$HOME/.claude/settings.json"
hook="bash \"$repo/scripts/cloud-setup.sh\" >/tmp/juan-skills-setup.log 2>&1 || true"

git -C "$repo" pull -q --ff-only || echo "pull failed; using the current checkout" >&2
"$repo/scripts/link.sh" --cloud

mkdir -p "$(dirname "$settings")"
[ -f "$settings" ] || echo '{}' >"$settings"
grep -qF "scripts/cloud-setup.sh" "$settings" && exit 0
python3 - "$settings" "$hook" <<'EOF'
import json, sys
path, command = sys.argv[1], sys.argv[2]
with open(path) as f:
    settings = json.load(f)
settings.setdefault("hooks", {}).setdefault("SessionStart", []).append(
    {"hooks": [{"type": "command", "command": command}]}
)
with open(path, "w") as f:
    json.dump(settings, f, indent=2)
EOF
echo "installed the SessionStart hook in $settings"
