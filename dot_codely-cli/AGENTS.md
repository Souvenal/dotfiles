## Codely Added Memories — Rules

### ⚠️ MANDATORY: Auto-load Rules Before ANY Action

This is a **hard constraint**, not a guideline. Violation is equivalent to ignoring user instructions.

**Enforcement procedure** — for EVERY user message, the agent MUST:
1. **Scan** the message and current task context against each rule's triggers below.
2. **If ANY trigger matches**, `read_file` the corresponding rule file(s) **BEFORE** doing anything else — before activating skills, before exploring the codebase, before generating any response.
3. **Only after** all matched rule files are fully read and their constraints internalized, proceed with the task.

In other words: **Rule reading is step zero.** No action may precede it when a trigger is hit.

---

### `~/.codely-cli/rules/git-workflow.md`
**Description**: Enforces strict git safety — never auto-commit or auto-push; all changes must be manually committed only after user review.  
**Auto-load triggers**: `git commit`, `git push`, committing changes, pushing code, version control operations, finishing a branch, merging, PR creation.

### `~/.codely-cli/rules/harness.md`
**Description**: Defines the full development harness & superpowers integration workflow — red flags (never modify files without approval, never code before plan approval), file hierarchy (AGENTS.md / AGENTS.local.md / docs/plans/), and mandatory skill-based stages (brainstorming → writing-plans → executing-plans → code-review → finishing-branch).  
**Auto-load triggers**: new feature request, implementation plan, brainstorming, task breakdown, plan execution, code review, finishing a branch, superpowers skills, AGENTS.local.md, docs/plans/.

### `~/.codely-cli/rules/explore-first.md`
**Description**: Requires exploring local source code first and using Context7 MCP as a strong auxiliary tool before writing any code. Local code is the single source of truth; Context7 enriches understanding of concepts, best practices, and idiomatic patterns. Mandates traceability annotations on all code written.  
**Auto-load triggers**: C/C++ files (`*.{h,hpp,c,cpp}`), writing new code, reusing existing code, consulting documentation, library usage patterns, API signatures, code annotations, Context7.
