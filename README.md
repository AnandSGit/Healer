# Healer v9.0

**Universal Autonomous Codebase Health & Development Engine with Design Intelligence**

44 commands | 27 flow presets | 36+ recipes | Karpathy enforcement | Postfix `?` discoverability | Self-validating command catalog | Shared enforcement protocol | Integrated UI/UX design databases | Any project, any language, any platform

---

## What is Healer?

Healer is a comprehensive command suite for [Claude Code](https://claude.ai/code) that turns your AI assistant into a research-augmented development lifecycle engine. Every command searches for best practices, patterns, and proven solutions **before** acting.

### What's New in v9.0: Karpathy Principles Integration

v9 integrates [Andrej Karpathy's coding principles](https://github.com/forrestchang/andrej-karpathy-skills) directly into Healer's enforcement layer — upgrading them from passive CLAUDE.md suggestions to actively enforced HARD-GATEs:

- **`/healer:karpathy`** — focused code review against 4 Karpathy principles with dual per-principle + per-file report format
- **Simplicity Protocol (P2)** — HARD-GATE preventing over-engineering, speculative features, and single-use abstractions. Self-scoped: only activates when commands write source code.
- **Surgical Changes Protocol (P3)** — HARD-GATE enforcing minimal diffs with traceback test: "Every changed line traces to the user's request." Self-scoped.
- **P1 enhancement** — Research Protocol now requires surfacing tradeoffs and pushing back when simpler approaches exist
- **P4 coverage** — already enforced by Healer's Verification and Fix Verification Protocols since v4
- **5 anti-rationalization entries** + **3 red-flag stop conditions** targeting over-engineering patterns
- **Flow presets**: `karpathy-review`, `karpathy-fix`
- See [docs/designs/2026-04-15-karpathy-integration.md](docs/designs/2026-04-15-karpathy-integration.md) for design rationale and [CHANGELOG.md](CHANGELOG.md) for full details.

### What's New in v7.1: Postfix `?` Help + Self-Validating Catalog

- **`?` postfix discoverability** — type `/healer:<command> ?` (or `--help`) on ANY healer command for an instant six-section drill-down (purpose, what it does, expected input, concrete example with trace, input purpose, after/related). Works on flow presets too: `/healer:flow feature ?`.
- **Sub-50ms help latency** — pre-built `data/help-index.json` replaces the old slow path that scanned all 41 command files (~14k lines) per invocation.
- **Self-validating command catalog** — `data/commands.yaml` and `data/flows.yaml` (JSON-Schema-validated) are the single source of truth. A PostToolUse hook auto-rebuilds the index on every catalog/command edit and detects drift loudly.
- **One-source documentation** — README, HTML user guide, and help system all derive from the same YAML catalog (auto-generated marker sections, in progress).
- See [docs/designs/2026-04-11-postfix-help-and-catalog.md](docs/designs/2026-04-11-postfix-help-and-catalog.md) for design rationale and [docs/plans/2026-04-11-postfix-help-and-catalog.md](docs/plans/2026-04-11-postfix-help-and-catalog.md) for the implementation plan.

### What's New in v6: Design Intelligence Integration

v6 integrates [UI-UX-Pro-Max](https://github.com/NextLevelBuilder/ui-ux-pro-max-skill) (MIT License) design intelligence into Healer, adding:

- **6 new commands**: `brand`, `logo`, `cip`, `banner`, `icon`, `slides`
- **5 enhanced commands**: `design`, `design-system`, `design-review`, `implement`, `audit` now query local design databases before web research
- **Design data layer**: 161 color palettes, 57 font pairings, 99 UX guidelines, 50+ UI styles, 14 stack-specific guideline files
- **BM25 search engine**: Python-based search across all design databases
- **Auto-sync**: SessionStart hook keeps design data fresh from upstream
- **New flow presets**: `identity`, `visual`, `brand-to-prod` + 4 new recipes

Design intelligence is the DATA LAYER. Healer's enforcement protocol is the PROCESS LAYER. Together they produce research-backed design that avoids AI slop.

### v4 Foundation: Enforcement Protocol

v4 introduces a **shared enforcement layer** (`_enforcement.md`) that makes all commands actually effective:

- **HARD-GATEs** — absolute blockers that prevent skipping research, verification, or testing
- **Explicit tool calls** — every "search online" instruction now specifies exact tools (WebSearch, WebFetch, Context7 MCP)
- **Evidence-before-claims** — every "tests pass" claim requires actual command output, not assumptions
- **Fix-verify cycles** — apply one fix, run tests, verify, then move on (no batching)
- **Anti-rationalization tables** — blocks common excuses like "I already know how to fix this"
- **Red-flag stop conditions** — automatic halt when approaches aren't working (3+ failed fixes = stop and reassess)

This enforcement layer is what separates Healer v4 from tools that just *describe* best practices — Healer v4 **enforces** them.

It works on **any project** — JavaScript/TypeScript, Python, Go, Rust, Swift, Kotlin, C#, Flutter, Ruby, Java, C/C++, and more. Stack detection is automatic.

## Quick Start

### Install

```bash
# Clone the repo
git clone https://github.com/AnandSGit/Healer.git

# Run the install script
cd Healer && ./install.sh
```

### Discoverability — `?` and `--help`

Append `?` (or `--help`) to any healer command for instant help:

```bash
/healer:flow ?              # Flow overview + all 26 presets
/healer:flow feature ?      # Six-section drill-down for the feature preset
/healer:brainstorm ?        # Drill-down for brainstorm command
/healer:flow my-recipe ?    # Drill-down for a user recipe in ~/.healer/recipes.yaml
```

Resolution rules: `?` triggers help only as a standalone token. Topics containing `?` mid-string (e.g., `/healer:debug "why is this ?"`) pass through as literal input.

### Or install manually

```bash
# Copy commands to Claude Code global commands
cp commands/healer*.md ~/.claude/commands/

# Copy config
mkdir -p ~/.healer
cp config/recipes.yaml ~/.healer/

# Copy docs
cp docs/healer-user-guide.html ~/.healer/
```

### Use

```bash
# In any Claude Code session:
/healer                    # Full autonomous heal
/healer:diagnose           # Health check
/healer:flow feature       # Full feature pipeline
```

## Commands

> **Auto-generated from `data/commands.yaml`.** Do not edit content between the marker comments — it's overwritten by `scripts/generate_readme.py` (run automatically via the help-catalog hook on every YAML edit).

<!-- HEALER:COMMANDS:START -->
### Core

| Command | Description |
|---------|-------------|
| `/healer:flow` | Flow orchestrator — chains multiple healer sub-commands into pipelines |
| `/healer` | Full autonomous codebase engine — discover, understand, assess, |

### Ideation & Strategy

| Command | Description |
|---------|-------------|
| `/healer:architect` | Research-augmented system architecture — service boundaries, |
| `/healer:brainstorm` | Interactive Socratic brainstorming — explores requirements through |
| `/healer:design` | Research-augmented feature design — APIs, data models, UX flows, |
| `/healer:plan` | Research-augmented implementation planning — creates bite-sized task |
| `/healer:research` | Deep research on a topic, technology, market, or approach — fetches |
| `/healer:spec` | Write detailed technical specifications — with acceptance tests, API |
| `/healer:strategy` | CEO-level strategic review — evaluates plans and designs for scope |
| `/healer:validate` | Demand validation diagnostic — challenges whether the idea is worth |

### Design Intelligence

| Command | Description |
|---------|-------------|
| `/healer:banner` | Banner and social media design — 22 banner styles, 9+ social platforms, |
| `/healer:brand` | Brand framework generator — creates brand voice, visual identity |
| `/healer:cip` | Corporate Identity Program — 50+ deliverables checklist, mockup |
| `/healer:design-review` | Visual and UX quality review — rates 7 design dimensions (0-10), |
| `/healer:design-system` | Design system generator — creates complete visual identity from |
| `/healer:icon` | Icon system design — 15 icon styles, SVG generation guidance, icon |
| `/healer:logo` | Logo design guidance — 55+ logo styles, color psychology, industry |
| `/healer:slides` | Presentation design — HTML slide decks with Chart.js data |

### Implementation

| Command | Description |
|---------|-------------|
| `/healer:implement` | Research-augmented implementation — builds features by searching |
| `/healer:optimize` | Research-augmented performance investigation — 10-phase structured |
| `/healer:refactor` | Research-augmented refactoring — improves code structure, readability, |
| `/healer:tdd` | Test-driven development — write failing tests first, then implement |

### Testing & Quality

| Command | Description |
|---------|-------------|
| `/healer:audit` | Research-augmented security and quality audit — scans for OWASP top |
| `/healer:catchup` | Full-pipeline gap analysis and auto-fix — reads ALL project artifacts |
| `/healer:conform` | Design conformance gate — reads approved design docs before and after |
| `/healer:coverage` | Test coverage analysis — identifies untested critical paths, measures |
| `/healer:karpathy` | Karpathy-lens code review — checks recent changes against the four |
| `/healer:review` | Research-augmented code review — reviews recent changes for bugs, |
| `/healer:test` | Research-augmented test writing — searches for testing patterns, |
| `/healer:verify` | Requirement-driven autonomous verification engine — reads all specs, |

### Debugging & Fixing

| Command | Description |
|---------|-------------|
| `/healer:debug` | Systematic debugging — structured troubleshooting with reproducible |
| `/healer:fix` | Research-augmented targeted fix — runs a specific test suite, |

### Health & Reporting

| Command | Description |
|---------|-------------|
| `/healer:analyze` | Analyze codebase health — patterns, tech debt, dependencies, and |
| `/healer:diagnose` | Read-only health check — runs all test suites sequentially, compares |
| `/healer:report` | Comprehensive status report generator — runs all test suites and |

### Recording & Flow Testing

| Command | Description |
|---------|-------------|
| `/healer:adapt` | Style DNA consumer and replicator — takes the Style DNA YAML produced |
| `/healer:imitate` | Reverse-engineer a specific layer (frontend, backend, server, db, ai) — |
| `/healer:indulge` | Imitate-driven exhaustive flow testing engine — parses /healer:imitate |

### Shipping

| Command | Description |
|---------|-------------|
| `/healer:deploy` | Research-augmented production deployment — runs all test suites as a |
| `/healer:docs` | Research-augmented documentation generation — auto-generates README, |
| `/healer:push` | Research-augmented commit and push — stages changes, generates a |
| `/healer:ship` | Complete PR workflow — branch, commit, push, create PR, wait for |

### Help

| Command | Description |
|---------|-------------|
| `/healer:add-command` | Atomic scaffolder for new healer commands — interactively prompts |
| `/healer:help` | Interactive help system — list commands, flows, recipes, gates, examples, |
<!-- HEALER:COMMANDS:END -->

## Flow Orchestrator

Chain commands into pipelines with gate operators:

```
/healer:flow feature                              # Built-in preset
/healer:flow brainstorm → plan → implement        # Inline chain
/healer:flow diagnose !→ deploy                   # Must-pass gate
/healer:flow plan ?→ implement → test             # Interactive checkpoint
```

### Gate Operators

| Operator | Name | On Success | On Failure |
|----------|------|-----------|------------|
| `→` | AUTO | Continue | Warn, continue |
| `?→` | INTERACTIVE | Ask user | Ask user |
| `!→` | MUST-PASS | Continue | **HALT** |

### Built-in Presets

> **Auto-generated from `data/flows.yaml`.** Do not edit content between the marker comments.

<!-- HEALER:FLOWS:START -->
| Preset | Pipeline | Purpose |
|--------|----------|---------|
| `audit` | analyze → audit → coverage → report → | Comprehensive health audit — analyze patterns, scan security, measure coverag... |
| `brand-to-prod` | brand ?→ design-system ?→ design ?→ implement → test !→ review ?→ ship !→ | Full brand-aware feature development — brand → design-system → design → imple... |
| `catchup` | catchup → test !→ review ?→ | Gap analysis + auto-fix — catchup → test → review. Use when artifacts have dr... |
| `conform` | conform !→ implement → conform !→ test !→ push ?→ | Design conformance gate around implementation — conform → implement → conform... |
| `deploy` | diagnose !→ review ?→ ship !→ | Safe deployment pipeline — pre-deploy diagnostic gate, code review checkpoint... |
| `feature` | brainstorm ?→ plan ?→ implement → test !→ review ?→ ship !→ | Full feature development lifecycle — takes an idea from exploration |
| `fix` | diagnose → debug → fix → test !→ push ?→ | Diagnose and fix issues in a single pipeline — runs full diagnostic |
| `full-qa` | imitate → indulge !→ coverage → report → | Complete QA pipeline — imitate → indulge (must-pass) → coverage → report. Use... |
| `full-verify` | conform !→ verify !→ test !→ review ?→ ship !→ | Visual + behavioral verification before shipping — conform (must-pass) → veri... |
| `ideate` | validate ?→ brainstorm ?→ research → design ?→ strategy ?→ spec ?→ plan ?→ | Full ideation pipeline from validation to plan — takes an idea through |
| `identity` | brand ?→ logo ?→ cip ?→ design-system ?→ | Brand identity pipeline — brand voice → logo → CIP → design system. Use for f... |
| `imitate-full` | imitate → indulge !→ push ?→ | Full 10x imitation + testing — imitate --full → indulge --full (must-pass) → ... |
| `imitate-onboard` | imitate → report → | Full onboarding + CLAUDE.md generation — imitate --full --claude-md → report.... |
| `imitate-regression` | imitate → indulge → report → | Regression detection — imitate --diff → indulge --regression → report. Use to... |
| `imitate-secure` | imitate → indulge → audit → report → | Security-focused imitation — imitate --risk → indulge --security → audit → re... |
| `imitate-test` | imitate → indulge !→ | Imitate flows + test them — imitate → indulge (must-pass). Use for app revers... |
| `imitate-visual` | imitate → indulge → design-review → report → | Visual audit — imitate --layer=frontend → indulge --visual --a11y → design-re... |
| `karpathy-fix` | karpathy → fix → karpathy !→ push ?→ | Karpathy review + fix loop — karpathy → fix → karpathy (must-pass) → push. |
| `karpathy-review` | implement → karpathy !→ push ?→ | Karpathy-lens review before shipping — implement → karpathy (must-pass) → push. |
| `morning` | diagnose → report → | Quick morning health check — runs diagnose and produces a health report. Use ... |
| `onboard` | imitate → report → | Onboarding (read-only) — imitate → report. Use when joining a new project to ... |
| `pre-ship` | verify !→ review ?→ ship !→ | Pre-ship gate to production — verify → review → ship. Use when you want one s... |
| `refactor` | analyze → plan ?→ refactor → test !→ review ?→ push ?→ | Research-backed code improvement — analyze first, plan refactor, execute, tes... |
| `research` | research → brainstorm ?→ design ?→ spec → | Deep research to specification — research → brainstorm → design → spec. Use w... |
| `tdd` | plan ?→ tdd → coverage → review ?→ push ?→ | Test-driven development flow — plan → tdd → coverage → review → push. Use whe... |
| `verify` | verify !→ push ?→ | Requirement verification + autonomous fix — verify (must-pass) → push. Use as... |
| `visual` | brand ?→ design-system ?→ design ?→ design-review → | Visual design pipeline with brand awareness — brand → design-system → design ... |
<!-- HEALER:FLOWS:END -->

### Custom Recipes (20+)

See `config/recipes.yaml` for all custom recipes including: `full-feature`, `quick-feature`, `spike`, `deep-fix`, `hotfix`, `flaky-hunt`, `full-audit`, `pre-release`, `health-deep`, `architect-feature`, `deep-refactor`, `perf-deep`, `tech-debt`, `safe-deploy`, `ci-fix`, `end-of-day`, `weekly-review`, and more.

## Smart Next-Step Suggestions

After any command completes, run `/healer` with no arguments — it reads `.healer/state.json` and suggests the natural next step:

```
💡 Last: /healer:brainstorm ✅
   Suggested next: /healer:plan

   Continue with /healer:plan? [Y/n/other]
```

## Supported Stacks

Healer auto-detects by scanning manifest files:

- **JavaScript/TypeScript** — package.json, Next.js, React, Vue, Angular
- **Python** — pyproject.toml, Django, FastAPI, Flask
- **Go** — go.mod
- **Rust** — Cargo.toml
- **Swift/iOS/macOS** — Package.swift, Xcode projects
- **Kotlin/Android** — build.gradle
- **C#/.NET** — *.csproj, *.sln
- **Flutter/Dart** — pubspec.yaml
- **Ruby** — Gemfile, Rails
- **Java** — pom.xml, build.gradle
- **C/C++** — CMakeLists.txt, Makefile
- **Elixir, Haskell, OCaml, Julia** — and more

## User Guide

Open the comprehensive HTML user guide:

```bash
open ~/.healer/healer-user-guide.html
```

## The Differentiator

Every healer command includes a **Research Phase** that searches GitHub, official docs, CVE databases, engineering blogs, and community discussions **before** acting. This means healer doesn't just fix your code — it learns from the best implementations in the world and adapts them to your project.

## License

MIT

## Author

Built by [WeaverBird LLC](https://github.com/AnandSGit)
