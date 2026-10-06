---
name: visual-pr
description: Prepare a PR description or publish an authorized regular PR and finalize its evidence after matching local and CI checks pass. Use when asked to create, describe or update a PR; description-only requests do not authorize publication.
metadata:
  credits:
    skill: show-me
    author: Dex Horthy
    organisation: Humanlayer
    url: 'https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md'
---

# Describe a Pull Request

Create or update the pull request for the current task with a concise description that helps a reviewer understand why the change exists, the shape of the implementation, the evidence that it works, and the risk of merging it.

## Workflow

1. Read the description template and [matching evidence rules](../ship/references/verification-evidence.md):

   `Read({SKILLBASE}/references/pr_description_template.md)`

2. Identify the stage and publication authority:
   - **Description only:** prepare the body locally. Updating an existing PR body needs authorization to update it; writing a description is not permission to commit, push or create a PR.
   - **Publish:** require publication authority, completed simplification/review, passing quick/focused evidence and any repository pre-publication gate. A user's `ship` request supplies authority for the task's branch, commit, push and regular PR; do not ask again. Default to a regular PR, with pending final checks stated explicitly. Publication state is separate from merge readiness.
   - **Draft:** use only when the user explicitly requests it; apply the same pre-publication requirements and preserve draft state until conversion is authorized.
   - **Final:** update the same PR's evidence and report merge-ready only after review, the repository's final gate and current required CI pass for the actual inputs/base/comparison. The caller runs the checks; consume matching evidence rather than restarting them. Finalization does not itself authorize draft conversion.
   - Check the current branch for a PR with `gh pr view --json url,number,title,state,isDraft,baseRefName,headRefName,headRefOid 2>/dev/null`.
   - If no PR exists, inspect `git status --short --branch` and the commits on the current branch.
   - Before any authorized publication, confirm the offered files and current branch. Preserve unrelated work and never publish from the default branch. Create a branch or commit only when authorized by the user; no implicit rebases, merges, force-pushes or deployments.
   - Commit only offered task-related changes, push with an upstream, and create a new regular PR with `gh pr create` without `--draft`. An explicit draft request adds `--draft`. Reuse an existing open PR rather than creating a second one; a closed/merged PR does not cover new work. Confirm its remote head and actual regular/draft state.
   - Read and record `draft_requested` under the matching evidence rules. A user's `ship` request authorizes converting an existing draft with `gh pr ready` after pre-publication requirements pass only when `draft_requested` is `false`, or the user explicitly authorizes conversion. Preserve explicit or unknown draft intent otherwise. Keep a regular PR regular while checks run or fail; convert it to draft only when the user requests that. State verification results separately and never report merge-ready while required checks are pending or failed.
   - Never include the generated PR description file in a commit or pull request.
   - Ask the user to select a PR only when the current branch has no relevant work and there is no safe current-branch PR to create.

3. Gather only the context needed to explain the change:
   - Read the ticket and any relevant task artifacts.
   - Account for the complete PR diff using the owner's completed context and matching review/evidence artifacts when available. Read the diff and surrounding source to fill gaps; a description update alone does not restart exploration or review.
   - Use `gh pr view` to collect PR metadata and changed files.
   - Read `{SKILLBASE}/references/show-me.md` for the visual-outline conventions used in the PR body.

4. Write the PR description using the template:
   - Keep **Why the change** to exactly one sentence.
   - Keep **Reviewer notes** to 1-3 bullets. Prioritize migrations, compatibility constraints, deliberate omissions, or surprising decisions. Write `- None.` when there are no special considerations.
   - Make **Change outline** a compact, `/show-me`-inspired structural view rather than prose or a file-by-file changelog.
   - Include only the views that help explain this PR:
     - SQL table and endpoint contract changes, plus pseudocode for business logic.
     - Key data structure or type changes.
     - A shallow file tree showing changed responsibilities.
     - React component tree changes, including important hooks, state, and package boundaries.
     - Call-tree, call-stack, control-flow, or data-flow changes.
   - Prefer `diff` blocks when showing changes to an existing shape. Show the complete target shape when most of it is new or diff notation would obscure ownership or order.
   - Keep each view focused on what a reviewer needs. Omit categories that did not change.
   - In **Evidence**, show the strongest available before/after proof. Prefer screenshots for visual changes and exact commands plus decisive output for behavior changes. State what passed, failed, was reused with matching inputs, or remains pending. Regular and draft PRs both name pending final checks; neither publication state proves merge readiness. Never claim evidence that was not executed.
   - In **Merge danger**, classify the change as a one-way or two-way door and state the concrete blast radius. Include the rollback constraint when it is not obvious.
   - If a ticket, task, plan, thread, or other relevant URL is known, include it in the header. Otherwise omit the header.
   - Check the finished text with `ce-noslop` in edit mode. It keeps the template's headings and code blocks.

5. Save and, when authorized, publish the description:
   - Save it to `${TMPDIR:-/tmp}/visual-pr/{repo}-pr-{number}.md`, outside the repository (use `draft` in place of the number for a local-only body).
   - In description-only mode without remote-update authority, stop at the saved body.
   - When remote body updates are authorized, update the PR with `gh api repos/{owner}/{repo}/pulls/{number} -X PATCH -F body=@{output-path}`. `gh pr edit --body` can fail silently.
   - Read the actual PR body back to confirm the update succeeded. Recheck head/base/comparison against the receipts and confirm the intended regular/draft state. Incomplete evidence leaves verification pending or failed, not merge-ready; it does not change PR state. Never merge automatically.
   - On authorized PR publication, when repository issue-tracker guidance defines a transition for an opened PR and the completing issue is known, apply that transition only after confirming the PR exists. A description-only request does not authorize an issue transition.

6. Report completion:
   - Read `{SKILLBASE}/references/describe_pr_final_answer.md`.
   - Respond using that final answer template with the PR URL (or local-only status), regular/draft state, local description path, changed files and separate verification/merge-readiness status.

Always read and follow `{SKILLBASE}/references/pr_description_template.md`. Do not expand the PR body beyond that template.

Write as one human talking to another: avoid jargon and slang, and use simple, coherent, concise language.
