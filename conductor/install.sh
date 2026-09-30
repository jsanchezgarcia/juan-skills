sudo dnf install -y \
  gcc gcc-c++ make python3-devel git openssl-devel \
  libX11 libXcomposite libXdamage libXrandr mesa-libgbm \
  alsa-lib atk at-spi2-atk cups-libs gtk3 nss libdrm \
  libxkbcommon pango cairo dbus-libs xorg-x11-server-Xvfb

curl --fail --silent --show-error --location \
  https://nodejs.org/dist/v22.23.1/node-v22.23.1-linux-x64.tar.xz \
  --output /tmp/node-v22.23.1-linux-x64.tar.xz
sudo tar -xJf /tmp/node-v22.23.1-linux-x64.tar.xz \
  --strip-components=1 --directory /usr/local
sudo /usr/local/bin/npm install --global npm@11.20.0
/usr/local/bin/npm cache add npm@10.9.8

node --version
npm --version

# Playwright's Chromium, version-matched to the repo's playwright-core (1.56.1).
# No --with-deps: that uses apt. The dnf packages above supply the libraries.
npx --yes playwright-core@1.56.1 install chromium

# Conductor drops OPENROUTER_API_KEY from cloud workspaces, so the key is saved
# in settings as OPENROUTER_KEY and re-exported under its real name in every shell.
mkdir -p "$HOME/.bashrc.d"
cat > "$HOME/.bashrc.d/openrouter.sh" <<'EOF'
# Conductor drops OPENROUTER_API_KEY from cloud workspaces, so the key is saved as OPENROUTER_KEY.
if [ -z "${OPENROUTER_API_KEY:-}" ] && [ -n "${OPENROUTER_KEY:-}" ]; then
	export OPENROUTER_API_KEY="$OPENROUTER_KEY"
fi
EOF

# Cloud workspaces start the agent while the repository setup script is still running, so agents
# ran npm against a half-installed node_modules. Each repository's setup script writes
# .context/setup-status; a SessionStart hook in Claude Code and Codex holds the first turn until it ends.
sudo tee /usr/local/bin/wait-for-workspace-setup >/dev/null <<'EOF'
#!/usr/bin/env bash
# Cloud workspaces start the agent while the repository setup script is still running.
# The setup script writes "running" to .context/setup-status, then its exit code when it ends;
# Claude Code and Codex run this as a SessionStart hook, which holds the first turn until then.
# No file means no setup to wait for.
status_file="${CONDUCTOR_WORKSPACE_PATH:-$PWD}/.context/setup-status"
[ -f "$status_file" ] || exit 0
deadline=$((SECONDS + 840))
while [ "$(cat "$status_file")" = running ]; do
	if [ "$SECONDS" -ge "$deadline" ]; then
		echo "Workspace setup is still running after 14 minutes. Don't install or run project commands until .context/setup-status holds an exit code."
		exit 0
	fi
	sleep 2
done
status="$(cat "$status_file")"
if [ "$status" = 0 ]; then
	echo "Workspace setup finished."
else
	echo "Workspace setup failed (exit $status). Its output is in .context/setup.log. Fix that before anything else."
fi
EOF
sudo chmod 755 /usr/local/bin/wait-for-workspace-setup

mkdir -p "$HOME/.claude"
python3 - "$HOME/.claude/settings.json" <<'EOF'
import json, os, sys
path = sys.argv[1]
settings = json.load(open(path)) if os.path.exists(path) else {}
session_start = settings.setdefault("hooks", {}).setdefault("SessionStart", [])
if "wait-for-workspace-setup" not in json.dumps(session_start):
    session_start.insert(0, {"hooks": [{"type": "command", "command": "/usr/local/bin/wait-for-workspace-setup", "timeout": 900}]})
with open(path, "w") as f:
    json.dump(settings, f, indent=2)
EOF

# Hooks in the system config count as managed, so Codex runs them without asking for review.
sudo mkdir -p /etc/codex
if ! sudo grep -q wait-for-workspace-setup /etc/codex/config.toml 2>/dev/null; then
	sudo tee -a /etc/codex/config.toml >/dev/null <<'EOF'
[[hooks.SessionStart]]
[[hooks.SessionStart.hooks]]
type = "command"
command = "/usr/local/bin/wait-for-workspace-setup"
timeout = 900
EOF
fi

d="$HOME/src/juan-skills"
{ if [ -d "$d/.git" ]; then git -C "$d" pull -q --ff-only; else git clone -q --depth 1 https://github.com/jsanchezgarcia/juan-skills.git "$d"; fi && bash "$d/scripts/cloud-setup.sh"; } >/tmp/juan-skills-setup.log 2>&1 || echo "juan-skills setup failed, see /tmp/juan-skills-setup.log"
true
