# Healer v4

**Universal Autonomous Codebase Health & Development Engine**

26 commands | 28 flow recipes | Shared enforcement protocol | Any project, any language, any platform

---

## What is Healer?

Healer is a comprehensive command suite for [Claude Code](https://claude.ai/code) that turns your AI assistant into a research-augmented development lifecycle engine. Every command searches for best practices, patterns, and proven solutions **before** acting.

### What's New in v4: Enforcement Protocol

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

## Commands (26)

### Core
| Command | Description |
|---------|-------------|
| `/healer` | Full 7-phase autonomous heal (discover → understand → assess → research → plan → execute → report) |
| `/healer:flow` | Chain multiple commands into pipelines with gate controls |

### Ideation & Design
| Command | Description |
|---------|-------------|
| `/healer:brainstorm` | Socratic dialogue + research-augmented idea exploration |
| `/healer:research` | Deep multi-source research on any topic |
| `/healer:design` | Feature/API/UX design with real-world references |
| `/healer:architect` | System architecture informed by postmortems |
| `/healer:spec` | Technical specifications cross-referenced with public RFCs |
| `/healer:plan` | Bite-sized task lists with dependency tracking |

### Implementation
| Command | Description |
|---------|-------------|
| `/healer:implement` | Research-augmented feature building |
| `/healer:tdd` | Test-driven development (Red-Green-Refactor) |
| `/healer:refactor` | Clean code refactoring with Fowler pattern citations |
| `/healer:optimize` | 10-phase performance investigation with baselines |

### Testing & Quality
| Command | Description |
|---------|-------------|
| `/healer:test` | Research-augmented test writing |
| `/healer:coverage` | Test coverage analysis with risk prioritization |
| `/healer:review` | Code review validated against best practices |
| `/healer:audit` | OWASP + CVE + accessibility + license audit |

### Debugging & Fixing
| Command | Description |
|---------|-------------|
| `/healer:debug` | Hypothesis-driven systematic debugging |
| `/healer:fix` | Targeted test suite fix with max 5 iterations |

### Health & Reporting
| Command | Description |
|---------|-------------|
| `/healer:diagnose` | Read-only health check with severity classification |
| `/healer:report` | Formal A-F health status report |
| `/healer:analyze` | Codebase health vs industry standards |

### Shipping
| Command | Description |
|---------|-------------|
| `/healer:push` | Conventional commit with emoji + push |
| `/healer:ship` | Full PR workflow with auto-reviewer loop |
| `/healer:deploy` | Gate-checked deployment with smoke tests |
| `/healer:docs` | Documentation generation (Divio framework) |

### Help
| Command | Description |
|---------|-------------|
| `/healer:help` | Interactive help — list commands, flows, recipes, gates, examples |

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

### Built-in Presets (8)

| Preset | Pipeline |
|--------|----------|
| `feature` | brainstorm → plan → implement → test → review → ship |
| `fix` | diagnose → debug → fix → test → push |
| `deploy` | diagnose → review → ship |
| `audit` | analyze → audit → coverage → report |
| `morning` | diagnose → report |
| `refactor` | analyze → plan → refactor → test → review → push |
| `tdd` | plan → tdd → coverage → review → push |
| `research` | research → brainstorm → design → spec |

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
