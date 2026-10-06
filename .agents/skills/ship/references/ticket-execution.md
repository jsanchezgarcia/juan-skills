# Execute a ticket graph

Use this guide when implementing a spec split into dependent tickets. It borrows the ready-frontier scheduling from Matt Pocock's [implement-spec](https://github.com/mattpocock/skills/blob/v1.3.1/skills/engineering/implement-spec/SKILL.md), with `ce-work` for implementation and `ship` for finishing.

A **ready frontier** is the set of unfinished tickets whose dependencies have been integrated and verified. Tickets in that set can run together only when their files, shared contracts and runtime resources are independent.

| Step | Owner's action |
| --- | --- |
| Read the graph | Read the spec and the configured issue tracker's tickets, dependency links and completion rules. Map each ticket to its owned files, shared interfaces and focused verification. |
| Choose the frontier | Start with ready tickets. Keep small work inline. Delegate only when useful parallel work earns its overhead; serialize tickets that share contracts or resources. |
| Establish the baseline | Use harness-provided isolation or explicitly authorized worktrees when isolation is needed. Each worker verifies its checkout against the owner's exact intended commit before editing. A mismatch or a prerequisite present only in uncommitted changes returns to the owner for inline execution or a corrected baseline. |
| Implement | Give each worker a bounded brief and invoke `ce-work mode:return-to-caller <brief-path>`. Workers implement and return focused evidence; the owner controls integration, commits and further decomposition. |
| Integrate | Inspect each result, integrate in dependency order, verify the affected behavior and recompute the frontier. Check remaining results against the advancing tree; a clean merge alone does not prove compatibility. |
| Finish | After all tickets are integrated, run one `ship` flow over the complete deliverable. The owner handles simplification, fresh-context review, repairs, canonical builds and the repository's final gate. |

Shared checkouts use the `ce-work` shared-workspace contract: exclusive file ownership, no worker Git writes, and owner-run mutating verification after the wave. Workers never rebuild shared outputs while another test consumes them.

Follow the repository's issue-tracker transitions. A locally completed ticket does not automatically become Done; use its configured completion rule. A user request to ship supplies publication authority under `ship`; an implementation-only request does not. Authorized PRs use `visual-pr`, and workers never publish.

Recheck evaluation evidence against the actual integrated inputs. Parallel scheduling does not make results from an older recipe, fixture set, configuration or comparison reusable.
