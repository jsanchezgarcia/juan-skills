---
name: ship
description: Take changes made outside ce-work to an open PR. Simplifies, reviews and fixes, then commits, pushes and opens the PR.
disable-model-invocation: true
---

# Ship

Run the finishing steps `ce-work` runs after implementing, on work that was written without it. Arguments pass through: a base ref (default `origin/main`) and any `ce-commit-push-pr` options such as `babysit:off`.

<arguments> $ARGUMENTS </arguments>

1. **Scope.** The work is the current branch's diff against the base, plus uncommitted changes. If there is nothing, say so and stop. If the current branch is the default branch, create a branch named for the change before going on.
2. **Simplify.** Invoke `ce-simplify-code` on that scope. Done when its typecheck, lint and test run passes.
3. **Review.** Invoke `ce-code-review` with `mode:agent apply:local base:<base>`. Done when every actionable finding is applied or recorded as skipped with a reason. A finding that needs a product or design decision stops the run: put it to me and wait.
4. **Ship.** Invoke `ce-commit-push-pr` with the pass-through options.
5. **Report** the PR URL and every finding review left unapplied.
