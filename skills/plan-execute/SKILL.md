---
name: plan-execute
description: >
  Orchestrate multi-task code changes using batched subagents. Use when the
  user says "execute the plan", "run the execution guide", "apply all tasks",
  "start the pipeline", or when an EXECUTION_GUIDE.md is ready to be executed.
  Coordinates @planner, @executor, and @verifier agents automatically.
metadata:
  version: "0.1.0"
---

# Plan-Execute Orchestrator

Coordinate the full enhancement pipeline: parse the execution guide, batch tasks
for parallel execution, dispatch agents, and verify between batches.

## Trigger Conditions

- An EXECUTION_GUIDE.md exists in the project root
- The user says "execute", "run the plan", "start the pipeline"
- @planner has announced planning is complete

## Orchestration Flow

### Phase 0: Load

1. Read EXECUTION_GUIDE.md (or the file the user specified)
2. Extract all numbered tasks with their file targets and dependencies
3. Present a summary table and ask for confirmation:

```
Found 13 tasks across 4 files.
Batch plan: 4 batches, 2 parallelizable.
Estimated cost: ~$3.50 (Sonnet execution + Haiku verification)

Proceed? [Y/range like 3-8/adjust]
```

### Phase 1: Batch

Group tasks using dependency analysis (see `references/batching-strategy.md`):

- **Different files, no deps** → parallel batch (use worktree isolation)
- **Same file, sequential deps** → single agent, sequential execution
- **Tests/docs** → final batch after all code changes
- **Verification** → Haiku agent after each batch

### Phase 2: Dispatch

For each batch:

1. Spawn @executor agents (Sonnet) with task-specific prompts
2. Include: task instructions, constraints, verification command
3. For parallel batches, use worktree isolation
4. Wait for completion
5. Spawn @verifier (Haiku) to confirm the batch
6. Only proceed to next batch if verification passes

If any agent fails:
- Read the error output
- Attempt one retry with the error context included
- If retry fails, pause and report to the user

### Phase 3: Finalize

After all batches:
1. Spawn @verifier for final comprehensive check
2. Show completion summary with batch timings
3. Suggest next steps: code review, simplify, commit

## Subagent Prompt Template

When dispatching @executor, structure the prompt as:

```
Execute tasks [N-M] from EXECUTION_GUIDE.md.

Constraints:
[copy from guide]

After each task, run: [test command]

Report format:
Task N: ✓/✗ description
```

## Recovery

If a batch fails twice:
```
Pipeline paused at Batch N.
Completed: Tasks 1-{last successful}
Failed: Task {N} — {error}

Options:
1. Fix manually and say "resume from task N"
2. Say "skip task N" to continue
3. Say "abort" to stop
```
