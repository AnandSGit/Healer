# HEALER DESIGN DOCUMENT
===================================
Feature: UI-UX-Pro-Max Integration into Healer
Stack: Claude Code Plugin (Markdown commands + Python scripts + CSV data)
Date: 2026-03-29
Prior designs: None
Brainstorm source: ~/.healer/brainstorms/2026-03-29-healer-uiux-integration.md
Research source: RES-20260329-CSVP at ~/.healer/research/2026-03-29-csv-plugin-integration.md
Inspired by:
  - Claude Code plugin reference — https://code.claude.com/docs/en/plugins-reference
  - Claude Code hooks guide — https://code.claude.com/docs/en/hooks-guide
  - UI-UX-Pro-Max source code (direct read) — core.py BM25 search pattern
  - SKILL.md Pattern article — https://bibek-poudel.medium.com/the-skill-md-pattern-how-to-write-ai-agent-skills-that-actually-work-72a3169dd7ee
  - Atomic UNIX operations — https://rcrowley.org/2010/01/06/things-unix-can-do-atomically.html

## DESIGN OVERVIEW
─────────────────────────────────

Absorb all UI-UX-Pro-Max design intelligence into Healer as a purely additive integration:
- 6 new commands (brand, logo, cip, banner, icon, slides)
- 5 enhanced commands (design, design-system, design-review, implement, audit)
- Infrastructure: data/ (76 CSVs), references/ (57 docs), scripts/ (4 Python files)
- SessionStart hook for upstream sync with atomic directory swap
- New flow presets for design/brand workflows

The integration follows a **Data Layer + Process Layer** architecture:
- **Data Layer**: CSV files + Python BM25 search engine (forked from UI-UX-Pro-Max)
- **Process Layer**: Healer markdown commands with enforcement protocol (native)

---

## 1. PLUGIN DIRECTORY LAYOUT
─────────────────────────────────

### Current Structure (unchanged)
```
Healer/
├── commands/                        # Existing — ALL unchanged
│   ├── _enforcement.md              # Shared enforcement protocol
│   ├── healer.md                    # Main command (UPDATED: add 6 new sub-commands)
│   ├── healer:analyze.md
│   ├── healer:architect.md
│   ├── healer:audit.md              # ENHANCED: add UX rules from CSVs
│   ├── healer:brainstorm.md
│   ├── healer:coverage.md
│   ├── healer:debug.md
│   ├── healer:deploy.md
│   ├── healer:design-review.md      # ENHANCED: add 99 UX guidelines + platform rules
│   ├── healer:design-system.md      # ENHANCED: add 161 palettes, 57 font pairings
│   ├── healer:design.md             # ENHANCED: add style/product CSV lookups
│   ├── healer:diagnose.md
│   ├── healer:docs.md
│   ├── healer:fix.md
│   ├── healer:flow.md               # UPDATED: add new presets
│   ├── healer:help.md               # UPDATED: document new commands
│   ├── healer:implement.md          # ENHANCED: add stack-specific guidelines
│   ├── healer:optimize.md
│   ├── healer:plan.md
│   ├── healer:push.md
│   ├── healer:refactor.md
│   ├── healer:report.md
│   ├── healer:research.md
│   ├── healer:review.md
│   ├── healer:ship.md
│   ├── healer:spec.md
│   ├── healer:strategy.md
│   ├── healer:tdd.md
│   ├── healer:test.md
│   └── healer:validate.md
├── config/
│   └── recipes.yaml                 # UPDATED: add new flow recipes
├── docs/
│   └── healer-user-guide.html
├── .healer/                         # Runtime state (gitignored)
│   └── state.json
├── install.sh
├── LICENSE
└── README.md                        # UPDATED: document new capabilities
```

### New Structure (additions only)
```
Healer/
├── commands/                        # ADDITIONS to existing directory
│   ├── healer:brand.md              # NEW — voice framework, visual identity
│   ├── healer:logo.md               # NEW — logo design guidance
│   ├── healer:cip.md                # NEW — corporate identity program
│   ├── healer:banner.md             # NEW — banner & social media design
│   ├── healer:icon.md               # NEW — icon design & SVG generation
│   └── healer:slides.md             # NEW — presentation design
│
├── data/                            # NEW — forked from UI-UX-Pro-Max
│   ├── styles.csv                   # 67 UI styles (139K)
│   ├── colors.csv                   # 161 color palettes (32K)
│   ├── typography.csv               # 57 font pairings (49K)
│   ├── ux-guidelines.csv            # 99 UX guidelines (18K)
│   ├── products.csv                 # 161 product types (57K)
│   ├── ui-reasoning.csv             # 161 reasoning rules (52K)
│   ├── charts.csv                   # 25 chart types (19K)
│   ├── icons.csv                    # Icon systems (20K)
│   ├── landing.csv                  # Landing page patterns (16K)
│   ├── app-interface.csv            # UI components (9.5K)
│   ├── react-performance.csv        # React optimization (14K)
│   ├── google-fonts.csv             # Font library (728K)
│   ├── design.csv                   # Comprehensive design data (104K)
│   └── stacks/                      # Stack-specific guidelines
│       ├── react.csv
│       ├── nextjs.csv
│       ├── vue.csv
│       ├── svelte.csv
│       ├── astro.csv
│       ├── swiftui.csv
│       ├── react-native.csv
│       ├── flutter.csv
│       ├── nuxtjs.csv
│       ├── nuxt-ui.csv
│       ├── html-tailwind.csv
│       ├── shadcn.csv
│       ├── jetpack-compose.csv
│       ├── laravel.csv
│       └── threejs.csv
│
├── references/                      # NEW — forked from UI-UX-Pro-Max
│   ├── brand/                       # 10 brand reference docs
│   │   ├── voice-framework.md
│   │   ├── visual-identity.md
│   │   ├── messaging-framework.md
│   │   ├── color-palette-management.md
│   │   ├── typography-specifications.md
│   │   ├── logo-usage-rules.md
│   │   ├── asset-organization.md
│   │   ├── consistency-checklist.md
│   │   ├── approval-checklist.md
│   │   └── brand-guideline-template.md
│   ├── design/                      # 10 design reference docs
│   │   ├── logo-design.md
│   │   ├── logo-prompt-engineering.md
│   │   ├── logo-color-psychology.md
│   │   ├── logo-style-guide.md
│   │   ├── icon-design.md
│   │   ├── cip-design.md
│   │   ├── cip-prompt-engineering.md
│   │   ├── cip-style-guide.md
│   │   ├── cip-deliverable-guide.md
│   │   └── design-routing.md
│   ├── design-system/               # 7 design-system reference docs
│   │   ├── token-architecture.md
│   │   ├── primitive-tokens.md
│   │   ├── semantic-tokens.md
│   │   ├── component-tokens.md
│   │   ├── component-specs.md
│   │   ├── states-and-variants.md
│   │   └── tailwind-integration.md
│   ├── ui-styling/                  # 7 UI styling reference docs
│   │   ├── tailwind-customization.md
│   │   ├── tailwind-responsive.md
│   │   ├── tailwind-utilities.md
│   │   ├── shadcn-components.md
│   │   ├── shadcn-theming.md
│   │   ├── shadcn-accessibility.md
│   │   └── canvas-design-system.md
│   └── slides/                      # 8 slides reference docs
│       ├── slides.md
│       ├── slides-create.md
│       ├── slides-html-template.md
│       ├── slides-layout-patterns.md
│       ├── slides-strategies.md
│       ├── slides-copywriting-formulas.md
│       ├── social-photos-design.md
│       └── banner-sizes-and-styles.md
│
├── scripts/                         # NEW — forked from UI-UX-Pro-Max
│   ├── search.py                    # BM25 search engine (entry point)
│   ├── core.py                      # CSV config, search logic, BM25
│   ├── design_system.py             # Design system generation
│   ├── _sync_all.py                 # Original sync script
│   └── sync-upstream.sh             # NEW — SessionStart sync hook script
│
└── hooks/                           # NEW — plugin hooks
    └── hooks.json                   # SessionStart hook for upstream sync
```

### Design Decision: Why This Layout
- `data/` mirrors UI-UX-Pro-Max's `src/ui-ux-pro-max/data/` — Python scripts reference `../data/` relative to scripts/
- `references/` mirrors UI-UX-Pro-Max's skill reference docs — commands reference via `${CLAUDE_PLUGIN_ROOT}/references/`
- `scripts/` contains the Python search engine — commands call via `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py`
- `hooks/` is the standard Claude Code plugin hook location
- `commands/` stays flat (no subdirectories) — matches Healer's existing pattern

---

## 2. DATA FLOW ARCHITECTURE
─────────────────────────────────

### Primary Data Flow: Command → Script → CSV → Output

```
User invokes /healer:design-system
    │
    ▼
Claude loads healer:design-system.md from commands/
    │
    ▼
Command instructs: "Run data lookup BEFORE web research"
    │
    ▼
Claude executes via Bash:
    python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py \
      "<product_type> <keywords>" --design-system
    │
    ▼
search.py → imports core.py
    │
    ├── core.py reads CSV_CONFIG (domain → file mapping)
    ├── core.py loads data/*.csv files
    ├── BM25 ranking over search_cols
    ├── Returns top N matches with output_cols
    │
    ▼
search.py formats results as markdown
    │
    ▼
Claude receives formatted design data in context
    │
    ▼
Command proceeds with web research (HARD-GATE still enforced)
    │
    ▼
Claude merges CSV data + web research into output
```

### Secondary Data Flow: Reference Doc Lookup

```
User invokes /healer:brand
    │
    ▼
Claude loads healer:brand.md from commands/
    │
    ▼
Command instructs: "Read voice framework reference"
    │
    ▼
Claude executes via Read tool:
    Read ${CLAUDE_PLUGIN_ROOT}/references/brand/voice-framework.md
    │
    ▼
Claude receives reference doc content in context
    │
    ▼
Command applies Healer enforcement protocol to output
```

### Sync Data Flow: SessionStart Hook

```
Session starts
    │
    ▼
hooks/hooks.json triggers sync-upstream.sh
    │
    ▼
sync-upstream.sh checks ${CLAUDE_PLUGIN_DATA}/sync-state.json
    │
    ├── Last sync < 7 days ago → exit 0 (silent, no output)
    │
    ├── Last sync >= 7 days → attempt sync:
    │   │
    │   ▼
    │   Locate upstream source:
    │   1. Check local install: ~/.claude/plugins/marketplaces/ui-ux-pro-max-skill/
    │   2. If not found: skip sync, log warning
    │   │
    │   ▼
    │   Copy upstream data/ to ${CLAUDE_PLUGIN_ROOT}/data.new/
    │   │
    │   ▼
    │   Validate: check headers of key CSVs match expected schema
    │   │
    │   ├── Validation fails → rm -rf data.new/, keep existing, warn
    │   │
    │   ├── Validation passes →
    │   │   mv data/ data.backup/
    │   │   mv data.new/ data/
    │   │   rm -rf data.backup/
    │   │   Update sync-state.json timestamp
    │   │   echo "Healer data synced from UI-UX-Pro-Max (N files updated)"
    │
    ▼
stdout (if any) injected into Claude's context
```

---

## 3. COMMAND TEMPLATE PATTERN
─────────────────────────────────

### Template for NEW Commands (brand, logo, cip, banner, icon, slides)

Every new command follows this exact structure:

```markdown
---
description: "{one-line description}"
---

**ENFORCEMENT: Read and apply all protocols from `commands/_enforcement.md`
before proceeding. HARD-GATEs are non-negotiable.**

# Healer: {Command Name}

You are the Healer in **{Command} Mode**. {role description}.

## Stack Auto-Detection
Follow the Stack Auto-Detection Protocol in `_enforcement.md`.

## Input
The user provides: $ARGUMENTS

## Procedure

### Step 0: Check Prior Artifacts
{check for existing brainstorm/design/spec artifacts}

### Step 1: Data Lookup Phase (LOCAL DATABASE)
<HARD-GATE>
BEFORE any web research, query the local design database.
Run via Bash:

python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<relevant query>" --domain {domain}

If the command needs reference docs, read them via:

Read ${CLAUDE_PLUGIN_ROOT}/references/{category}/{doc}.md

This provides instant, offline, curated data. Web research supplements, not replaces.
</HARD-GATE>

### Step 2: Research Phase (WEB — still mandatory)
{standard Healer research protocol — WebSearch, Context7, WebFetch}

### Step 3: {Command-specific procedure}
{the actual work of the command, merging CSV data + web research}

### Step N: Save Artifact
{save to appropriate location}

## Anti-Rationalization Table
| Rationalization | Reality | Correction |
|----------------|---------|------------|
| "The CSV data is enough, skip web research" | CSVs are curated but may be stale; web research catches trends | Run BOTH. CSV first, web second. Merge. |
| "I'll skip the data lookup, I know the styles" | Your training data produces AI slop. The CSVs are curated by humans. | Run the search.py script. Read the results. |
{additional command-specific entries}

## Red Flags
{command-specific red flags}

## Rules
{command-specific rules — always includes enforcement compliance}
```

### Template for ENHANCED Commands (design, design-system, design-review, implement, audit)

Enhanced commands keep ALL existing content and ADD a new step between Step 0 and the current Step 1:

```markdown
### Step 0.5: Design Intelligence Lookup (NEW)

Before proceeding to web research, query the local design database for
curated recommendations:

**For style/product recommendations:**
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --design-system

**For domain-specific lookups:**
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --domain {relevant_domain}

**For stack-specific guidelines:**
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --stack {detected_stack}

Incorporate these results as a STARTING POINT. Web research (Step 1) still
applies as a HARD-GATE — the CSV data supplements but does not replace online research.

DATA LOOKUP ORDER:
  1. CSV database (instant, offline, curated) → baseline recommendations
  2. Web research (HARD-GATE enforced) → current trends, validation
  3. Merge both → final output
```

### Key Constraint: $ARGUMENTS Passthrough

Commands use `$ARGUMENTS` in their markdown, which Claude Code replaces with the user's input at invocation time. The data lookup queries should incorporate `$ARGUMENTS` where relevant.

---

## 4. SESSIONSTART HOOK DESIGN
─────────────────────────────────

### hooks/hooks.json
```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/sync-upstream.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

### scripts/sync-upstream.sh Design
```
PURPOSE: Check if upstream UI-UX-Pro-Max data has been updated since last sync.
         If so, perform atomic sync with validation and rollback.

BEHAVIOR:
  - Silent on no-op (no stdout if nothing to sync)
  - Reports only meaningful changes (stdout injected to Claude context)
  - Never blocks session start for more than 5 seconds
  - Falls back gracefully if upstream not installed

STATE FILE: ${CLAUDE_PLUGIN_DATA}/sync-state.json
  {
    "last_sync": "2026-03-29T00:00:00Z",
    "upstream_source": "local",
    "upstream_path": "~/.claude/plugins/marketplaces/ui-ux-pro-max-skill/",
    "files_synced": 76,
    "sync_frequency_days": 7
  }

VALIDATION CHECKS (before atomic swap):
  1. styles.csv header contains "Style Category"
  2. colors.csv header contains "Product Type"
  3. typography.csv header contains "Font Pairing Name"
  4. ux-guidelines.csv header contains "Category"
  5. File count in data/ >= 10 (sanity check)

ATOMIC SWAP:
  cp -r upstream_data/ data.new/
  [validate]
  mv data/ data.backup/    # step 1
  mv data.new/ data/        # step 2 (atomic rename)
  rm -rf data.backup/       # cleanup

ROLLBACK (if step 2 fails):
  mv data.backup/ data/
  rm -rf data.new/
```

---

## 5. FLOW PRESET DEFINITIONS
─────────────────────────────────

### New Built-in Presets (added to healer:flow.md)

```yaml
# In healer:flow.md preset definitions section:

identity:
  description: "Brand identity pipeline — from brand voice to design system"
  steps:
    - command: brand
      gate: interactive
    - command: logo
      gate: interactive
    - command: cip
      gate: interactive
    - command: design-system
      gate: interactive

brand-to-production:
  description: "Full brand-aware feature development"
  steps:
    - command: brand
      gate: interactive
    - command: design-system
      gate: interactive
    - command: design
      gate: interactive
    - command: implement
      gate: auto
    - command: test
      gate: must-pass
    - command: review
      gate: interactive
    - command: ship
      gate: must-pass
```

### Enhanced Existing Presets

```yaml
# visual preset ENHANCED (was: design-system → design → design-review)
visual:
  description: "Visual design pipeline with brand awareness"
  steps:
    - command: brand
      gate: interactive
    - command: design-system
      gate: interactive
    - command: design
      gate: interactive
    - command: design-review
      gate: auto

# feature preset ENHANCED (conditional: adds design-system if no DESIGN.md)
# Note: This is handled in flow logic, not YAML. The flow orchestrator
# checks for DESIGN.md existence and inserts design-system step if missing.
```

### New Custom Recipes (added to config/recipes.yaml)

```yaml
# ─────────────────────────────────────────────────
# DESIGN & BRAND FLOWS (NEW)
# ─────────────────────────────────────────────────

brand-identity:
  description: "Complete brand identity from scratch"
  steps:
    - command: brainstorm
      gate: interactive
    - command: brand
      gate: interactive
    - command: logo
      gate: interactive
    - command: icon
      gate: interactive
    - command: cip
      gate: interactive
    - command: design-system
      gate: interactive
    - command: design-review
      gate: auto

visual-full:
  description: "Full visual design pipeline with brand and review"
  steps:
    - command: brand
      gate: interactive
    - command: design-system
      gate: interactive
    - command: design
      gate: interactive
    - command: slides
      gate: interactive
    - command: design-review
      gate: auto

marketing-kit:
  description: "Marketing materials — brand, banners, slides"
  steps:
    - command: brand
      gate: interactive
    - command: logo
      gate: interactive
    - command: banner
      gate: interactive
    - command: slides
      gate: interactive

design-polish:
  description: "Design review and iteration cycle"
  steps:
    - command: design-review
      gate: auto
    - command: design
      gate: interactive
    - command: design-review
      gate: auto
```

### Updated Suggested-Next Graph

```
# Additions to the suggested-next graph in healer:flow.md:
brand         → logo, design-system, cip
logo          → icon, cip, brand
cip           → design-system, banner
banner        → slides, push
icon          → implement, push
slides        → push, ship
design-system → design, implement (existing, unchanged)
```

---

## 6. COMMAND SPECIFICATIONS (Summary)
─────────────────────────────────

### 6.1 healer:brand (NEW)
**Purpose**: Create brand voice framework, visual identity, messaging architecture
**Data sources**: `data/products.csv` (product type matching), `references/brand/*.md` (10 reference docs)
**Script call**: `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<product> <industry>" --design-system`
**Output**: Brand document with voice, tone, visual identity, messaging framework
**Artifact**: Saves to `brand-guidelines.md` in project root

### 6.2 healer:logo (NEW)
**Purpose**: Logo design guidance with 55+ styles, color psychology, industry conventions
**Data sources**: `references/design/logo-*.md` (4 reference docs)
**Script call**: None (reference doc lookup only — logos need creative guidance, not CSV search)
**Output**: Logo brief with style recommendations, color psychology, do/don't rules
**Artifact**: Saves to `docs/designs/{date}-logo-brief.md`

### 6.3 healer:cip (NEW)
**Purpose**: Corporate Identity Program — 50+ deliverables, mockup guidance
**Data sources**: `references/design/cip-*.md` (4 reference docs)
**Script call**: None (reference doc lookup only)
**Output**: CIP checklist with deliverable specifications
**Artifact**: Saves to `docs/designs/{date}-cip.md`

### 6.4 healer:banner (NEW)
**Purpose**: Banner design for 22 styles across 9+ social platforms
**Data sources**: `references/slides/banner-sizes-and-styles.md`
**Script call**: None (reference doc lookup only)
**Output**: Banner specifications with platform sizes, style recommendations
**Artifact**: Saves to `docs/designs/{date}-banners.md`

### 6.5 healer:icon (NEW)
**Purpose**: Icon design with 15 styles, SVG generation guidance
**Data sources**: `data/icons.csv`, `references/design/icon-design.md`
**Script call**: `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --domain icons`
**Output**: Icon system specification with style, library, and code examples
**Artifact**: Saves to `docs/designs/{date}-icon-system.md`

### 6.6 healer:slides (NEW)
**Purpose**: HTML presentation design with Chart.js, copywriting, strategies
**Data sources**: `references/slides/*.md` (6 reference docs)
**Script call**: `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --domain chart` (for data visualization)
**Output**: Slide deck specification + HTML preview
**Artifact**: Saves to `docs/presentations/{date}-{name}.html`

### 6.7 healer:design (ENHANCED)
**Enhancement**: Add Step 0.5 — query `data/styles.csv`, `data/products.csv`, `data/ui-reasoning.csv` BEFORE web research
**Script calls**:
  - `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<feature> <product_type>" --design-system`
  - `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --domain style`

### 6.8 healer:design-system (ENHANCED)
**Enhancement**: Add Step 0.5 — query `data/colors.csv` (161 palettes), `data/typography.csv` (57 pairings), `data/stacks/{detected_stack}.csv`
**Script calls**:
  - `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<product_type> <brand_keywords>" --design-system`
  - `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --domain typography`
  - `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --stack {detected_stack}`

### 6.9 healer:design-review (ENHANCED)
**Enhancement**: Embed UX guidelines from `data/ux-guidelines.csv` into the 7-dimension checklist. Each dimension cross-references relevant CSV rules.
**Script calls**:
  - `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --domain ux`

### 6.10 healer:implement (ENHANCED)
**Enhancement**: When implementing UI features, look up stack-specific guidelines before coding
**Script calls**:
  - `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --stack {detected_stack}`

### 6.11 healer:audit (ENHANCED)
**Enhancement**: Add UX audit dimensions — animation, navigation, forms, touch interaction rules
**Script calls**:
  - `python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "accessibility touch animation" --domain ux`

---

## DESIGN DECISIONS
─────────────────────────────────

| # | Decision | Choice | Reasoning | Inspired by |
|---|----------|--------|-----------|-------------|
| D1 | Data directory location | `data/` at plugin root | Mirrors UI-UX-Pro-Max's `src/ui-ux-pro-max/data/` structure. core.py uses `Path(__file__).parent.parent / "data"` — keeping scripts/ and data/ as siblings preserves this relative path. | UI-UX-Pro-Max source code |
| D2 | Python scripts reuse | Copy scripts as-is, only update DATA_DIR path | The BM25 search engine is tested, working code. Rewriting it adds risk for zero benefit. | Research finding: "Don't rewrite proven code" |
| D3 | Command format | Healer-native markdown with enforcement | User explicitly chose Healer-native over faithful copy. Every command gets HARD-GATEs, anti-rationalization, and verification protocol. | Brainstorm decision (user trade-off choice) |
| D4 | Hook location | `hooks/hooks.json` at plugin root | Standard Claude Code plugin hook location per official docs. | Claude Code plugins reference |
| D5 | Sync state storage | `${CLAUDE_PLUGIN_DATA}/sync-state.json` | CLAUDE_PLUGIN_DATA persists across plugin updates. CLAUDE_PLUGIN_ROOT does not. | Research finding RES-20260329-CSVP |
| D6 | Sync source | Local install path (not GitHub API) | Faster, works offline, no auth needed. The user has UI-UX-Pro-Max installed locally. | Brainstorm decision (REQ-F05) |
| D7 | Sync validation | Header check on 4 key CSVs | core.py's CSV_CONFIG defines expected columns — checking headers catches schema drift without parsing entire files. | Research finding RES-20260329-CSVP |
| D8 | New commands as commands/ not skills/ | Use `commands/` directory | Healer uses commands/ exclusively. Mixing commands/ and skills/ adds complexity. When Anthropic deprecates commands/, migrate all at once. | Existing Healer convention |
| D9 | Data lookup order | CSV first, web second, merge | CSV gives instant curated baseline. Web research (HARD-GATE) adds current trends. Merging both gives best-of-both-worlds output. | Brainstorm REQ-NF04 |
| D10 | Flow presets | 2 new built-in + 4 new recipes | Built-in for common paths (identity, brand-to-production). Recipes for specialized paths (visual-full, marketing-kit). Matches Healer's existing preset/recipe split. | Existing Healer flow architecture |

## TRADE-OFFS ACCEPTED
─────────────────────────────────

1. **Repo size increase**: Adding 76 CSVs (~1.3MB total) increases the repo significantly. Chose this over symlinks because plugin cache isolation prevents external references. Mitigation: `.gitignore` the largest files if needed.

2. **Python dependency**: Commands shell out to Python scripts. If Python is not installed, data lookups silently fail. Chose this over rewriting search in bash because BM25 requires math operations. Mitigation: Commands fall back to web-research-only mode if Python unavailable.

3. **Single sync source**: Only syncs from local UI-UX-Pro-Max install, not GitHub. Chose this for speed and offline capability. Mitigation: Can add GitHub sync as a future enhancement.

4. **SessionStart overhead**: Sync hook runs on every session start. Chose 7-day frequency check to minimize impact. Mitigation: Hook exits in <100ms when no sync needed (just reads a JSON timestamp).

5. **Schema validation is shallow**: Only checks CSV headers, not data integrity. Chose this for speed over thorough validation. Mitigation: If data corruption occurs, user can re-trigger sync manually.

## REQUIREMENTS_TRACED
─────────────────────────────────

| Brainstorm Requirement | Design Decision | How Addressed |
|-----------------------|-----------------|---------------|
| REQ-F01 Copy CSV data files | D1 (data/ at plugin root) | data/ directory mirrors upstream structure |
| REQ-F02 Copy reference docs | Directory layout (references/) | references/ with 5 subdirectories, 42 docs |
| REQ-F03 Copy Python scripts | D2 (scripts reuse) | scripts/ with search.py, core.py, design_system.py |
| REQ-F04 SessionStart hook | D4, D5 (hook + sync state) | hooks/hooks.json + sync-upstream.sh |
| REQ-F05 Dual sync source | D6 (local install path) | Local-first; GitHub as future enhancement |
| REQ-F06 healer:brand | Section 6.1 | New command reading products.csv + brand references |
| REQ-F07 healer:logo | Section 6.2 | New command reading logo reference docs |
| REQ-F08 healer:cip | Section 6.3 | New command reading CIP reference docs |
| REQ-F09 healer:banner | Section 6.4 | New command reading banner reference doc |
| REQ-F10 healer:icon | Section 6.5 | New command reading icons.csv + icon reference doc |
| REQ-F11 healer:slides | Section 6.6 | New command reading slides references + charts.csv |
| REQ-F12 healer:design enhanced | Section 6.7 | Step 0.5 added with styles/products/reasoning CSVs |
| REQ-F13 healer:design-system enhanced | Section 6.8 | Step 0.5 added with colors/typography/stacks CSVs |
| REQ-F14 healer:design-review enhanced | Section 6.9 | UX guidelines embedded in 7-dimension checklist |
| REQ-F15 healer:implement enhanced | Section 6.10 | Stack-specific guidelines lookup added |
| REQ-F16 healer:audit enhanced | Section 6.11 | UX audit dimensions added |
| REQ-F17 New flow presets | Section 5 (identity, brand-to-production) | 2 built-in presets + 4 custom recipes |
| REQ-F18 Enhanced feature preset | Section 5 (conditional design-system) | Flow logic checks for DESIGN.md |
| REQ-F19 Help system update | Design scope | healer:help.md updated with new commands |
| REQ-F20 healer.md update | Design scope | Sub-command listing updated |
| REQ-NF01 Enforcement protocol | D3 (Healer-native format) | All commands include HARD-GATEs + anti-rationalization |
| REQ-NF02 Sync < 5 seconds | D4, D6 (local sync + frequency check) | Timestamp check exits in <100ms on no-op |
| REQ-NF03 CSVs at runtime | D1, D9 (data/ dir + lookup order) | Commands call search.py via Bash at runtime |
| REQ-NF04 Data lookup order | D9 (CSV first, web second) | Embedded in command template pattern |
| REQ-NF05 Healer output format | D3 (Healer-native) | All commands produce Healer-format output |
| REQ-C01 Zero deletions | Directory layout | All existing files unchanged; only additions |
| REQ-C02 _enforcement.md untouched | Explicit constraint | No modifications to enforcement protocol |
| REQ-C03 CLAUDE_PLUGIN_ROOT | D1, template pattern | All paths use ${CLAUDE_PLUGIN_ROOT} |
| REQ-C04 Valid CSVs after sync | D7 (header validation) | 4-CSV header check before atomic swap |
| REQ-C05 MIT license | LICENSE file | Attribution in README.md |

## OPEN QUESTIONS
─────────────────────────────────

1. **Plugin manifest**: Healer currently has no `.claude-plugin/plugin.json`. Should we create one to formally register hooks and component paths? Or continue using `install.sh`?

2. **Python availability check**: Should the sync hook verify Python 3 is installed before attempting to run? Or assume it's always available?

3. **google-fonts.csv (728K)**: This is the largest single file. Should it be included in the initial fork or deferred?

## DESIGN REVIEW CHECKLIST
===================================

Since this is a system architecture design (not UI), the 7-dimension checklist is adapted:

1. **INFORMATION ARCHITECTURE**
   [x] Directory hierarchy is logical and self-documenting
   [x] Command naming follows existing Healer conventions
   [x] Data flow is clear and traceable
   Score: **PASS** — Layout mirrors upstream for script compatibility while following Healer conventions

2. **INTERACTION STATES** (adapted: failure modes)
   [x] Sync failure handled (rollback to backup)
   [x] Python unavailable handled (fall back to web-only)
   [x] Upstream not installed handled (skip sync silently)
   [x] CSV schema drift handled (validation blocks swap)
   [x] Network unavailable handled (local-only sync)
   Score: **PASS** — All failure modes have defined recovery paths

3. **USER JOURNEY COMPLETENESS**
   [x] Entry points: individual commands, flow presets, flow recipes
   [x] Happy path: command → CSV lookup → web research → output
   [x] Error recovery: sync rollback, Python fallback
   [x] Edge cases: first use (no prior sync), stale data, missing upstream
   Score: **PASS** — Complete journey from install to daily use

4. **AI SLOP DETECTION** (adapted: architectural slop)
   [x] No unnecessary abstractions (scripts reused as-is)
   [x] No premature optimization (simple copy + sync)
   [x] No over-engineering (header check, not full schema validation)
   [x] Architecture has clear rationale, not template-default
   Score: **PASS** — Deliberately simple; complexity only where justified

5. **DESIGN SYSTEM ALIGNMENT** (adapted: convention alignment)
   [x] New commands follow Healer enforcement protocol
   [x] New flow presets follow existing gate operator conventions
   [x] New recipes follow existing YAML format
   [x] File naming matches existing patterns
   Score: **PASS** — All additions follow established Healer patterns

6. **RESPONSIVE CONSIDERATIONS** (adapted: portability)
   [x] Works on macOS (primary target)
   [x] sync-upstream.sh uses POSIX-compatible commands
   [x] Python 3 is the only non-standard dependency
   [x] No platform-specific assumptions in CSV parsing
   Score: **PASS** — Portable across platforms with Python 3

7. **ACCESSIBILITY** (adapted: maintainability)
   [x] Single maintainer can update all components
   [x] Sync hook reduces manual maintenance burden
   [x] CSV schema validation catches breaking changes
   [x] Clear documentation for new contributors
   Score: **PASS** — Designed for single-maintainer sustainability

**OVERALL: 7/7 PASS**

===================================

VERIFICATION NOTE: Implementation should be verified against this design
document. Compare the built plugin against each design decision (D1-D10)
and the directory layout to confirm structural fidelity. Run each command
at least once to verify data flow works end-to-end.

Next steps:
- /healer:spec — write technical specification with acceptance tests
- /healer:plan — create implementation plan with task tracking
- /healer:strategy — CEO-level review of the design
===================================
