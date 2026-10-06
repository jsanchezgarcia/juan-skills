---
name: ship
description: Finish or resume a deliverable's missing simplification, independent review and final verification. A user request to ship authorizes committing, pushing and opening a regular PR through visual-pr without another confirmation.
---

# Ship

Own the finishing steps once per deliverable, not once per worker or invocation. An argument can name the base ref (default `origin/main`). Consume matching evidence from `ce-work`, an earlier `ship`, or the caller; do only the missing work. Read [verification evidence](references/verification-evidence.md) before reusing checks, narrowing review, publishing, or reporting merge-ready. Apply the caller's proportional-execution policy: do bounded work in this context, and delegate only for worthwhile parallel work, substantial isolated exploration or required independence. Collect and release completed workers where supported.

<arguments> $ARGUMENTS </arguments>

## Finish locally

1. **Scope and authority.** Identify the goal, repository, base and current branch, owned changes (including dirty and untracked files), earlier evidence, and existing PR state. Preserve unrelated work. A user request to ship, including invoking this skill, authorizes creating a task branch, committing owned changes, pushing and opening or updating a regular PR without further confirmation. An explicit local-only or draft request takes precedence. An automatic skill call after an implementation-only request inherits that request's authority; it does not grant itself publication permission. If there is nothing to finish, say so and stop. Use a task branch for PR publication; a direct push to the default branch, merge, rebase, force-push or deployment needs its own authorization.
2. **Focused proof.** Run or reuse quick/static diagnostics and behavior tests for the changed code, including user-visible UI proof when relevant. Workers return focused evidence; this agent owns broad gates and shared builds. Build a prerequisite only when its consumers need it and no matching artifact exists.
3. **Simplify if needed.** Invoke unchanged `ce-simplify-code` when at least 30 substantive human-authored code lines changed or the change's risk warrants it. Exclude documentation, fixtures, generated and mechanical churn from the threshold. Record a completed outcome or why it does not apply. Keep caller-owned inspection and repairs inline; invoking simplification alone does not justify additional discretionary workers. Preserve the skill's required stages. Consume unchanged-input checks instead of repeating the skill's generic verification; real edits invalidate affected checks and need focused proof.
4. **Independent review.** Read [review capacity recovery](references/review-capacity.md) before dispatch; include its caller contract with the goal, base and repository in the fresh review context. Never pass implementation reasoning. Run unchanged `ce-code-review` with `mode:agent base:<base>` and require a completed receipt. Use `depth:auto` by default; forward `depth:full` when explicitly requested. Preserve the skill's depth floors, reviewer selection and independence. If capacity interrupts the run, the adapter resumes only missing work through the owner; a checkpoint or self-review is not a completed receipt. Reuse only receipts that cover the current scope and inputs.
5. **Repair and close.** Batch justified fixes and add regressions. Independently cover the repairs and affected dependencies using a supported explicit delta scope; if the tool cannot express it safely, review the full current diff. Widen for architecture, security, contracts or uncertain impact. Follow the repository's review round limit when it sets one; otherwise do not impose one. Finish when review coverage includes every final edit and actionable findings are fixed or recorded unapplied with a reason; unresolved blockers prevent readiness. Ask for a genuine product/design decision rather than silently choosing.

## Choose the publication path

Where repository instructions make CI on the published head the final gate, that CI run stands in for the local final gate in every row and step below; run no local broad gate beside it.

Otherwise, complete the final local gate before publication unless repository policy explicitly permits publishing while that gate is pending. Silence does not permit early publication. Apply this timing rule to regular and draft PRs alike.

| Authority and PR state                             | Next action                                                                                                                |
| -------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------- |
| Local-only request or no publication authority     | Run/reuse the repository's final local gate, prepare a local `visual-pr` description, then hand off without remote changes |
| User requested ship; publication gates passed      | Follow the timing rule above; commit and push, open or update a regular PR through `visual-pr`, then complete any pending final gate and current-head CI |
| User explicitly requested a draft                  | Use `visual-pr`'s draft path and retain draft state until the user authorizes conversion                                    |
| Repository requires broad checks before any PR     | Complete its final local gate before publishing; do not override that requirement                                          |

For authorized publication:

1. **Freeze.** Confirm review closure, matching quick/focused proof, publication authority and the exact offered source inputs. Include relevant cheap migration checks before publication; retain any required post-commit migration check. Commit only offered task files. Never absorb unrelated work or infer permission to rebase, force-push or merge.
2. **Publish regular PR.** Invoke `visual-pr`'s publish stage with the user's ship authorization, goal, review receipt, unapplied findings, input identity and pending final checks. Create with `gh pr create` without `--draft`; reuse an existing open PR. Read and record draft intent under the evidence rules. Convert an existing draft with `gh pr ready` under this ship authorization only when `draft_requested` is `false`, or the user explicitly authorizes conversion. Preserve explicit or unknown draft intent otherwise. Confirm the remote head and intended regular/draft state. An explicit draft request uses the draft path instead. A feature-branch push alone may not trigger CI: inspect the workflow. Publish only after review repairs and required pre-publication gates settle.
3. **Verify.** Complete exactly the repository's final gate while collecting matching CI. Overlap local verification with CI only where repository policy permits it. Never rebuild shared artifacts or run competing broad gates. Regular PR state does not mean verification passed: name pending or failed checks in the body and report, keep the PR regular, repair failures, invalidate affected evidence and re-review behavior changes before pushing. Do not convert to draft without a user request.
4. **Merge readiness.** Recheck local inputs, published head, base/comparison and actual required CI outcomes. Finalize the description on the same PR only when review and required verification pass. Report merge-ready only then. Preserve an explicitly requested draft. No automatic merge or deployment.

**Report:** local handoff or PR URL and regular/draft state; simplify outcome, fresh review coverage, description, checks run/reused, and every unapplied finding. Report verification separately as pending, failed or passed. A regular PR with pending checks is not yet merge-ready.
