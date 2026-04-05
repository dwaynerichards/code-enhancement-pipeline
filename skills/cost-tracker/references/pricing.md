# Model Pricing Reference

Current as of April 2026. Update this file when Anthropic changes pricing.

## Per-Token Rates

| Model | Input (per 1M tokens) | Output (per 1M tokens) | Cache Read (per 1M) |
|---|---|---|---|
| Claude Opus | $15.00 | $75.00 | $1.50 |
| Claude Sonnet | $3.00 | $15.00 | $0.30 |
| Claude Haiku | $0.25 | $1.25 | $0.025 |

## Cost Multipliers

Relative to Sonnet (baseline = 1x):

| Model | Input | Output |
|---|---|---|
| Opus | 5x | 5x |
| Sonnet | 1x | 1x |
| Haiku | 0.083x | 0.083x |

## Token Estimation by Task Type

These estimates include full cycle: reading the file (~40%), reasoning (~30%),
writing the edit (~20%), running verification (~10%).

| Task Type | Est. Input Tokens | Est. Output Tokens | Total |
|---|---|---|---|
| Add a comment block | 2K | 1K | 3K |
| Add an env var + config | 5K | 3K | 8K |
| Add a CLI flag | 6K | 4K | 10K |
| New helper function | 8K | 7K | 15K |
| Modify error handling | 12K | 8K | 20K |
| Add a test function | 10K | 10K | 20K |
| Restructure control flow | 20K | 15K | 35K |
| Multi-file refactor | 30K | 20K | 50K |
| New feature end-to-end | 50K | 40K | 90K |

## Session Budget Guidelines

| Session Type | Typical Token Budget | Est. Cost (Sonnet) |
|---|---|---|
| Quick fix (1-2 tasks) | 15-25K | $0.12 |
| Enhancement batch (5-8 tasks) | 60-100K | $0.60 |
| Major feature (10-15 tasks) | 120-200K | $1.50 |
| Full pipeline (plan+execute+verify) | 200-400K | $5-12 |

## Pipeline Cost Formula

```
total_cost = planning_cost + execution_cost + verification_cost + orchestration_overhead

planning_cost = opus_rate × planning_tokens
execution_cost = sonnet_rate × execution_tokens
verification_cost = haiku_rate × verification_tokens
orchestration_overhead = opus_rate × (2K tokens × number_of_batches)

typical_ratio:
  planning_tokens = 0.10 × total_tokens
  execution_tokens = 0.70 × total_tokens
  verification_tokens = 0.20 × total_tokens
```

## Savings Examples

| Scenario | All-Opus | Golden Ratio | Savings |
|---|---|---|---|
| 5 tasks, 80K tokens | $8.40 | $3.20 | 62% |
| 13 tasks, 200K tokens | $22.00 | $10.50 | 52% |
| 25 tasks, 400K tokens | $44.00 | $18.00 | 59% |
