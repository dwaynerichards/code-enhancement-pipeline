---
name: verify-and-report
description: >
  Run comprehensive verification and produce a structured report. Use when
  the user says "verify everything", "check the changes", "run verification",
  "are the tests passing", "verify-and-report", or when @executor has
  finished a batch and needs confirmation before proceeding.
metadata:
  version: "0.1.0"
---

# Verify and Report

Run the project's full verification suite, per-task spot checks, and constraint
guards, then output a single structured pass/fail report.

## Modes

- **"all"** or no argument — full verification + per-task checks
- **"quick"** — test suite only, skip per-task checks
- **"tasks 3-8"** — only check specific tasks
- **"constraints"** — only check project constraints (stdlib, no crash, etc.)

## Process

### Step 1: Discover Test Infrastructure

Look for verification commands in this order:
1. `.claude/commands/verify.md` in the project
2. Test commands documented in CLAUDE.md
3. `Makefile` with `test` or `check` target
4. `package.json` `test` script
5. `tests/` directory with recognizable test files

### Step 2: Run Test Suite

Execute the discovered test command. Capture exit code, stdout, stderr, duration.

If tests fail, **stop and report immediately** — do not proceed to per-task checks.

### Step 3: Per-Task Validation

If EXECUTION_GUIDE.md exists, validate each task landed:
- Grep for the key change in the target file
- Confirm old code is replaced (not duplicated)
- Check that comments were added where specified

If `.claude/commands/check-task.md` exists in the project, use its task-specific
checks instead of generic greps.

### Step 4: Constraint Checks

Read CLAUDE.md for constraints. Common checks:
- **stdlib-only**: AST-parse imports, flag non-stdlib modules
- **no visible crash**: Run with empty/malformed input
- **settings preservation**: Verify installer doesn't clobber keys
- **cross-platform**: Check for platform-specific code without guards

### Step 5: Report

Output a structured markdown report:

```
## Verification Report

**Project**: {name}  |  **Time**: {timestamp}  |  **Guide**: {N} tasks

### Test Suite
| Check              | Result  | Duration |
|--------------------|---------|----------|
| {test suite name}  | ✓ PASS  | {time}   |

### Per-Task Checks
| #  | Task                 | Check                  | Result |
|----|----------------------|------------------------|--------|
| 1  | {name}               | {what was checked}     | ✓/✗    |

### Constraints
| Constraint    | Method         | Result |
|---------------|----------------|--------|
| {constraint}  | {how checked}  | ✓/✗    |

### Summary
✓ All passed ({N}/{N} tasks, {M}/{M} tests, {K}/{K} constraints)
```

On failure, add:
```
### Failures
1. {specific description with file:line}

### Recommended Action
{what to do — fix, escalate, or skip}
```

## Rules

- **Never modify code.** Report only.
- **Run every check.** Don't short-circuit on early success.
- **Be specific about failures.** File, line, expected vs actual.
- **Use tables.** Scannable > readable for verification output.
