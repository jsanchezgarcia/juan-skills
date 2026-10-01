---
name: visual-pr
description: Prepare a PR description or publish an authorized draft and finalize it after matching local and CI evidence passes. Use when asked to create, describe or update a PR; description-only requests do not authorize publication.
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
   - **Draft:** when publication is authorized and repository policy permits overlap, require completed simplification/review and passing quick/focused evidence, then publish with broad local/CI checks explicitly pending. Otherwise complete the required pre-publication gate first.
   - **Final:** update the same PR and mark ready only after completed review coverage, the repository's local final gate and current required CI pass for the relevant inputs/base/comparison. The caller owns running those checks; consume its matching evidence, do not restart them.
   - Check the current branch for a PR with `gh pr view --json url,number,title,state,isDraft,baseRefName,headRefName,headRefOid 2>/dev/null`.
   - If no PR exists, inspect `git status --short --branch` and the commits on the current branch.
   - Before any authorized publication, confirm the offered files and current branch. Preserve unrelated work and never publish from the default branch. Create a branch or commit only when authorized by the user; no implicit rebases, merges, force-pushes or deployments.
   - Commit only offered task-related changes when authorized, push with an upstream, and create a new PR with `gh pr create --draft` for the overlap path. Reuse an existing PR rather than creating a second one. Confirm its remote head and draft state after publication.
   - An existing ready PR is not silently converted to draft. Require conversion permission (`gh pr ready --undo`) or complete the local gate before pushing; do not report ready until matching current CI passes.
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
   - In **Evidence**, show the strongest available before/after proof. Prefer screenshots for visual changes and exact commands plus decisive output for behavior changes. State what passed, failed, was reused with matching inputs, or remains pending. A draft says which final local checks and CI are pending; do not imply readiness. Never claim evidence that was not executed.
   - In **Merge danger**, classify the change as a one-way or two-way door and state the concrete blast radius. Include the rollback constraint when it is not obvious.
   - If a ticket, task, plan, thread, or other relevant URL is known, include it in the header. Otherwise omit the header.
   - Check the finished text with `ce-noslop` in edit mode. It keeps the template's headings and code blocks.

5. Save and, when authorized, publish the description:
   - Save it to `${TMPDIR:-/tmp}/visual-pr/{repo}-pr-{number}.md`, outside the repository (use `draft` in place of the number for a local-only body).
   - In description-only mode without remote-update authority, stop at the saved body.
   - When remote body updates are authorized, update the PR with `gh api repos/{owner}/{repo}/pulls/{number} -X PATCH -F body=@{output-path}`. `gh pr edit --body` can fail silently.
   - Read the actual PR body back to confirm the update succeeded. In the final stage recheck head/base/comparison against the receipts before `gh pr ready`, then confirm `isDraft` is false. If evidence is incomplete, leave draft and report the missing evidence. Never merge automatically.
   - On authorized PR publication, when repository issue-tracker guidance defines a transition for an opened PR and the completing issue is known, apply that transition only after confirming the PR exists. A description-only request does not authorize an issue transition.

6. Report completion:
   - Read `{SKILLBASE}/references/describe_pr_final_answer.md`.
   - Respond using that final answer template with the PR URL (or local-only status), draft/ready state, local description path, changed files and actual evidence/pending checks.

Always read and follow `{SKILLBASE}/references/pr_description_template.md`. Do not expand the PR body beyond that template.

Write as one human talking to another: avoid jargon and slang, and use simple, coherent, concise language.
