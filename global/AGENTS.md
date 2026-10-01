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
- PR titles say what changed and why. PR descriptions follow `visual-pr`'s template, in plain language a person would write.
- In docs, use simple markdown tables where a diagram is tempting.

`~/vault/` holds my personal notes; write there only when I ask.

## Skills

Pocock's skills settle what to build and record it in Linear; CE skills build and ship it.

| Work                        | Flow                                                                                                      |
| --------------------------- | --------------------------------------------------------------------------------------------------------- |
| Small, clear                | `ce-work mode:return-to-caller` → `ship` → `ce-resolve-pr-feedback` (unknown bug cause: `ce-debug` first) |
| One session, open decisions | `grilling` → `to-spec` in the same session → the small, clear flow                                        |
| Bigger than one session     | `wayfinder` → `to-spec` → `to-tickets` → a flow above per ticket                                          |

Open and describe every PR with `visual-pr`, including work built with `ce-work`, in place of `ce-commit-push-pr`. `ship` finishes work done outside `ce-work` and resumes missing finishing steps without repeating valid evidence.

`ce-work`'s return-to-caller mode requires a real plan/spec path, for example `ce-work mode:return-to-caller docs/plans/fix.md`. If a clear bare request has no such file, save a short execution brief naming the goal, owned scope and focused verification in gitignored workspace context (or a temporary directory). Do not add a planning interview or require a full plan template. Pass that path; workers receive a bounded brief from the owner. Never pass a bare prompt after the mode token.

### Finish once per deliverable

- The main implementing agent owns final simplification, independent review, canonical builds, broad local verification and authorized publication. Invoke `ce-work mode:return-to-caller` for implementation, then resume `ship` in the same session; this avoids standalone `ce-work`'s pre-review broad-test tail. Workers also use that mode but return focused evidence to the owner, never invoke `ship`. Reviewers run targeted reproductions, not competing broad gates. Do not rebuild shared artifacts underneath running tests.
- Broad gates wait until implementation, simplification and independent review repairs settle. For authorized overlap where repository policy permits it, publish the reviewed draft before the final gate. Run focused behavior checks during implementation and after repairs instead of a broad gate for each unit or finishing substep. If a caller explicitly selects standalone `ce-work`, apply this scheduling policy to its generic verification steps and reuse its matching finishing receipts.
- Repository instructions define required final coverage. These personal scheduling rules override generic duplicated verification in called skills, not required coverage or review criteria: consume recorded successful evidence when its actual source/configuration, environment and artifact inputs still match. Without matching evidence, run the required check. A no-op simplify pass does not invalidate checks.
- Simplify settled code when at least 30 substantive human-authored code lines changed, or a smaller risky change warrants it; documentation, fixtures, generated files and mechanical edits alone do not trigger it. Record the outcome or why it was not applicable. Preserve valid simplification and review receipts on resume.
- Before final handoff, independently review the final work and all repairs, and complete the repository's local final gate. Review a repair delta and its dependencies only when the review tool can represent that scope safely; widen for architecture, security, contracts or uncertain impact. No review-count cap or fabricated receipt. Treat findings as proper fix requests; record any unapplied finding and its reason.
- "Handle this" or "implement that" includes local finishing, not permission to commit, push or open a PR. Publication needs explicit authorization. When authorized and the repository permits it, `ship` publishes a reviewed, focused-tested draft, then runs the required local final gate while CI runs. A draft means verification is pending; ready requires successful local evidence and current-head CI for the relevant base/comparison. Without permission, finish locally. Never silently turn an existing ready PR into a draft.
- When reporting ready, list simplification, fresh-context review and the `visual-pr` description, what each changed, checks actually run or reused, and unapplied findings. Use `ship`'s evidence rules when resuming finishing or deciding whether a check or review still applies.

Review work written in this session from a fresh context: whenever `ce-code-review` runs on it, including inside `ce-work`, run it in a subagent that gets only the goal (ticket, spec or plan path, or two sentences on what the change is for), the base branch and the repository, never the implementation reasoning. The subagent returns the review receipt; apply the findings in the implementing thread.
