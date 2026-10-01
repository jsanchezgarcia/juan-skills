---
name: ship
description: Finish or resume a deliverable's missing simplification, independent review and final verification. Use for work done outside ce-work or incomplete finishing; publish through visual-pr only when authorized.
---

# Ship

Own the finishing steps once per deliverable, not once per worker or invocation. An argument can name the base ref (default `origin/main`). Consume matching evidence from `ce-work`, an earlier `ship`, or the caller; do only the missing work. Read [verification evidence](references/verification-evidence.md) before reusing checks, narrowing review, publishing, or marking ready.

<arguments> $ARGUMENTS </arguments>

## Finish locally

1. **Scope and authority.** Identify the goal, repository, base and current branch, owned changes (including dirty and untracked files), earlier evidence, and existing PR state. Preserve unrelated work. If there is nothing to finish, say so and stop. Implementation permission alone is not publication permission. Do not create a branch or commit without authorization; never publish from the default branch. If publication needs a branch and that operation is not authorized, finish locally and report the missing permission.
2. **Focused proof.** Run or reuse quick/static diagnostics and behavior tests for the changed code, including user-visible UI proof when relevant. Workers return focused evidence; this agent owns broad gates and shared builds. Build a prerequisite only when its consumers need it and no matching artifact exists.
3. **Simplify if needed.** Invoke unchanged `ce-simplify-code` when at least 30 substantive human-authored code lines changed or the change's risk warrants it. Exclude documentation, fixtures, generated and mechanical churn from the threshold. Record a completed outcome or why it does not apply. Consume unchanged-input checks instead of repeating the skill's generic verification; real edits invalidate affected checks and need focused proof.
4. **Independent review.** Dispatch a fresh subagent with only the goal (ticket/spec/plan path or two sentences), base and repository, never implementation reasoning. It runs unchanged `ce-code-review` with `mode:agent base:<base>` at the depth the risks call for and returns a completed receipt. A launch acknowledgement or self-review is not a receipt. Reuse only receipts that cover the current scope and inputs.
5. **Repair and close.** Batch justified fixes and add regressions. Independently cover the repairs and affected dependencies using a supported explicit delta scope; if the tool cannot express it safely, review the full current diff. Widen for architecture, security, contracts or uncertain impact. Do not impose a round limit. Finish when review coverage includes every final edit and actionable findings are fixed or recorded unapplied with a reason; unresolved blockers prevent readiness. Ask for a genuine product/design decision rather than silently choosing.

## Choose the publication path

| Authority and PR state                             | Next action                                                                                                                |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| No publication permission                          | Run/reuse the repository's final local gate, prepare a local `visual-pr` description, then hand off without remote changes |
| Authorized new/draft PR, repository allows overlap | Freeze the reviewed and focused-tested snapshot, publish the draft, then start the final local gate while CI runs          |
| Existing ready PR, draft conversion not authorized | Complete the local final gate before pushing; then wait for current CI before reporting ready                              |
| Repository requires broad checks before any PR     | Complete its final local gate before publishing; do not override that requirement                                          |

For an overlap path:

1. **Freeze.** Confirm review closure, matching quick/focused proof, publication authority and the exact offered source inputs. Include relevant cheap migration checks before publication; retain any required post-commit migration check. Commit only offered task files when authorized. Never absorb unrelated work or infer permission to rebase, force-push or merge.
2. **Publish draft.** Invoke `visual-pr`'s draft stage with goal, review receipt, unapplied findings, input identity and pending final checks. Confirm the remote head and draft state. A feature-branch push alone may not trigger CI: check the repository's workflow. Drafts may start other integrations too; publish only after review repairs settle.
3. **Overlap.** Start exactly the repository's appropriate local final gate while collecting its matching CI run. Choose one coverage-complete command rather than chaining overlapping convenience commands. Never run another broad gate or rebuild its artifacts concurrently in this checkout. If either fails or remains pending, keep the PR draft, repair, invalidate affected evidence and re-review new edits before another authorized push.
4. **Ready.** Recheck local inputs, published head, base/comparison and the required CI job outcomes. Invoke `visual-pr`'s final stage on the same PR only when review, local verification and matching CI are complete and passing. No automatic merge or deployment.

**Report:** local handoff or PR URL and draft/ready state; simplify outcome, fresh review coverage, description, checks run/reused, and every unapplied finding. Distinguish pending, failed and passed evidence. Do not claim a draft is ready or invent CI evidence for a local-only handoff.
