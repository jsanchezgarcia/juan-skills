# Records progress in .context/setup-status so cloud agents wait for it (see /usr/local/bin/wait-for-workspace-setup).
mkdir -p .context
echo running > .context/setup-status
(
	set -e
	npx --yes npm@10.9.8 ci
) 2>&1 | tee .context/setup.log
status=${PIPESTATUS[0]}
echo "$status" > .context/setup-status
exit "$status"
