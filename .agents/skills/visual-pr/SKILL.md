---
name: visual-pr
description: Creates or updates a pull request with a visual change outline, execution evidence, and merge-risk assessment. Use when asked to create, describe, or update a PR, or when explicitly invoked as visual-pr.
metadata:
  credits:
    skill: show-me
    author: Dex Horthy
    organisation: Humanlayer
    url: "https://github.com/humanlayer/skills/blob/main/plugins/show-me/skills/show-me/SKILL.md"
---

# Describe a Pull Request

Create or update the pull request for the current task with a concise description that helps a reviewer understand why the change exists, the shape of the implementation, the evidence that it works, and the risk of merging it.

## Workflow

1. Read the description template:

   `Read({SKILLBASE}/references/pr_description_template.md)`

2. Identify or create the pull request:
   - Check the current branch for a PR with `gh pr view --json url,number,title,state,baseRefName,headRefName 2>/dev/null`.
   - If no PR exists, inspect `git status --short --branch` and the commits on the current branch.
   - Commit task-related changes when needed, push the branch with an upstream, and create a PR for it. Follow the repository's git safety protocol.
   - Never include the generated PR description file in a commit or pull request.
   - Ask the user to select a PR only when the current branch has no relevant work and there is no safe current-branch PR to create.

3. Gather only the context needed to explain the change:
   - Read the ticket and any relevant task artifacts.
   - Read the complete PR diff and enough surrounding code to understand behavior and ownership.
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
   - In **Evidence**, show the strongest available before/after proof. Prefer screenshots for visual changes and exact commands plus decisive output for behavior changes. Never claim evidence that was not executed.
   - In **Merge danger**, classify the change as a one-way or two-way door and state the concrete blast radius. Include the rollback constraint when it is not obvious.
   - If a ticket, task, plan, thread, or other relevant URL is known, include it in the header. Otherwise omit the header.
   - Check the finished text with `ce-noslop` in edit mode. It keeps the template's headings and code blocks.

5. Save and publish the description:
   - Save it to `${TMPDIR:-/tmp}/visual-pr/{repo}-pr-{number}.md`, outside the repository.
   - Update the PR with `gh api repos/{owner}/{repo}/pulls/{number} -X PATCH -F body=@{output-path}`. `gh pr edit --body` can fail silently.
   - Confirm the update succeeded.
   - When repository issue-tracker guidance defines a transition for an opened PR and the completing issue is known, apply that transition only after confirming the PR exists.

6. Report completion:
   - Read `{SKILLBASE}/references/describe_pr_final_answer.md`.
   - Respond using that final answer template with the PR URL, local description path, and concise list of changed files.

Always read and follow `{SKILLBASE}/references/pr_description_template.md`. Do not expand the PR body beyond that template.

Write as one human talking to another: avoid jargon and slang, and use simple, coherent, concise language.
