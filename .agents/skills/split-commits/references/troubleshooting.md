# Split commits: troubleshooting

### Finding Coupling Does NOT Mean "Combine Everything"

**This is the most common mistake.** When you discover that schemas and services are coupled, the WRONG response is:

❌ "Schema and services are coupled → combine ALL backend changes into one commit"

The RIGHT response is to be SURGICAL:

✅ "Schema field X is used by Service Y → those specific pieces go together"

**Example of bad reasoning:**
```
"The schema changes break existing code because the tools field was removed.
The schema and service changes are tightly coupled - they can't be split.
Let me combine all backend changes into one commit."
```

**Example of good reasoning:**
```
"The tools field removal in SkillRecord breaks SkillService.getTools().
ONLY those two changes are coupled:
- SkillRecord.tools removal
- SkillService.getTools() removal/update

The OTHER schema changes (SkillVersion, SkillInstall) and OTHER service
methods are NOT coupled to this. They can still be separate commits."
```

**Ask these questions:**
1. What SPECIFIC change is breaking what SPECIFIC code?
2. Is that the ONLY coupling, or are there others?
3. Can I combine JUST those coupled pieces and keep the rest separate?

**The goal is the MINIMUM viable grouping, not the MAXIMUM convenient grouping.**

### Validation Fails Mid-Process

**DO NOT immediately bundle everything together.** Take time to understand the dependency and find the minimal fix.

When a commit fails validation:

1. **Identify exactly what's missing**
   ```
   Error: Cannot find name 'SkillVersion'
   ```
   → The type `SkillVersion` is defined in a later commit

2. **Understand the dependency relationship**
   - Is it a type/interface that this code needs?
   - Is it a function being called?
   - Is it an import that's missing?

3. **Choose the RIGHT fix (in order of preference):**

   **Option A: Reorder commits** (best if possible)
   - If Commit 3 depends on something from Commit 5, maybe Commit 5 should come first
   - Ask: "Does the new order still make logical sense?"
   - If yes, reorder and continue

   **Option B: Pull in ONLY the missing piece** (surgical fix)
   - If Commit 2 needs a type from Commit 4, pull JUST that type into Commit 2
   - Don't pull the entire file or all the types - just what's needed
   - Example: Add only the `SkillVersion` interface, not the entire schema file

   **Option C: Move the dependent code to a later commit**
   - If a small piece of Commit 2 depends on Commit 4, move that piece to Commit 4
   - Keep the rest of Commit 2 intact

   **Option D: Merge two specific commits** (targeted merge)
   - If Commits 2 and 4 are tightly coupled, merge JUST those two
   - Don't merge everything - keep other commits separate

   **Option E: Rethink the split** (not a last resort - often the RIGHT answer)
   - **Dependency issues are a signal, not just a problem to hack around**
   - If you're constantly pulling pieces from other commits, the boundaries are wrong
   - Step back and ask: "What grouping would have NO cross-dependencies?"
   - Often the answer is grouping by feature slice (vertical) instead of by layer (horizontal)

   Example of bad vs good grouping:
   ```
   BAD (causes dependency issues):
   1. All types/schemas
   2. All services
   3. All UI components
   → Services need types, UI needs services = constant dependency problems

   GOOD (self-contained):
   1. Feature A: types + service + UI for feature A
   2. Feature B: types + service + UI for feature B
   → Each commit is complete and independent
   ```

4. **Keep the split.** When a dependency problem appears, reorder commits or move the minimum code into the earlier commit; don't collapse commits to avoid the problem.

### Dependency Analysis Checklist

Before panicking, ask:

1. **What exactly is missing?** (specific type, function, constant)
2. **Where is it defined?** (which planned commit)
3. **Can that definition move earlier?** (reorder)
4. **Can just that definition be pulled in?** (surgical)
5. **Does this reveal a better grouping?** (rethink)

### File Has Interleaved Changes

When a file has changes that logically belong to different commits but are interleaved:
1. Determine if they can be separated
2. If not, assign entire file to the commit with the primary change
3. Document in COMMIT_PLAN.md why separation wasn't possible

### Final State Doesn't Match

If the final state differs from the original:
1. Run `git diff "$CURRENT_BRANCH"` to see what's different
2. Create a "fixup" commit with the missing changes
3. Consider if the original had unintended changes that should be excluded
