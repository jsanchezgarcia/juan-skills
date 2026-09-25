# juan-skills

The skills I use, for every agent: Claude Code, Codex, Amp and Cursor, locally and in the cloud. A skill is in use if its folder is in `.agents/skills/`. Push to GitHub and every agent picks up the change.

| Source | Skills | Pinned in |
|---|---|---|
| [mattpocock/skills](https://github.com/mattpocock/skills) | codebase-design, domain-modeling, grilling, improve-codebase-architecture, prototype, research, setup-matt-pocock-skills, tdd, to-spec, to-tickets, wayfinder, writing-for-agents | `skills-lock.json` (a `main` commit; his releases lag) |
| [EveryInc/compound-engineering-plugin](https://github.com/EveryInc/compound-engineering-plugin) | ce-work, ce-debug, ce-handoff, ce-resolve-pr-feedback, ce-pov, ce-ideate, ce-explain, wtf, ce-optimize, ce-bakeoff, ce-compound, and the skills they call: ce-simplify-code, ce-code-review, ce-noslop, ce-commit-push-pr, ce-commit, ce-babysit-pr. Not ce-plan or ce-brainstorm: grilling, to-spec and wayfinder cover that half; lfg needs both, so it's out too. | `skills-lock.json` (a release tag) |
| Mine | design-review, split-commits, ship (simplify, review and open the PR for work done outside ce-work) | — |

Upstream skills are installed with [`npx skills`](https://github.com/vercel-labs/skills) and never edited here.

## Set up with an agent

Paste this into Claude Code, Codex, Amp or Cursor on the new machine:

> Set up my agent skills from https://github.com/jsanchezgarcia/juan-skills. Clone it to `~/src/juan-skills` and follow its README's "Set up a machine" section. Do every step you can, then give me the "You do" steps from the README that are still open, with the exact text to paste for each.

## Set up a machine

1. Clone: `git clone git@github.com:jsanchezgarcia/juan-skills.git ~/src/juan-skills`
2. Run `~/src/juan-skills/scripts/install.sh`. It:
   - turns off Claude Code's claude.ai skill sync and the compound-engineering plugin, and stops Amp reading `~/.claude`, so each agent sees only these skills;
   - sets the git hooks: commit and pull re-link the skills, push publishes to Amp;
   - adds the `amp` remote;
   - runs `link.sh`, which symlinks the skills into `~/.claude/skills` and `~/.agents/skills` and copies them into `~/.cursor/skills`.
3. Read the `link.sh` output. `skip` lines are real folders blocking a link, and `not from juan-skills` lines are skills from somewhere else. Delete each one after I confirm it.
4. Check: ask each agent to list its skills. It should list exactly the skills above, plus the agent's own built-ins.

### You do (once per account, not per machine)

| Where | Step |
|---|---|
| Claude Code cloud | At claude.ai/code, edit the environment and paste the cloud snippet below into **Setup script**.  |
| Claude Code cloud | At claude.ai → Customize → Skills, remove the skills uploaded earlier, so they don't load twice. |
| Claude Code cloud | At claude.ai → Customize, remove the compound-engineering plugin. The cloud turns it on at every session start, loading all of CE next to this repo's subset; `settings.json` can't keep it off. |
| Codex cloud | At chatgpt.com/codex → Environments, paste the cloud snippet into the environment's setup script. |
| Cursor cloud | Cursor Settings → Agents → turn on **Sync Skills for Cloud Agents**. It uploads `~/.cursor/skills`. |
| Amp cloud | Nothing: pushing this repo publishes to Amp's hosted skills repo. |

Cloud snippet:

```sh
d="$HOME/src/juan-skills"
{ if [ -d "$d/.git" ]; then git -C "$d" pull -q --ff-only; else git clone -q --depth 1 https://github.com/jsanchezgarcia/juan-skills.git "$d"; fi && bash "$d/scripts/cloud-setup.sh"; } >/tmp/juan-skills-setup.log 2>&1 || echo "juan-skills setup failed, see /tmp/juan-skills-setup.log"
true
```

It runs `scripts/cloud-setup.sh`, so changes to the setup never need a new paste. A failure is logged to `/tmp/juan-skills-setup.log` and never blocks the session. Cloud environments cache the setup script's result, so `cloud-setup.sh` also installs a Claude Code SessionStart hook that pulls the latest push at the start of every session; a skill added or removed shows up one session later.

In the cloud, the web app's `/` menu doesn't list these skills. Ask for one by name instead ("use wayfinder"). To make that work, the cloud copies drop the manual-only flag, so there the agent can also pick `wayfinder`, `to-spec`, `to-tickets` and `setup-matt-pocock-skills` on its own.

Check a cloud with a new session: "List your skills, say which commit `~/src/juan-skills` is on, and show `/tmp/juan-skills-setup.log`." Compare the commit with `git log -1` here.

## Day to day

| Change | Do |
|---|---|
| Edit or add one of my skills | Edit under `.agents/skills/`, commit, push. Commit re-links locally; push reaches Amp directly and the other clouds on their next session. |
| Upstream updates | Run `scripts/check-upstream.sh`. It lists changed skills, new upstream skills, and new CE skills that yours start calling, then prints the update command. Run that command with `DISABLE_TELEMETRY=1`, review `git diff`, commit, push. |
| Add an upstream skill | `DISABLE_TELEMETRY=1 npx skills add '<repo>#<ref>' -s <name> -a claude-code -a codex -a cursor -a amp -y`, commit, push. For a CE skill, check which `ce-*` skills it calls. |
| Remove a skill | Delete its folders under `.agents/skills/` and `.claude/skills/` and its `skills-lock.json` entry, commit, push. |

## Scripts

| Script | Does |
|---|---|
| `install.sh` | One-time machine setup (above) |
| `link.sh` | Links the skills into every local agent; run by the commit and pull hooks. `--cloud` copies them for cloud agents instead |
| `cloud-setup.sh` | Cloud setup: pulls, copies the skills with `link.sh --cloud`, installs the SessionStart hook |
| `publish-amp.sh` | Publishes to Amp's hosted repo; run by the push hook |
| `check-upstream.sh` | Reports upstream changes and prints the update command |
| `build-claude-ai.sh` | Fallback if the Claude Code cloud setup script can't load skills: zips changed skills for upload at claude.ai → Customize → Skills |
