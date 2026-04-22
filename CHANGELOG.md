# Changelog

All notable changes to Healer are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [9.1.0] — 2026-04-21

### Added — Deep-Research + Options-First Protocol

A new shared module (`shared/_research_and_options.md`) defines an 8-category
research matrix and a mandatory Options-First selection gate for every
command that produces ideas, designs, specs, or plans. Commands no longer
silently pick one approach — they present a curated menu and wait for the
user's selection.

- **`shared/_research_and_options.md`** — new shared protocol with:
  - **8-category research matrix**: best-practice state, competitor teardown
    (≥3), reference implementations (top-starred GitHub), anti-patterns /
    postmortems (non-negotiable), authoritative specs (RFCs / W3C / ADRs),
    **visual inspiration galleries** (Mobbin, Dribbble, Awwwards, Behance,
    Land-book, godly.website, SaaS landing galleries), Context7 library docs,
    contradiction & consensus scan
  - **Source credibility scoring** (★★★★★ to ★) with ≥3 distinct-organization
    diversity requirement
  - **Minimum candidate counts** per command+domain (brainstorm: 7,
    design-UI: 10, design-API: 7, design-UX: 5, spec: 5, plan: 4,
    architect: 5, strategy: 4, refactor: 5, optimize: 5, catchup: 3)
  - **Candidate Divergence Rule** — options must come from different
    architectures / aesthetic families / strategies, not parameter tuning
  - **Visual Direction Starter Catalog** — 20 distinct aesthetic families
    (editorial, swiss-grid, brutalist, neo-brutalist, glassmorphism,
    neumorphic, bento, terminal-CLI, skeuomorphic-modern, Memphis,
    liquid-glass, data-dense, pastel, zine, maximalist-animated,
    command-palette-first, etc.) to draw UI options from
  - **Numbered pros/cons template** + **Tradeoff Matrix** for all commands
  - **HTML option gallery** spec for UI picks —
    `docs/design-previews/options/{date}-{slug}/index.html` with iframe
    tiles of all N variants, self-contained (no CDN), responsive 3-col grid
- **HARD-GATE: Options-First Protocol** — new gate in `_enforcement.md`
  binding all commands to the shared module
- **HARD-GATE: Deep-Research Protocol upgrade** — existing research gate now
  requires all 8 categories, not just "≥1 WebSearch"

### Changed — Commands upgraded to use the new protocol

- **`/healer:brainstorm`** — Step 3 (Research) now mandates all 8 categories
  with ≥3 distinct organizations and ≥2 anti-pattern findings. Step 4
  (Options) now requires **7 genuinely distinct approaches** (was "2-3") with
  Divergence-Rule enforcement. Example 7-option set included inline.
- **`/healer:design`** — Step 2 (Research) upgraded to 8-category protocol
  with mandatory visual-gallery research (≥5 references described in prose).
  New **Step 3 (Options Phase)** presents **10 UI visual directions / 7 API
  options / 5 UX flow variants** with numbered pros/cons AND a self-contained
  HTML option gallery at `docs/design-previews/options/`. Old steps
  renumbered (old Step 3 → Step 4, old Step 4 → Step 5, old 4b → 5b, etc).
  New red flags for missing options / variation-only options / missing HTML
  gallery.
- **`/healer:spec`** — Step 2 (Research) upgraded to 8-category protocol
  with emphasis on Category 5 (authoritative specs — RFCs/W3C/ADRs fetched,
  not paraphrased). New **Step 2.5 (Options Phase)** presents **5 structural
  variants** (e.g., REST+webhooks vs WebSocket push vs SSE vs GraphQL-subs
  vs queue-backed-pull) with acceptance-criteria / error-catalog /
  migration impact per variant. Section 16 "Alternatives Considered" now
  captures the outcome.
- **`/healer:plan`** — Step 2 (Research) upgraded to 8-category protocol.
  New **Step 2.5 (Options Phase)** presents **4 execution-order strategies**
  (vertical-slice-first / horizontal-layer-first / risk-first /
  happy-path-first / TDD-outer-loop / parallelization-optimized) with phase
  shape, checkpoint density, rollback-ease, and parallelizability tradeoffs.
- **`/healer:catchup`** — New **Step 5.5 (Fix-Strategy Research)** runs
  focused research per gap cluster before fixing, producing a
  Fix-Strategy Brief (current best practice + known anti-pattern to avoid +
  library API check). New **Step 5.6 (Fix-Strategy Options)** presents 3
  strategies per cluster that has ≥3 gaps and multiple valid fixes
  (trivial clusters proceed directly). Iteration-caching note prevents
  re-research on every convergence loop pass.

### Why this release

User feedback: "I was never asked any question to select the design with
giving me options. (Enough number of best options to select one). Same
applicable for any implementation or analysis or design or plan." Prior
versions had research built in but no options-selection gate, so commands
silently picked approaches instead of curating the design space for the
user. This release treats "curate the menu" as the command's job and
"pick one" as the user's job — non-negotiable.

---

## [9.0.0] — 2026-04-15

### Breaking — Karpathy Enforcement Integration

New HARD-GATE enforcement rules change behavior of all code-writing commands.
Commands that write or edit source code now enforce Karpathy's Simplicity and
Surgical Changes principles automatically. Existing workflows may surface
violations that were previously silent.

### Added

- **`/healer:karpathy`** — Karpathy-lens code review checking recent changes
  against four principles (Think Before Coding, Simplicity First, Surgical
  Changes, Goal-Driven Execution) with research-augmented validation and dual
  per-principle + per-file report format (Option C)
- **HARD-GATE: Simplicity Protocol (Karpathy P2)** — self-scoped gate in
  `_enforcement.md` preventing over-engineering, speculative features, and
  single-use abstractions. Heuristic: "200 lines → could be 50? Rewrite."
- **HARD-GATE: Surgical Changes Protocol (Karpathy P3)** — self-scoped gate
  enforcing minimal diffs with traceback test: "Every changed line traces
  directly to the user's request"
- **P1 enhancement** — Research Protocol now requires surfacing tradeoffs,
  presenting alternative approaches, and pushing back when simpler options exist
- **5 anti-rationalization entries** — YAGNI abstractions, speculative config,
  drive-by cleanups, over-architecture, future-requirement speculation
- **3 red-flag stop conditions** — file drift, single-use abstraction, unrelated
  formatting in diffs
- **Flow presets**: `karpathy-review` (implement → karpathy !→ push),
  `karpathy-fix` (karpathy → fix → karpathy !→ push)
- **Suggested-next graph**: karpathy integrated into implement/review/refactor paths

### Documented

- P4 (Goal-Driven Execution) noted as already fully covered by existing
  Verification Protocol and Fix Verification Protocol — no new gate needed

### Design

- Self-scoping HARD-GATEs: P2/P3 gates activate only when commands write source
  code (Write/Edit tools). Dormant for ideation commands (brainstorm, validate,
  research, etc.). Handles mixed commands (fix, tdd) naturally by scoping to
  code-writing phases.
- `_enforcement.md` stays at 607 lines (within 800-line budget)

### Artifacts

- Design: `docs/designs/2026-04-15-karpathy-integration.md`
- Spec: `docs/specs/2026-04-15-karpathy-integration.md`
- Plan: `docs/plans/2026-04-15-karpathy-integration.md`
- Brainstorm: `~/.healer/brainstorms/2026-04-15-karpathy-in-healer.md`
- Research: `~/.healer/research/2026-04-15-karpathy-in-healer.md`

---

## [8.1.0] — 2026-04-12

### Added — Style DNA deep-style capture + `/healer:adapt` replicator

Motivation: a user ran `/healer:imitate --layer=frontend --full` on a financial
app ("Prism") and adapted the output onto a second project ("Adapt"). The
result landed at a 5-6/10 visual-fidelity ceiling — structural bones matched,
but the specific feel did not. Root cause: imitate captured primitives and
tokens, but not the dimensions where "looks like the same app" actually
lives — page-level composition grammar, per-context visual micro-decisions,
chart render specifics, per-icon styles, branding SVG data, copy voice,
AI-response rendering patterns, and literal motion values. And the output
was prose, not a machine-parseable contract — so no downstream command could
replicate it deterministically.

#### `/healer:imitate` — deep-style capture (additive)
- **Eight new ID prefixes** scoped to the frontend layer:
  - `PC-NNN` Page Composition (layout shell, hero variant, primary/secondary
    section grammar, density, per-page micro-spacing, section-icon-color
    map, copy voice ref, composition hash)
  - `VM-NNN` Visual Motif (named gestures like card-lift-on-hover,
    glass-overlay, number-ticker — definition, triggers, applied_to list)
  - `CH-NNN` Chart Render Config (library, chart type, full axes config,
    legend, tooltip, colors, animation — captures render-output not just
    component name)
  - `IC-NNN` Icon Usage (system fingerprint with stroke width / corner
    style / fill / size scale / color strategy PLUS per-icon catalog PLUS
    custom inline-SVG path data)
  - `BR-NNN` Branding Asset (logos, gradients, marks with exact SVG path
    data, gradient stops, viewBox, aspect ratio)
  - `CV-NNN` Copy Voice (tone markers 0-1, sentence pattern templates,
    emoji usage rules per-context, microcopy catalog)
  - `AR-NNN` AI Response Pattern (RichResponse-style rendering: markdown
    lib, citation style, suggestion-chip layout, streaming cursor, structured
    output handlers)
  - `MD-NNN` Motion Literal (EXACT cubic-bezier arrays, spring stiffness /
    damping / mass, duration scale, stagger scale, page transition config,
    reduced-motion handling)
- **New Step 8.5** (deep-style scan) runs when frontend is in scope, emitting
  PC/VM/CH/IC/BR/CV/AR/MD entries with source-file:line provenance on every
  field.
- **New Sections 1.B.10–1.B.20** in the markdown output surface findings
  for human review (page compositions table, visual motifs, chart render
  configs, per-icon catalog, branding assets, copy voice, AI response
  patterns, motion literals, per-context spacing overrides, focus ring &
  a11y visuals, Style DNA emission summary).
- **New Step 13.5** emits `{AppName}_StyleDNA_{MMDDYYYY}.yaml` alongside
  the markdown. Validated against a rigorous schema with closed enums and
  mandatory `source_file:line` provenance. Deterministic: same git SHA =
  byte-identical YAML (canonical hash excludes `generated_at`).
- **New flags:**
  - `--style-dna` (DEFAULT ON when frontend in scope)
  - `--no-style-dna` (suppress emission)
  - `--pages=exhaustive` (DEFAULT — every route gets a PC-NNN entry)
  - `--pages=sample` (landing + 3 most-distinct + 1 per unique layout shell)
  - `--rendered` (opt into headless-browser evidence for computed CSS
    snapshots and screenshot paths — augments, never overrides, source
    values)
  - `--deep-style` (alias: `--style-dna --pages=exhaustive --rendered`)

#### `/healer:adapt` — NEW command (the replicator / decoder)

- **The consumer side of imitate.** Takes a Style DNA YAML, scans a target
  codebase, computes an adaptation plan, and optionally applies it. Closes
  the 5-6/10 visual-fidelity ceiling by replicating page compositions,
  visual motifs, chart render configs, per-icon styles, and motion literals
  — not just tokens and primitives.
- **Three write modes:**
  - `--plan-only` — emits `ADAPTATION_PLAN.md` only. Safe preview. Zero
    writes to target files.
  - `--write-components` (DEFAULT) — writes tokens + primitives +
    reusable composition templates. Does NOT touch target pages.
  - `--full` — also rewrites target pages to echo source PC-NNN page
    compositions. Explicit flag required.
- **Decision records:** `AD-NNN` (Adaptation Decision), `CF-NNN` (Conflict
  Flag — target has a differing value), `GP-NNN` (Gap — target stack cannot
  express this StyleDNA section).
- **Opt-in sections** with explicit defaults OFF: `--copy-voice` (source
  microcopy usually doesn't apply), `--branding` (target has its own brand).
- **Section filters:** `--only=<sections>` and `--exclude=<sections>` with
  9-section vocabulary (tokens, motifs, pages, charts, icons, branding,
  copy_voice, ai_response, motion). Mutually exclusive.
- **Target-stack translation:** tokens translate into target's idiom —
  Tailwind target gets `tailwind.config.*` extensions, CSS-modules target
  gets `:root { --* }` variables, styled-components target gets theme
  object. Chart configs translate across libraries (recharts ↔ chart.js
  ↔ nivo) where possible; otherwise logged as `GP-NNN`.
- **Determinism contract:** same StyleDNA + same target SHA + same flags =
  byte-identical `ADAPTATION_PLAN.md`.
- **Fidelity scoring:** `ADAPTATION_REPORT.md` emits 0-10 per-section
  scores and an overall projected fidelity with plain-English rationale.
- **Never commits.** Writes files. User commits via `/healer:push` or
  `/healer:ship`.

#### New shared schema: `references/ui-styling/style-dna.md`
- 12 top-level sections (envelope, tokens, visual_motifs, page_compositions,
  chart_renders, icon_usage, branding_assets, copy_voice,
  ai_response_patterns, motion_literals, primitives_ref, provenance).
- Closed enums throughout (layout_shell, chart_type, icon style, gradient
  type, citation style, etc.) — prevents string drift between imitate and
  adapt.
- Mandatory `source_file:line` provenance on every non-trivial field.
- Canonical-hash determinism contract.
- Companion JSON Schema Draft 2020-12 for automated validation.

#### Flow preset updates
- `imitate-test`, `imitate-full`, `imitate-secure`, `imitate-visual`,
  `imitate-onboard`, `imitate-regression` all still function unchanged —
  they automatically benefit from StyleDNA emission when the frontend
  layer is in scope.
- Suggested-next graph: `imitate → adapt` added. State file records
  `style_dna_file`, `style_dna_hash`, `pages_mode`, `rendered_evidence`,
  and per-prefix counts.

#### Non-breaking by design
- Existing `/healer:imitate` invocations continue to work. StyleDNA emission
  is ADDITIVE (a second output file) — nothing existing is replaced. Users
  who do not want the YAML can pass `--no-style-dna`.
- Command count: 42 → 43. Flow preset count unchanged at 25.

---

## [8.0.0] — 2026-04-12

### Changed — BREAKING: `/healer:record` renamed to `/healer:imitate`

- **Command renamed:** `/healer:record` → `/healer:imitate`. No alias; clean rename.
- **New `--layer` flag** (replaces `--frontend-only` / `--backend-only` / `--design-only`).
  Accepts comma-separated values: `frontend`, `backend`, `server`, `db`, `ai`.
  Example: `/healer:imitate --layer=frontend,db`.
  Without `--layer`, all 5 layers are imitated.
- **5 layers (up from 8 heuristic sections):**
  - `frontend` — components, pages, state, styles, design tokens, UI hierarchy
  - `backend` — API surface, business logic, validators, domain models
  - `server` — env, middleware order, request pipeline, process lifecycle,
    graceful shutdown, CI/CD, Dockerfiles, infra-as-code
  - `db` — schemas, migrations, ORM models, RLS, views, triggers, indexes
  - `ai` — prompts, agents, chains, embeddings, vector stores, tools, RAG
    (NEW layer — not covered by `record`)
- **New flow ID prefixes:** `AI-NNN` (AI surfaces), `SRV-NNN` (server elements).
- **4-in-1 output per layer:** every layer section now contains four subsections —
  **Requirements**, **Design**, **Specification**, **Implementation Plan**.
  Enough to rebuild the layer from scratch in a new codebase.
- **Output filename:** `{AppName}_Imitate_{MMDDYYYY}.md`
  (was `{AppName}_Business_Flows_Helper_{MMDDYYYY}.md`).
- **Flow presets renamed:** `record-test` → `imitate-test`, `record-full` →
  `imitate-full`, `record-secure` → `imitate-secure`, `record-visual` →
  `imitate-visual`, `record-onboard` → `imitate-onboard`, `record-regression`
  → `imitate-regression`.
- **`/healer:indulge` now parses imitate files.** The `--record {path}` flag
  became `--imitate {path}`. Error codes `ERR_NO_RECORD` / `ERR_RECORD_STALE`
  became `ERR_NO_IMITATE` / `ERR_IMITATE_STALE`.

### Migration

```
# Old                                 # New
/healer:record                        /healer:imitate
/healer:record --frontend-only        /healer:imitate --layer=frontend
/healer:record --backend-only         /healer:imitate --layer=backend
/healer:record --design-only          /healer:imitate --layer=frontend
/healer:flow record-test              /healer:flow imitate-test
/healer:indulge --record <path>       /healer:indulge --imitate <path>
```

### Added

- **`ai` layer scan:** detects LLM client code, prompt templates, agents,
  chains, embeddings, vector stores, tool definitions, RAG pipelines, and
  observability hooks across Anthropic/OpenAI/LangChain/LlamaIndex/Vercel AI SDK.
- **Server layer expansion:** now includes process lifecycle (entry points,
  graceful shutdown, signal handling), middleware chain (with **order
  preserved** — order is part of the spec), and request pipeline.
- **Per-layer Implementation Plan:** bite-sized tasks with dependencies, effort,
  verification checkpoints, and build order — each task traces back to a flow ID.

---

## [7.1.0] — 2026-04-11

### Added — Postfix `?` Help + Self-Validating Command Catalog

- **Postfix `?` and `--help` interceptor** in `shared/_enforcement.md`.
  Type `/healer:<command> ?` or `/healer:<command> --help` for instant
  six-section drill-down help. Works on every healer command.
  Drill-down also supported for flow presets: `/healer:flow feature ?`.
- **Canonical command catalog** at `data/commands.yaml` and `data/flows.yaml`,
  validated by JSON Schema (`data/schema/*.json`). Single source of truth
  for all command and flow metadata.
- **Pre-built help index** at `data/help-index.json` for sub-50ms help
  latency. Replaces the previous slow path that scanned all 41 command
  files (~14k lines) on every help invocation.
- **PostToolUse hook** (`hooks/hooks.json`) with matcher `Write|Edit`
  automatically rebuilds `data/help-index.json` whenever any command file,
  YAML catalog, or schema is edited. Drift between `commands/*.md` and
  `data/commands.yaml` is detected and reported with a loud error.
- **Build pipeline:**
  - `scripts/build-help-index.sh` (Bash wrapper)
  - `scripts/build_help_index.py` (Python core: validates, renders, writes)
  - `scripts/help_catalog_hook.sh` (PostToolUse handler)
- **Help renderer documentation** at `shared/_help_renderer.md` describing
  the four panel variants (command, flow-overview, flow-preset, recipe)
  and the dispatch contract.
- **Six-section drill-down format** for every command and flow:
  PURPOSE → WHAT IT DOES → INPUT → CONCRETE EXAMPLE → INPUT PURPOSE → AFTER.
- **Recipe support:** `/healer:flow <recipe> ?` resolves user-local recipes
  from `~/.healer/recipes.yaml` at runtime (not baked into shipped artifact).

### Changed

- `plugin.json` description now mentions the discoverability primitive
  and self-validating catalog.
- `shared/_enforcement.md` bumped to v1.1; the `?` interceptor block is
  the FIRST hard-gate in the file (runs before research/verification).

### Notes

- The full command catalog migration (all 41 commands + 26 flows in YAML)
  is in progress — pilot covers `brainstorm`, `flow`, `help`, and three
  flow presets (`feature`, `fix`, `ideate`). Remaining commands fall
  through to the dynamic-help fallback path with a one-line warning until
  migrated.
- See `docs/plans/2026-04-11-postfix-help-and-catalog.md` for the full
  implementation plan and remaining work (Phases 3, 5, 6, parts of 7).

---

## [7.0.0] — 2026-04-09

### Added

- `/healer:record` — reverse-engineer an entire app into a flow document
  (8-layer analysis: frontend, backend, DB, design, infra, etc.).
- `/healer:indulge` — record-driven exhaustive flow testing across 6
  dimensions (happy path, negative input, boundary, permission, state,
  data integrity).
- `/healer:verify` — 9-dimension functional verification engine with
  autonomous fix dispatch.
- `/healer:conform` — design conformance gate enforcing pixel-perfect
  spec compliance.
- New flow presets: `record-test`, `record-full`, `full-qa`, `onboard`,
  `record-secure`, `record-visual`, `record-onboard`, `record-regression`.
- Total: 41 commands, 26 flow presets, 36+ recipes.

### Changed

- Plugin renamed from `healer-v6` to `healer` v7.0.0.
- Install script updated for verify command and 39+ command roster.

[7.1.0]: https://github.com/AnandSGit/Healer/releases/tag/v7.1.0
[7.0.0]: https://github.com/AnandSGit/Healer/releases/tag/v7.0.0
