# Code Enhancement Pipeline

Multi-agent plugin for orchestrating code enhancements. Opus plans, Sonnet executes, Haiku verifies — automatically coordinated through batched parallel execution.

## What It Does

Instead of one model doing everything, this plugin splits work across three specialized agents:

| Agent | Model | Role | Cost |
|---|---|---|---|
| **@planner** | Opus | Reads codebase, designs tasks, writes execution guide | $$$ (but only 10% of tokens) |
| **@executor** | Sonnet | Applies code changes, runs tests after each task | $$ (70% of tokens) |
| **@verifier** | Haiku | Runs verification suite, produces pass/fail reports | $ (20% of tokens) |

Typical savings: **40-60% cheaper** than using Opus for everything.

## Install

### Cowork (recommended)

Download the latest release and drag the `.plugin` file into Cowork. Or clone and point Cowork at the repo:

```bash
git clone https://github.com/YOUR_USERNAME/code-enhancement-pipeline.git
```

Then in Cowork: Settings → Plugins → Add from folder → select the cloned directory.

### Claude Code (manual skills only)

Copy the skill files as slash commands:

```bash
cp skills/*/SKILL.md ~/.claude/commands/
# Rename SKILL.md files to match their directory names
for d in skills/*/; do
  name=$(basename "$d")
  cp "$d/SKILL.md" ~/.claude/commands/$name.md"
done
```

This gives you the 5 skills as `/plan-execute`, `/task-batch`, etc. but without the agent orchestration or hooks — you invoke them manually.

### Build the .plugin file yourself

```bash
git clone https://github.com/dwaynerichards/code-enhancement-pipeline.git
cd code-enhancement-pipeline
make package
```

## Quick Start

1. Install the plugin in Cowork
2. Open a project and say: "I want to improve this codebase"
3. @planner analyzes and produces an execution guide
4. Say "execute" — @executor applies all changes with @verifier checking each batch
5. Review the final verification report

Or go step by step:
- `/cost-tracker estimate` — see what it'll cost before starting
- `/task-batch EXECUTION_GUIDE.md` — preview the parallel execution plan
- `/plan-execute EXECUTION_GUIDE.md` — run the full pipeline

## Components

### Agents (3)

- **@planner** (Opus, blue) — codebase analysis, task design, guide generation
- **@executor** (Sonnet, green) — code changes, test verification, failure recovery
- **@verifier** (Haiku, yellow) — test suite, per-task checks, constraint validation

### Skills (5)

| Skill | Trigger | What It Does |
|---|---|---|
| **plan-execute** | "execute the plan", "run the pipeline" | Orchestrates batched agent dispatch |
| **task-batch** | "batch these tasks", "what can run in parallel" | Dependency analysis and batch planning |
| **verify-and-report** | "verify everything", "check the changes" | Full verification with structured report |
| **execution-handoff** | "write the execution guide", "create handoff" | Converts planning into Sonnet-ready guide |
| **cost-tracker** | "how much will this cost", "budget check" | Token estimation and model recommendations |

### Hooks (2)

- **SessionStart** — prints available agents and skills
- **Stop (executor)** — after @executor finishes, suggests @verifier handoff

## Typical Flow

```
You: "Enhance this project with better error handling and ASCII fallback"
         │
    @planner (Opus) reads codebase
    @planner writes EXECUTION_GUIDE.md with 8 tasks
    @planner runs task-batch → identifies 3 parallel batches
         │
You: "Execute" (or it auto-proceeds)
         │
    Batch 1: @executor-a (file A) ║ @executor-b (file B)  ← parallel
    @verifier checks Batch 1 ✓
         │
    Batch 2: @executor-c (depends on Batch 1)
    @verifier checks Batch 2 ✓
         │
    Batch 3: @executor-d (tests) ║ @executor-e (docs)     ← parallel
    @verifier checks Batch 3 ✓
         │
    @verifier: final comprehensive report
         │
You: review, commit, done
```

## Configuration

No environment variables or API keys required. The plugin uses whatever models are available in your Cowork session.

The cost-tracker skill references pricing in `skills/cost-tracker/references/pricing.md` — update that file if Anthropic changes rates.

## Usage Tips

- **Start with `/cost-tracker estimate`** before any large enhancement to set expectations
- **Use `execution-handoff review`** to audit a guide before executing — catches stale line numbers
- **If execution fails mid-batch**, say "resume from task N" rather than restarting
- **For small changes (< 5 tasks)**, skip the pipeline and just ask @executor directly

## Project Structure

```
code-enhancement-pipeline/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── agents/
│   ├── planner.md               # Opus — codebase analysis, task design
│   ├── executor.md              # Sonnet — code changes, testing
│   └── verifier.md              # Haiku — verification, reports
├── skills/
│   ├── plan-execute/            # Orchestrates batched agent dispatch
│   │   ├── SKILL.md
│   │   └── references/
│   │       └── batching-strategy.md
│   ├── task-batch/              # Dependency analysis, parallel grouping
│   │   └── SKILL.md
│   ├── verify-and-report/       # Full verification with structured output
│   │   └── SKILL.md
│   ├── execution-handoff/       # Converts planning into execution guide
│   │   └── SKILL.md
│   └── cost-tracker/            # Token estimation, model recommendations
│       ├── SKILL.md
│       └── references/
│           └── pricing.md
├── hooks/
│   └── hooks.json               # SessionStart + post-executor handoff
├── Makefile                     # make package / make validate
├── LICENSE                      # MIT
└── README.md
```

## Contributing

PRs welcome. The main things to improve:

- Test the Stop hook matcher — `"matcher": "executor"` needs real Cowork testing
- Add more reference docs for edge cases in batching strategy
- Update `pricing.md` when Anthropic changes rates

## License

MIT
