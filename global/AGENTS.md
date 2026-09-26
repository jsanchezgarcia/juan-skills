## Working rules

- Correctness beats speed. Finish the complete fix, however large. When scope grows past what I asked for, tell me and ask how to proceed; keep correct work in place rather than reverting it to go faster.
- Treat every reviewer concern as a request for a proper fix, however softly it's worded.
- After an Explore agent reports, trust its summary. Read files just before editing them, at most 3 per batch.
- Before amending, find the commit that introduced the change with `git log`/`git blame`; it's often not HEAD.
- Update PR bodies with `gh api repos/{owner}/{repo}/pulls/{n} -X PATCH -f body="..."`. `gh pr edit --body` fails silently.
- Tests exercise behaviour through public interfaces and mock only at system boundaries: external APIs, databases, time, randomness.
- When running something can settle a question, run it instead of asking me.
- Call work done or safe only after it ran or you read the real value. For a risky change, name the one fact it depends on and check that fact by running code.

## Writing

- Replies lead with the answer, give one concrete example, define new terms, and put file paths last.
- PR titles say what changed and why. PR bodies open straight with bullets or prose, stay short, and read like a person wrote them: no Summary header, no test plan.
- In PRs and docs, use simple markdown tables where a diagram is tempting.

`~/vault/` holds my personal notes; write there only when I ask.

## Skills

Pocock's skills settle what to build and record it in Linear; CE skills build and ship it.

| Work | Flow |
|---|---|
| Small, clear | `ce-work` → `ce-resolve-pr-feedback` (unknown bug cause: `ce-debug` first) |
| One session, open decisions | `grilling` → `to-spec` in the same session → `ce-work` |
| Bigger than one session | `wayfinder` → `to-spec` → `to-tickets` → a flow above per ticket |

`ce-work` already simplifies, reviews and cleans the PR text before opening the PR. For work done without it, `/ship` runs those steps.
