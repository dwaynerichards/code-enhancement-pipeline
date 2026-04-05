---
name: execution-handoff
description: >
  Generate an EXECUTION_GUIDE.md from a planning session's output. Use when
  the user says "write the execution guide", "create the handoff",
  "generate the guide", "package the plan for Sonnet", or when @planner
  is ready to hand off to @executor. Also supports "review" mode to audit
  an existing guide for stale references.
metadata:
  version: "0.1.0"
---

# Execution Handoff

Convert planning session output into a structured EXECUTION_GUIDE.md that a
Sonnet-powered @executor agent can follow without ambiguity.

## Modes

- **Generate** (default) — create EXECUTION_GUIDE.md from current planning context
- **"review"** — audit an existing guide against the current codebase

## Generate Mode

### Step 1: Gather Context

Scan the conversation or planning output for:
- Tasks identified (enhancements, fixes)
- Files analyzed (with line numbers and function names)
- Constraints (from CLAUDE.md and conversation)
- Implementation order decided
- Edge cases and corrections

### Step 2: Validate References

For every code reference in a task:
1. Read the actual file at the referenced location
2. Confirm the line numbers still match
3. Confirm the Find block text is an exact, unique match in the file
4. If stale, update and flag: `> Note: Updated from planning session`

**Verification method**: For each Find block, grep the target file. Must return
exactly 1 match. If 0: the code changed. If >1: add more context to make it unique.

### Step 3: Write the Guide

Use this template structure:

```markdown
# Execution Guide — {Project} {Description}

> **For**: Sonnet-powered execution agent
> **Date**: {today}
> **Version**: {current version}

## How to Use This Guide
[Standard execution instructions]

## Project Map
| File | Role | Lines |
|---|---|---|

## Constraints (Non-Negotiable)
[Numbered list]

## Task N: {Title}

**Why**: {1-sentence rationale}
**File**: {path}, {location}

**Find**:
\```{language}
{exact current code — verified unique}
\```

**Replace with**:
\```{language}
{new code with comments}
\```

**Run** verification after this change.

## Final Verification
[All verification commands]

## What NOT to Do
[Anti-patterns for this project]
```

### Step 4: Quality Checks

Before writing:
1. Every Find block is unique in its target file (tested with grep)
2. Every Replace block is syntactically valid
3. Dependencies are respected in ordering
4. No task's Find block references pre-change code that a prior task already changed
5. Constraint list is complete (cross-reference CLAUDE.md)

### Step 5: Effort Estimate

Append to the guide:
```markdown
## Effort Estimate
| Metric          | Value |
|-----------------|-------|
| Tasks           | N     |
| Files modified  | M     |
| Est. complexity | Low/Med/High |
| Recommended     | Sonnet execute, Haiku verify |
```

### Step 6: Confirm

```
✓ Execution guide written to EXECUTION_GUIDE.md
  - {N} tasks across {M} files
  - All Find blocks verified unique
  - Ready for: plan-execute or @executor
```

## Review Mode

When called with "review":

1. Read existing EXECUTION_GUIDE.md
2. For each task's Find block, grep the target file
3. Flag stale references, ambiguous instructions, missing constraints
4. Output a review table:

```
| Task | Find Valid? | Syntax OK? | Deps OK? | Comments? |
|------|-------------|------------|----------|-----------|
| 1    | ✓           | ✓          | N/A      | ✓         |
| 2    | ✗ shifted   | ✓          | N/A      | ✓         |
```

Do NOT overwrite the file in review mode — report only.
