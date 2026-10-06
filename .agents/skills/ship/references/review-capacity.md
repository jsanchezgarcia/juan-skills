# Review capacity recovery

This is a caller adapter for `ship`, not a fork of `ce-code-review`. CE owns scope,
depth, reviewer selection, model tiers, peer routing, validation and final reporting.
This adapter owns recovery when the host cannot launch another agent. It changes
the infrastructure-failure handoff only; it never removes a required reviewer or
turns missing coverage into approval.

## Caller contract: include in the fresh review prompt

Pass this reference's absolute path and the following contract alongside the goal,
repository and base. These are execution instructions, not implementation reasoning.

> Run the installed `ce-code-review` unchanged. Read the ship capacity adapter at
> the supplied path. Retain the run directory and exact prompts for selected work
> before dispatching it. Collect results and release completed agents when the host
> exposes a release operation. If a capacity rejection cannot recover by collecting
> active work or an actual release, return the adapter's blocked checkpoint. Do not
> repeat an unchanged rejected launch, substitute self-review, or start another
> review coordinator. A blocked checkpoint is an infrastructure handoff, not the
> CE review result. The caller will resume the missing steps.

Use native host tools. A finished or interrupted agent is not proof of a released
slot. Record available close/release capabilities and any observed limit; leave
the numeric limit unknown when the host does not expose it. Do not change runtime
configuration or interrupt unrelated agents to make space.

## Checkpoint the interrupted run

Record the run's UTC start before dispatch. As CE selects work, save its full
resolved prompts and selection decisions in the run directory. Preserve model and
effort bindings, standards mappings, scope, intent, plan and peer state. Paths may
carry large inputs, as CE allows; referenced files must accompany the checkpoint.
Store prompts before each launch and record its agent ID before launching more.

Before yielding, also persist judgments held only in the coordinator's context:
focused/lite correctness findings, full-path fast-pass candidates (including an
empty result), coverage notes and the current scope/finish-input state. Record
which judgments completed and which remain partial, with their original author
and evidence. Hash these artifacts separately from subagent terminal returns.
They remain merge inputs with CE's original confidence and independence rules;
never seed pending persona prompts with them. Recovery must consume completed
judgments rather than repeat or lose them; partial finish input is not ready for
a finishing leaf until CE's required fields and artifacts are complete.

On a capacity error, collect already-started workers within CE's existing bounds.
Release this run's collected workers if supported. Retry the rejected work once
only after an observed capacity change; otherwise hand it back immediately.
Apply CE's collection, peer reap and cleanup rules before handing off. If a worker
or peer remains live or its state is unknown, record it as such: the next owner
must reconcile it before launching a replacement. Preserve its receipt and cleanup
obligations, including any required adversarial fallback.

Write `capacity-checkpoint.json` atomically in the run directory, then return:

```json
{
  "status": "blocked",
  "reason": "agent_capacity",
  "checkpoint": "/absolute/run-dir/capacity-checkpoint.json"
}
```

The checkpoint contains these fields. Use explicit `null` for unavailable facts.

| Field | Content |
| --- | --- |
| `version` | `1` |
| `run_dir`, `repository`, `branch`, `started_at`, `checkpoint_at` | Absolute paths, branch and UTC timestamps. Retain the original start across recovery. |
| `invocation` | Original CE arguments and caller constraints; no additional apply, publication or model authority. |
| `inputs` | Resolved base SHA, head SHA, reviewed diff hash, hashes of included untracked inputs and applicable instructions/configuration. Follow `verification-evidence.md` for dependency identity. |
| `skill` | Loaded CE directory and content hashes of its instructions, scripts and prompt assets used by this run. |
| `selection` | Chosen depth, complete selected roster with reasons and model bindings, intent, plan, standards mappings, and peer decision. Persist CE's existing artifacts rather than reinterpreting them. |
| `artifacts` | Paths and content hashes of completed returns, scope files, saved prompts and existing finish artifacts. File existence alone is not a successful result. |
| `coordinator` | Paths and hashes of persisted correctness findings, fast-pass candidates, coverage notes and partial/complete finish-input state, each with author, evidence and completion state. An empty completed result differs from work not yet done. |
| `work` | Every selected reviewer and required finishing step: ID, kind, dependencies, state (`pending`, `running`, `complete`, `failed`), agent ID, prompt path, and result path when present. Deferred validator selection stays pending until synthesis selects it. |
| `peer` | CE's peer job identity, route, terminal outcome or live/unknown state, artifacts and outstanding cleanup. |
| `capacity` | Exact rejection, rejected work ID, dispatch context, known limit, release capability, observed capacity changes and attempts. |
| `recovery` | Direct-owner and fresh-session attempts, session IDs, and current dispatch owner. Record attempts before launch. |

Capture complete work only after validating its actual terminal return under CE's
contract. Preserve unsuccessful and malformed returns as failed work; capacity
rejections remain pending. Keep genuine review findings intact.

## Owner recovery

1. **Verify identity.** Read the checkpoint and compare the actual repository,
   reviewed inputs, skill and artifact contents with their recorded identities.
   Apply `verification-evidence.md` to changes and dependencies. Missing or altered
   evidence invalidates affected work; never silently reuse it. If the roster,
   scope or prompts cannot be recovered faithfully, report the missing evidence
   instead of inventing a reduced review. Retain valid completed work.
2. **Reconcile live work.** Collect or clean up recorded running/unknown jobs using
   their original handles and CE's bounds. Give dispatch ownership to one context
   only after the previous owner has yielded. Do not launch duplicate workers or
   peer jobs. Carry peer cleanup obligations through every handoff.
3. **Launch missing leaves directly.** The main agent dispatches pending reviewers
   from their saved prompts, in fresh contexts, using CE's model bindings and host
   capacity. Pass no implementation reasoning or sibling findings. These leaves
   launch no children. Collect and validate each result; release when supported.
   Persist progress after each terminal result. Never rerun a completed matching
   reviewer to recover a different missing reviewer.
4. **Finish through CE.** Once required reviewer outcomes and the peer fold-in are
   collected, follow the installed `references/finish-input.md`. Reuse matching
   completed finish input, synthesis, validator selection/verdicts and report
   artifacts. Dispatch only the next pending stage: independent merge, selected
   validators, then independent report. Preserve finding IDs and the selection
   that existing verdicts answer. Changed dependencies invalidate the affected
   stage and its downstream results; a capacity error alone invalidates none.
   If only reporting is pending, launch only the report leaf; if its completed
   receipt still matches, return it without another launch. CE's focused/lite
   paths retain their own finishing rules; use a fresh context for missing judgment.
   Forward CE's report verbatim. The implementing owner never substitutes its own
   synthesis or creates a successful review receipt.
5. **Escalate once if direct dispatch is exhausted.** Collect/release owned work
   first. If capacity still rejects dispatch without a recoverable change, use at
   most one fresh top-level host session, only when native session controls exist
   and a bounded foreground collector is available. Give it the checkpoint and
   read-only recovery instructions, the same reviewed checkout and all required
   artifacts; verify their identities there before resuming. It becomes the sole
   dispatch owner and receives no implementation reasoning. Respect CE's prohibition
   on detached, polled local review: launching a background CLI or Conductor session
   and polling it is not this fallback. If the host cannot provide the required
   collection or snapshot, retain the checkpoint and report the exact blocker.
   The fresh session may not recursively create another recovery session.

On an interrupted recovery, keep the same checkpoint and reconcile recorded jobs
before retrying. A non-capacity error follows CE's normal failure rules. A blocked
or degraded result never satisfies `ship`'s completed independent-review gate.

## Timing and compatibility

Keep recovery events in `capacity-events.jsonl`: UTC time, work ID, event, dispatch
context and observed outcome. Record launch rejection, collection, release, owner
handoff and resume. At completion, record the original start, finish and total wall
time separately from CE's stage-duration sum; overlapping stages and recovery gaps
make those different measures. Do not rewrite CE's cost fields or attribute every
gap to capacity. Optional timing analysis never delays a completed review.

After an upstream update, verify the dispatch, return and finish contracts this
adapter references. If they no longer match, stop recovery with a compatibility
blocker. Keep changes in this owned adapter; upstream CE files stay unmodified.
