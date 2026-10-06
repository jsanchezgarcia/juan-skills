# Matching finishing evidence

Keep a small evidence record and logs in gitignored workspace context (for example `.context/finishing/`), or outside the repository when no ignored context directory exists. This is a record, not a new cache service. Missing or uncertain identity means rerun the affected check or widen review. Completion requires usable receipts, findings, input identities and check results; optional historical narratives or cost reports are separate follow-up work, not another finishing gate.

## Record actual inputs

| Evidence           | Record                                                                                                                                     |
| ------------------ | ------------------------------------------------------------------------------------------------------------------------------------------ |
| Review             | Goal, resolved base, reviewed tree/diff identity, completed receipt, covered scope and unresolved findings                                 |
| Local verification | Exact command, consumed source/configuration/fixtures, tool and relevant environment versions, generated artifact identity, result and log |
| Publication        | Repository, branch, PR, remote head, base, regular/draft state and `draft_requested` (`true`, `false` or `unknown`) with the source user instruction; record verification separately                                                                            |
| CI                 | Workflow/run, PR head, checked base/merge comparison and completed required job outcomes                                                   |

A clean HEAD is not a dirty tree. Record tracked edits and task-related untracked files with content identities, not just filenames or `git status`. Use a content manifest or tree/diff hash with separately hashed untracked inputs. Protect secrets: record relevant environment identities without exposing values.

Local generated artifacts are test inputs. Record the source/configuration that built them and their own content hash; do not rebuild them under running tests. Nondeterministic builds (including Theseus CLI's random build ID) can differ locally and in CI: match source/configuration identities, not cross-machine bundle bytes.

On resume, read saved publication intent alongside the current user instructions. Missing draft intent is `unknown`, not `false`. Preserve an existing draft with explicit or unknown intent unless the user explicitly authorizes conversion; save any new instruction that changes this intent.

## Reuse and invalidate

- Reuse a successful check only when its consumed inputs still match; starting another skill or a no-op simplification does not invalidate it.
- Changes to code, fixtures, lockfiles, runners or relevant environment invalidate checks that consume them. Widen conservatively when dependencies are uncertain. Pure documentation or PR-body edits do not by themselves invalidate an unchanged API run.
- A final gate covers its constituent suites. Do not run those suites again merely to collect separate receipts; retain the final command's actual log and scope.
- A fresh review receipt must cover the original diff and subsequent edits. Preserve earlier coverage only if it remains valid. Review deltas plus affected dependencies through a supported explicit scope; without that support, review the full diff. Architecture, security, contract changes and uncertain impact require wider coverage. Never fabricate a reduced-scope receipt or cap rounds.
- CI tests a comparison that may be a proposed merge tree, while the local gate usually tests the branch tree. Record both. Older heads, other stacked PRs and changed bases/comparisons are not interchangeable. If the comparison changes, require matching evidence for the new comparison; this never authorizes a rebase, merge commit or force-push.

## Merge-ready means all required evidence passed

Before reporting merge-ready, reread the published head and current comparison, confirm the local checked inputs match that publication, and inspect actual completed required CI jobs. No pending, cancelled, skipped-required or failed gate counts as passed. If the host does not expose a trustworthy comparison identity or required-check policy, do not invent it; resolve the missing evidence or report readiness blocked.

When resuming, retain completed stages and rerun only missing or invalidated evidence. A local-only handoff requires the repository's local gate and fresh review coverage, not fabricated remote CI. An authorized regular or draft PR may carry pending broad checks when repository policy permits publication before the final gate. Neither PR state proves merge readiness.
