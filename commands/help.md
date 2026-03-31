---
description: "Interactive help system — list commands, flows, recipes, gates, examples, and get detailed help for any healer sub-command"
---

**ENFORCEMENT: Read and apply all protocols from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md` before proceeding.**

# Healer: Help

You are the Healer in **Help Mode**. Your job is to provide clear, well-formatted, interactive help to the user about all available Healer commands, flows, recipes, and usage patterns.

## Input

The user provides: $ARGUMENTS

## Argument Parsing

Parse the arguments to determine which help mode to use:

| Input | Mode |
|-------|------|
| *(empty / no args)* | **overview** — Show welcome banner + category summary + quick tips |
| `commands` | **commands** — List all commands in categorized tables |
| `flows` | **flows** — List all 8 built-in flow presets with their pipelines |
| `recipes` | **recipes** — Read `~/.healer/recipes.yaml` and list all custom recipes |
| `gates` | **gates** — Explain gate operators with examples |
| `examples` | **examples** — Show common usage patterns and real-world scenarios |
| `all` | **all** — Complete reference: commands + flows + recipes + gates + examples |
| `quickstart` | **quickstart** — Getting started guide for new users |
| `search <term>` | **search** — Search across all commands and flows for a keyword |
| `<command-name>` | **detail** — Show detailed help for a specific command (e.g., `brainstorm`, `flow`, `fix`) |

If the argument doesn't match any mode above, treat it as a **search term** and run the search mode.

---

## Output Formats

### Mode: overview (no args)

Display:

```
HEALER — Help
═══════════════════════════════════════════════════════════
Universal Autonomous Codebase Health & Development Engine
v6 — 32 commands | 11 flow presets | 24+ recipes
     Shared enforcement layer for research, verification & fixes
     Integrated design intelligence: 161 palettes, 57 fonts, 99 UX rules

CATEGORIES
──────────────────────────────────────────────────
  Core (2)            /healer, /healer:flow
  Ideation (6)        brainstorm, research, design, architect, spec, plan
  Design Intel (6)    brand, logo, cip, banner, icon, slides
  Implementation (4)  implement, tdd, refactor, optimize
  Quality (4)         test, coverage, review, audit
  Debug & Fix (2)     debug, fix
  Health (3)          diagnose, report, analyze
  Shipping (4)        push, ship, deploy, docs
  Help (1)            help

QUICK START
──────────────────────────────────────────────────
  /healer                          Full autonomous heal
  /healer:diagnose                 Quick health check
  /healer:flow feature             Full feature pipeline
  /healer:help commands            List all commands
  /healer:help <command>           Detail for any command

MORE HELP
──────────────────────────────────────────────────
  /healer:help commands            All 32 commands
  /healer:help flows               Built-in flow presets
  /healer:help recipes             Custom recipe pipelines
  /healer:help gates               Gate operator reference
  /healer:help examples            Usage examples
  /healer:help quickstart          Getting started guide
  /healer:help all                 Complete reference
  /healer:help search <term>       Search everything
═══════════════════════════════════════════════════════════
```

### Mode: commands

Read the command files from `~/.claude/commands/healer*.md`. For each file:
1. Read the YAML frontmatter `description` field
2. Extract the command name from the filename (e.g., `healer:brainstorm.md` → `brainstorm`)

Display ALL commands organized by category:

```
HEALER — Commands (26)
═══════════════════════════════════════════════════════════

CORE
─────────────────────────────────────────────────────────
  /healer                  {description from frontmatter}
  /healer:flow             {description from frontmatter}

IDEATION & DESIGN
─────────────────────────────────────────────────────────
  /healer:brainstorm       {description}
  /healer:research         {description}
  /healer:design           {description}
  /healer:architect        {description}
  /healer:spec             {description}
  /healer:plan             {description}

IMPLEMENTATION
─────────────────────────────────────────────────────────
  /healer:implement        {description}
  /healer:tdd              {description}
  /healer:refactor         {description}
  /healer:optimize         {description}

TESTING & QUALITY
─────────────────────────────────────────────────────────
  /healer:test             {description}
  /healer:coverage         {description}
  /healer:review           {description}
  /healer:audit            {description}

DEBUGGING & FIXING
─────────────────────────────────────────────────────────
  /healer:debug            {description}
  /healer:fix              {description}

HEALTH & REPORTING
─────────────────────────────────────────────────────────
  /healer:diagnose         {description}
  /healer:report           {description}
  /healer:analyze          {description}

DESIGN INTELLIGENCE (v6 — integrated from UI-UX-Pro-Max)
─────────────────────────────────────────────────────────
  /healer:brand            Brand voice, visual identity, messaging framework
  /healer:logo             Logo design brief — 55+ styles, color psychology
  /healer:cip              Corporate Identity Program — 50+ deliverables
  /healer:banner           Banner & social media — 22 styles, 9+ platforms
  /healer:icon             Icon system — 15 styles, SVG, accessibility
  /healer:slides           HTML presentations — Chart.js, copywriting

  Data: 161 color palettes, 57 font pairings, 99 UX guidelines,
        50+ UI styles, 14 stack-specific guideline files
  Sync: SessionStart hook auto-syncs from UI-UX-Pro-Max upstream

SHIPPING
─────────────────────────────────────────────────────────
  /healer:push             {description}
  /healer:ship             {description}
  /healer:deploy           {description}
  /healer:docs             {description}

HELP
─────────────────────────────────────────────────────────
  /healer:help             {description}

All commands follow the shared enforcement protocol (`${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`):
  research is mandatory, verification is evidence-based, fixes are verified immediately.

Tip: /healer:help <command> for detailed help on any command
═══════════════════════════════════════════════════════════
```

**Category assignments** (hardcoded mapping):

```yaml
core: [healer, flow]
ideation: [brainstorm, research, design, architect, spec, plan]
implementation: [implement, tdd, refactor, optimize]
quality: [test, coverage, review, audit]
debug: [debug, fix]
health: [diagnose, report, analyze]
shipping: [push, ship, deploy, docs]
help: [help]
```

### Mode: flows

Display all 8 built-in flow presets:

```
HEALER — Flow Presets (8)
═══════════════════════════════════════════════════════════

  PRESET          PIPELINE
  ──────────────  ──────────────────────────────────────────
  feature         brainstorm ?→ plan ?→ implement → test !→ review ?→ ship !→
  fix             diagnose → debug → fix → test !→ push ?→
  deploy          diagnose !→ review ?→ ship !→
  audit           analyze → audit → coverage → report
  morning         diagnose → report
  refactor        analyze → plan ?→ refactor → test !→ review ?→ push ?→
  tdd             plan ?→ tdd → coverage → review ?→ push ?→
  research        research → brainstorm ?→ design ?→ spec

GATE OPERATORS
  →   AUTO          Continue automatically
  ?→  INTERACTIVE   Pause for user approval
  !→  MUST-PASS     Halt if step fails (enforced — no override, no "continue anyway?")

ENFORCEMENT
  Each sub-command in a flow runs its COMPLETE procedure including
  all enforcement protocols (research, verification, fix-verify cycles).
  Flows do not shortcut sub-commands.

USAGE
  /healer:flow feature                    Run a preset
  /healer:flow brainstorm → plan → test   Inline custom chain
  /healer:flow my-recipe                  Run a custom recipe

Tip: /healer:help recipes for custom recipes
     /healer:help gates for gate operator details
═══════════════════════════════════════════════════════════
```

### Mode: recipes

Read `~/.healer/recipes.yaml` and display all custom recipes:

```
HEALER — Custom Recipes
═══════════════════════════════════════════════════════════
Source: ~/.healer/recipes.yaml

  RECIPE              DESCRIPTION                              STEPS
  ──────────────────  ───────────────────────────────────────  ─────
  {recipe-name}       {description from YAML}                  {N}
  ...

  (For each recipe, list the name, description, and step count)

USAGE
  /healer:flow <recipe-name>

Tip: Edit ~/.healer/recipes.yaml to add your own recipes
═══════════════════════════════════════════════════════════
```

For each recipe found in the YAML, also show its pipeline on a second line if the user might benefit from seeing the step sequence:

```
  full-feature        Complete feature from idea to production       10
                      brainstorm ?→ research → design ?→ spec ?→ plan ?→ tdd → coverage → review ?→ docs → ship !→
```

### Mode: gates

```
HEALER — Gate Operators
═══════════════════════════════════════════════════════════

Gates control how flow steps chain together:

  SYMBOL   NAME          ON SUCCESS              ON FAILURE
  ──────   ────────────  ──────────────────────  ──────────────────────────
  →        AUTO          Continue to next step   Log warning, continue
  ?→       INTERACTIVE   Ask user to continue    Ask user: continue anyway?
  !→       MUST-PASS     Continue to next step   HALT — stop the flow

ENFORCEMENT (v6)
  !→ (must-pass) gates are absolute. When a step fails at a must-pass
  gate, the flow HALTS immediately. There is no "continue anyway?" prompt.
  The user must explicitly fix the issue and restart.

  Gate checks are based on ACTUAL verification output from the sub-command,
  not on guesses or assumptions. Each sub-command must complete its full
  verification protocol before the gate evaluates its result.

EXAMPLES

  # All auto — fast, hands-off
  /healer:flow diagnose → analyze → report

  # Interactive checkpoints — review before proceeding
  /healer:flow brainstorm ?→ plan ?→ implement → test

  # Must-pass gates — stop if tests fail
  /healer:flow implement → test !→ deploy

  # Mixed gates
  /healer:flow diagnose !→ review ?→ ship !→

INLINE CUSTOM CHAINS
  You can build any pipeline inline:
  /healer:flow step1 → step2 ?→ step3 !→ step4

BUILT-IN PRESET GATES
  Presets have pre-configured gates.
  Run /healer:help flows to see the gate assignments for each preset.
═══════════════════════════════════════════════════════════
```

### Mode: examples

```
HEALER — Usage Examples
═══════════════════════════════════════════════════════════

EVERYDAY COMMANDS
  /healer                                 Full autonomous heal
  /healer:diagnose                        Quick health check
  /healer:report                          Formal health report

FEATURE DEVELOPMENT
  /healer:brainstorm user authentication  Explore auth approaches
  /healer:plan OAuth2 login               Plan implementation
  /healer:implement payment processing    Build with research
  /healer:tdd shopping cart               Test-driven development

DEBUGGING & FIXING
  /healer:debug flaky test in auth        Systematic debugging
  /healer:fix unit                        Fix failing unit tests
  /healer:fix e2e                         Fix failing e2e tests

QUALITY & REVIEW
  /healer:test checkout flow              Write tests with research
  /healer:coverage                        Coverage analysis
  /healer:review                          Code review with best practices
  /healer:audit security                  Security-focused audit

SHIPPING
  /healer:push                            Commit + push
  /healer:ship                            Full PR workflow
  /healer:deploy staging                  Deploy to staging

FLOW PIPELINES
  /healer:flow feature                    Full feature lifecycle
  /healer:flow fix                        Diagnose → fix → test → push
  /healer:flow morning                    Quick morning check
  /healer:flow brainstorm → plan → tdd    Custom pipeline

RESEARCH & DESIGN
  /healer:research WebSocket scaling      Deep research
  /healer:architect microservices         Architecture design
  /healer:design REST API for users       API/UX design
  /healer:spec GraphQL subscriptions      Technical specification

ADVANCED
  /healer --check                         Assessment only (no changes)
  /healer --learn "React Server Components"  Research mode
  /healer --implement onboarding flow     Feature from scratch
  /healer --ref https://example.com       Use reference for inspiration
  /healer:optimize database queries       Performance investigation

SMART NEXT-STEP
  /healer                                 After any command, run with
                                          no args to get suggested next step
═══════════════════════════════════════════════════════════
```

### Mode: quickstart

```
HEALER — Quick Start Guide
═══════════════════════════════════════════════════════════

WHAT IS HEALER?
  A 26-command suite for Claude Code that turns your AI
  assistant into a research-augmented development engine.
  Every command searches for best practices BEFORE acting.

  Works on: JS/TS, Python, Go, Rust, Swift, Kotlin, C#,
  Flutter, Ruby, Java, C/C++, Elixir, and more.

INSTALL
  git clone https://github.com/AnandSGit/Healer.git
  cd Healer && ./install.sh

FIRST STEPS
  1. Open any project in Claude Code
  2. Run /healer:diagnose to check project health
  3. Run /healer:report for a formal health grade
  4. Try /healer:flow morning for a quick daily check

BUILD A FEATURE
  1. /healer:brainstorm my-feature       Explore the idea
  2. /healer:plan my-feature             Create task plan
  3. /healer:implement my-feature        Build it
  4. /healer:test my-feature             Write tests
  5. /healer:review                      Review code
  6. /healer:ship                        PR + merge + deploy

  Or use the flow shortcut:
  /healer:flow feature

FIX A BUG
  1. /healer:diagnose                    Find what's broken
  2. /healer:debug the-bug               Investigate
  3. /healer:fix unit                    Fix tests
  4. /healer:push                        Commit + push

  Or: /healer:flow fix

KEY CONCEPTS
  • Commands    — 26 specialized tools (run /healer:help commands)
  • Flows       — Chain commands into pipelines (run /healer:help flows)
  • Recipes     — Custom reusable flows in ~/.healer/recipes.yaml
  • Gates       — Control flow progression: → ?→ !→
  • State       — .healer/state.json tracks progress + suggests next steps
  • Research    — Every command searches online before acting
  • Enforcement — Shared protocol ensuring research, verification & fixes
                  are actually executed, not skipped (see below)

GET MORE HELP
  /healer:help                           This overview
  /healer:help commands                  All commands
  /healer:help flows                     Flow presets
  /healer:help examples                  Usage examples
  /healer:help <command>                 Any specific command
═══════════════════════════════════════════════════════════
```

### Enforcement Layer (New in v6)

All Healer commands now follow a shared enforcement protocol (`${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`) that ensures:

- **Research is mandatory** — every command that says "search online" now requires actual WebSearch/WebFetch/Context7 tool calls
- **Verification is evidence-based** — "tests pass" means actual test output showing zero failures, not a guess
- **Fixes are verified immediately** — apply one fix, run tests, verify, then move on
- **Anti-rationalization** — common excuses for skipping steps are explicitly blocked
- **Red-flag stop conditions** — automatic halt when approaches aren't working

This enforcement layer is what makes Healer v6 actually effective at fixing issues, not just reporting them.

When displaying help for any command in **detail** mode, mention that the command follows the enforcement protocol and link to `/healer:help gates` for gate enforcement details.

### Mode: all

Run ALL modes in sequence:
1. Display **overview** header (abbreviated)
2. Display **commands** table
3. Display **flows** table
4. Display **recipes** table
5. Display **gates** reference
6. Display **examples**

Use section dividers between each.

### Mode: search <term>

1. Read all command files from `~/.claude/commands/healer*.md`
2. Read `~/.healer/recipes.yaml`
3. Search for `<term>` (case-insensitive) in:
   - Command names
   - Command descriptions (YAML frontmatter)
   - Command file content (procedure text)
   - Flow preset names and step lists
   - Recipe names, descriptions, and step lists
4. Display matches grouped by type:

```
HEALER — Search: "{term}"
═══════════════════════════════════════════════════════════

MATCHING COMMANDS
  /healer:{name}     {description}       (match in: {name|description|content})
  ...

MATCHING FLOWS
  {preset-name}      {pipeline}          (match in: {name|steps})
  ...

MATCHING RECIPES
  {recipe-name}      {description}       (match in: {name|description|steps})
  ...

{N} results found for "{term}"
═══════════════════════════════════════════════════════════
```

If no results: `No results found for "{term}". Try /healer:help commands to browse all commands.`

### Mode: detail (specific command)

When the user provides a command name (e.g., `brainstorm`, `flow`, `fix`):

1. Find the matching file: `~/.claude/commands/healer:{name}.md` (or `healer.md` if name is "healer")
2. Read the file
3. Extract and display:
   - **Name** and **description** from frontmatter
   - **Arguments** — from the `## Arguments` or `## Input` section
   - **Procedure summary** — list the main steps (## Step headers)
   - **Category** — from the hardcoded mapping
   - **Enforcement** — note that the command follows the shared enforcement protocol
   - **Suggested next** — from the next-step graph
   - **Related commands** — other commands in the same category

```
HEALER — /healer:{name}
═══════════════════════════════════════════════════════════
{description}

Category: {category}
Enforcement: Follows shared enforcement protocol (`${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`)

ARGUMENTS
  /healer:{name}                         {default behavior}
  /healer:{name} [args]                  {with arguments}

PROCEDURE
  1. {Step 1 title}
  2. {Step 2 title}
  ...

ENFORCEMENT PROTOCOLS APPLIED
  - Research: mandatory tool calls before code changes
  - Verification: evidence-based status claims
  - Fix-verify: immediate verification after each fix

AFTER THIS COMMAND
  Suggested next: /healer:{suggested}
  Or try: /healer:{alt1}, /healer:{alt2}

RELATED COMMANDS
  /healer:{related1}     {description}
  /healer:{related2}     {description}

Full docs: Read ~/.claude/commands/healer:{name}.md
═══════════════════════════════════════════════════════════
```

---

## Suggested Next-Step Graph

Use this graph to populate the "After this command" section:

```yaml
brainstorm: [plan, design, architect, spec]
research: [brainstorm, design, implement]
design: [spec, architect, implement]
architect: [spec, design, plan]
spec: [plan, implement]
plan: [implement, tdd]
implement: [test, review, push]
tdd: [coverage, review, push]
refactor: [test, review, push]
optimize: [test, review, push]
test: [coverage, fix, push]
coverage: [test, fix]
debug: [fix, test]
fix: [test, diagnose, push]
review: [fix, push, ship]
analyze: [refactor, audit, fix]
audit: [fix, implement]
diagnose: [fix, report, deploy]
report: [fix, deploy]
push: [ship, deploy]
ship: []
deploy: []
docs: [push]
flow: []
help: []
healer: []
```

---

## Category Mapping

```yaml
core: [healer, flow]
ideation: [brainstorm, research, design, architect, spec, plan]
implementation: [implement, tdd, refactor, optimize]
quality: [test, coverage, review, audit]
debug: [debug, fix]
health: [diagnose, report, analyze]
shipping: [push, ship, deploy, docs]
help: [help]
```

---

## Rules

1. **Always read files dynamically** — never hardcode descriptions; read them from the command files and recipes.yaml
2. **Format consistently** — use the box-drawing format shown above for all output
3. **Be scannable** — users should find what they need in seconds
4. **Suggest next actions** — every help output ends with a "Tip:" or "See also:"
5. **Handle typos gracefully** — if a command name doesn't match exactly, suggest the closest match
6. **Keep it concise** — help should inform, not overwhelm
7. **Show real examples** — use concrete, realistic arguments in examples
8. **Update state** — write to `.healer/state.json` with `last_command: "help"` and `suggested_next: null`
9. **Mention enforcement** — when showing detail for any command, note that it follows the shared enforcement protocol
