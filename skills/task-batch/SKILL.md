---
name: task-batch
description: >
  Analyze a task list or execution guide for parallel execution opportunities.
  Use when the user says "analyze the tasks", "batch these tasks",
  "what can run in parallel", "optimize the execution order", or before
  running plan-execute to preview the batch plan.
metadata:
  version: "0.1.0"
---

# Task Batch Analyzer

Parse an execution guide, build a dependency graph, identify the critical path,
and output an optimal batch plan for parallel agent execution. This skill is
analysis only — it does not execute anything.

## Process

### Step 1: Extract Tasks

Read the execution guide and extract every numbered task. Record:
- **Task ID**
- **Files touched** (exact filenames from the guide)
- **Functions/line ranges modified**
- **Explicit dependencies** (look for "depends on", "after Task N", "uses X from Task N")
- **Implicit dependencies** (same function or overlapping line range as another task)

### Step 2: Build Dependency Graph

Create edges between dependent tasks:

```
1 → 4 (Task 4 uses ASCII_BARS defined in Task 1)
3 → 6 (Task 6 modifies the block Task 3 wrote)
7 → 8 (Task 8 wraps around Task 7's function)
```

Tasks with no incoming edges are "roots" — they can start immediately.

### Step 3: Identify Critical Path

The critical path is the longest chain of sequential dependencies.
This determines minimum wall-clock execution time.

Report:
```
Critical path: 1 → 4 → 5 → 6 → 8 (5 tasks, estimated 3-4 minutes)
Parallel track: 9 → 10 (2 tasks, runs alongside critical path)
Tail: 11, 12 (after all code tasks)
```

### Step 4: Generate Batch Plan

Group into batches following the rules in plan-execute/references/batching-strategy.md.

Output format:

```
## Batch Plan

### Batch 1 — Foundation (parallel)
| Agent | Model  | Isolation | Tasks   | Files         |
|-------|--------|-----------|---------|---------------|
| A     | sonnet | worktree  | 1, 2, 3 | statusline.py |
| B     | sonnet | worktree  | 9, 10   | install.py    |

### Batch 2 — Core (sequential)
| Agent | Model  | Isolation | Tasks       | Files         |
|-------|--------|-----------|-------------|---------------|
| C     | sonnet | none      | 4, 5, 6, 7  | statusline.py |

### Batch 3 — Complex (sequential)
| Agent | Model  | Isolation | Tasks | Files         |
|-------|--------|-----------|-------|---------------|
| D     | sonnet | none      | 8     | statusline.py |

### Batch 4 — Tests & Docs (parallel)
| Agent | Model  | Isolation | Tasks | Files          |
|-------|--------|-----------|-------|----------------|
| E     | sonnet | none      | 11    | smoke_test.py  |
| F     | haiku  | none      | 12    | CHANGELOG.md   |

### Batch 5 — Verify
| Agent | Model | Tasks             |
|-------|-------|-------------------|
| G     | haiku | full verification |

Total: 5 batches, 7 agents
Critical path: Batches 1→2→3→4→5
```

### Step 5: Cost Estimate

Classify each agent's work by complexity and estimate tokens:

| Complexity | Token Range | Examples |
|---|---|---|
| Trivial | 3K-5K | Comments, version strings, changelog |
| Low | 8K-15K | Add env var, CLI flag, doc table row |
| Medium | 15K-30K | New function, test, multi-site edit |
| High | 30K-60K | Error handling redesign, auth flow |

Show per-agent and total cost across Opus/Sonnet/Haiku.

### Step 6: Prompt

After presenting the plan:
> "Batch plan ready. Say 'execute' to run plan-execute, or adjust the batching."
