# Batching Strategy Reference

Detailed rules for grouping tasks into parallel execution batches.

## Dependency Detection Rules

### Explicit Dependencies
Phrases that indicate dependency:
- "depends on Task N"
- "after Task N"
- "uses the X defined in Task N"
- "the block you modified in Task N"
- "the variable from Task N"

### Implicit Dependencies (Same File)

When two tasks modify the same file:

1. **Same line range** (overlapping edits) → must be sequential, same agent
2. **Same function** (different parts) → must be sequential, same agent
3. **Different sections** (>50 lines apart, no shared variables) → sequential but
   can be in same agent for efficiency
4. **Different functions, no shared state** → technically parallelizable with
   worktrees, but risky; prefer sequential in same agent

### Cross-File Independence

Tasks touching entirely different files are always parallelizable IF:
- No task depends on another task's output
- No shared build artifacts (e.g., generated files)
- The test suite can run with partial changes applied

### Test and Doc Tasks

Always schedule last:
- Test tasks validate code changes → depend on all code tasks
- Doc tasks (CHANGELOG, README) describe features → depend on the feature tasks
- These are often parallelizable with each other

## Batch Sizing

### Optimal Agent Scope

Each @executor agent should handle 2-5 tasks per dispatch:
- **Too few** (1 task): High overhead from agent spawn + file reading
- **Too many** (>5): Risk of context window pressure; harder to diagnose failures
- **Sweet spot**: 3-4 tasks touching the same file

### Model Selection Per Batch

| Batch Type | Recommended Model | Rationale |
|---|---|---|
| Code changes (medium+ complexity) | Sonnet | Good balance of capability and cost |
| Code changes (trivial: comments, versions) | Haiku | Cheap; trivial changes don't need reasoning |
| Test writing | Sonnet | Tests require understanding of the code under test |
| Documentation updates | Haiku | Templated work; low reasoning requirement |
| Verification | Haiku | Read-only checks; structured output |

### Parallelism Limits

- Maximum 3 parallel agents per batch (beyond this, coordination overhead dominates)
- Worktree isolation adds ~5s overhead per agent (git checkout + branch creation)
- If total task count ≤ 5, skip batching entirely — one agent handles everything

## Example Batch Plans

### Small Project (5 tasks, 2 files)

```
Batch 1: @executor(sonnet) — Tasks 1-3 (file A) + Tasks 4-5 (file B)
Batch 2: @verifier(haiku) — Final check
Total: 2 batches, 1+1 agents
```

### Medium Project (13 tasks, 4 files)

```
Batch 1 (parallel):
  @executor-a(sonnet, worktree) — Tasks 1-3 (statusline.py)
  @executor-b(sonnet, worktree) — Tasks 9-10 (install.py)
Batch 2:
  @executor-c(sonnet) — Tasks 4-8 (statusline.py, depends on Batch 1a)
Batch 3 (parallel):
  @executor-d(sonnet) — Task 11 (tests)
  @executor-e(haiku) — Task 12 (changelog)
Batch 4:
  @verifier(haiku) — Final verification
Total: 4 batches, 5+1 agents
```

### Large Project (25+ tasks, 8+ files)

Split into two pipeline runs:
1. Run 1: Core feature changes (tasks 1-15)
2. Run 2: Tests, docs, polish (tasks 16-25)

This avoids context window exhaustion in the orchestrator.

## Cost Formula

```
batch_cost = sum(
  agent_tokens × model_rate
  for each agent in batch
)

total_cost = sum(batch_cost for all batches) + orchestrator_overhead

orchestrator_overhead ≈ 2K tokens per batch (reading results, deciding next batch)
```

Typical overhead is 10-15% of total execution cost.
