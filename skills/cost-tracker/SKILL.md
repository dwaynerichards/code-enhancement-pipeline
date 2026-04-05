---
name: cost-tracker
description: >
  Estimate and monitor token spend across a multi-agent workflow. Use when
  the user asks "how much will this cost", "estimate the tokens",
  "compare model costs", "am I running out of context", "cost tracker",
  "budget check", or before starting a pipeline to decide model allocation.
metadata:
  version: "0.1.0"
---

# Cost Tracker

Estimate token cost for planned work, monitor session health, and recommend
optimal model allocation across Opus/Sonnet/Haiku.

## Modes

- **"estimate"** — estimate cost before executing
- **"status"** — check current session context usage
- **"compare" + description** — compare model costs for a specific task

## Pricing (update if changed)

See `references/pricing.md` for current rates and the golden ratio formula.

| Model  | Input/1M | Output/1M | Relative Cost |
|--------|----------|-----------|---------------|
| Opus   | $15.00   | $75.00    | 5x Sonnet     |
| Sonnet | $3.00    | $15.00    | 1x (baseline) |
| Haiku  | $0.25    | $1.25     | 0.08x Sonnet  |

## Estimate Mode

### Classify Tasks

For each task in the execution guide:

| Complexity | Tokens | Examples |
|---|---|---|
| Trivial | 3-5K | Comments, version strings, changelog |
| Low | 8-15K | Env var, CLI flag, doc update |
| Medium | 15-30K | New function, test, multi-site edit |
| High | 30-60K | Error handling, auth flow, refactor |
| Very High | 60-100K | New feature end-to-end |

### Calculate Costs

Show per-task cost across all three models, then recommend:

```
Recommended allocation:
  Planning:     Opus    (~$5)     — already done / 10% of work
  Execution:    Sonnet  (~$3.50)  — 70% of work
  Verification: Haiku   (~$0.05)  — 20% of work
  Review:       Opus    (~$2)     — final pass

  Total: ~$10.55 vs all-Opus: ~$22 (52% savings)
```

## Status Mode

Check session health:
- Context window usage percentage
- Estimated tokens consumed
- Remaining capacity
- Whether remaining tasks will fit

If capacity is tight:
```
⚠️ Context pressure: ~80K needed, ~40K remaining

Options:
1. End session with handoff, continue fresh
2. Switch remaining tasks to Haiku
3. Batch more aggressively
```

## Compare Mode

For a specific task description, show capability/cost tradeoff:

```
| Factor     | Opus        | Sonnet      | Haiku       |
|------------|-------------|-------------|-------------|
| Capability | ✓ Excellent | ✓ Good      | ⚠️ Risky    |
| Est. cost  | $3.15       | $0.72       | $0.08       |
| Risk       | Very low    | Low         | Medium-high |

Recommendation: Sonnet — [reason]
```

## The Golden Ratio

When in doubt, use this allocation:
- **Opus plans (10%)** — architectural thinking, dependency analysis
- **Sonnet executes (70%)** — code changes, test writing
- **Haiku verifies (20%)** — test runs, grep checks, constraint validation

This typically costs 40-60% less than all-Opus with minimal quality loss.
