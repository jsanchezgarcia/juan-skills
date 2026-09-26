---
name: ship
description: Finish work that didn't go through ce-work, up to an open PR. Simplifies, reviews from a fresh context, fixes, then opens the PR with visual-pr. Use before opening a PR or calling work ready for review when those steps haven't run on it.
---

# Ship

Run the finishing steps `ce-work` runs after implementing, on work that was written without it. An argument can name the base ref (default `origin/main`).

<arguments> $ARGUMENTS </arguments>

1. **Scope.** The work is the current branch's diff against the base, plus uncommitted changes. If there is nothing, say so and stop. If the current branch is the default branch, create a branch named for the change before going on.
2. **Simplify.** Invoke `ce-simplify-code` on that scope. Done when its typecheck, lint and test run passes.
3. **Review in a fresh context.** Dispatch a subagent that knows only the goal (the ticket, spec or plan path, or two sentences stating what the change is for), the base, and the repository. It runs `ce-code-review` with `mode:agent base:<base>` and returns the receipt. Give it none of this session's implementation reasoning. Then apply its findings here. Done when every actionable finding is applied or recorded as skipped with a reason. A finding that needs a product or design decision stops the run: put it to me and wait.
4. **Ship.** Invoke `visual-pr`. It commits, pushes, opens or updates the PR, and writes the description. Give it the goal and the review's unapplied findings for the reviewer notes.
5. **Report** the PR URL and every finding review left unapplied.
