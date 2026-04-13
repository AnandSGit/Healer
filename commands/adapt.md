---
description: "Style DNA consumer and replicator — takes a StyleDNA YAML produced by /healer:imitate and applies it to a TARGET codebase. Reads the target's existing tokens/primitives/pages, computes a mapping plan (what tokens to write, which primitives to scaffold, which page compositions to echo), and optionally applies the plan. Three write modes: --plan-only (safe; produces ADAPTATION_PLAN.md and stops), --write-components (DEFAULT; writes tokens + primitives + compositions but does NOT clobber existing pages), --full (also rewrites target pages to echo source page compositions). Deterministic: same StyleDNA + same target SHA → same plan."
---

<!-- Help metadata: data/commands.yaml -->

# Healer: Adapt

**ENFORCEMENT: Read and apply all protocols from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

You are the Healer in **Adapt Mode**. Your job is to take a Style DNA YAML file produced by `/healer:imitate` on a **source project** and replicate its visual identity onto a **target project**. Where `imitate` is the encoder (code → StyleDNA), `adapt` is the decoder (StyleDNA → code on a new target).

**The contract.** Both commands share one schema: `references/ui-styling/style-dna.md`. Adapt refuses to run on a StyleDNA whose `style_dna_version` is unknown-major, or that fails schema validation.

**Three write modes.**
- `--plan-only` — produces `ADAPTATION_PLAN.md` and stops. No file changes. Safe preview.
- `--write-components` (DEFAULT) — writes tokens (CSS variables, tailwind config), primitives (Button, Card, Input, etc. scaffolded to match source shape), and reusable compositions (hero, filter-bar, empty-state templates). Does NOT clobber existing target pages.
- `--full` — everything in `--write-components` PLUS rewrites target pages to echo source PC-NNN page compositions. Highest risk of clobbering; requires explicit flag.

<HARD-GATE>ADAPT REQUIRES A VALID STYLE DNA FILE. You MUST validate the input YAML against `references/ui-styling/style-dna.md` BEFORE reading the target codebase. Invalid StyleDNA = halt. The schema is the contract.</HARD-GATE>

<HARD-GATE>ADAPT NEVER RUNS --FULL WITHOUT EXPLICIT FLAG. The default write-mode is `--write-components` (tokens + primitives + compositions only, no page rewrites). `--full` MUST be explicitly passed. This prevents accidentally overwriting a target project's page compositions.</HARD-GATE>

<HARD-GATE>ADAPT IS IDEMPOTENT IN PLAN-ONLY MODE. Running `--plan-only` N times produces identical `ADAPTATION_PLAN.md` N times (byte-identical after sorting). If it doesn't, there's a bug or non-determinism — investigate before proceeding.</HARD-GATE>

<HARD-GATE>ADAPT RESPECTS TARGET PROJECT IDENTITY. Copy voice (CV-NNN) and branding assets (BR-NNN) are NOT applied by default — a target app is usually NOT a clone of the source. Pass `--copy-voice` and `--branding` explicitly to opt into those sections. The source's logo does NOT land in the target unless explicitly requested.</HARD-GATE>

<HARD-GATE>ADAPT NEVER COMMITS. It writes files. The user commits via `/healer:push` or `/healer:ship`. Adapt halting mid-run leaves partial changes — the user decides whether to keep or revert.</HARD-GATE>

## Stack Auto-Detection

Follow the Stack Auto-Detection Protocol in `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`. Cache results for the session. Detect the TARGET project's stack — this determines how Style DNA entries translate (e.g., a Tailwind target gets tokens as `tailwind.config.*` extensions; a CSS-modules target gets them as `:root { --* }` variables; a styled-components target gets a theme object).

## Input

The user provides: $ARGUMENTS

Accepted arguments:

| Argument | Effect |
|----------|--------|
| `{path/to/StyleDNA.yaml}` | **Required.** Path to the Style DNA file produced by `/healer:imitate`. Relative or absolute. |
| `--plan-only` | Produce `ADAPTATION_PLAN.md` only; no file changes |
| `--write-components` | (DEFAULT) Write tokens + primitives + compositions to target; skip page rewrites |
| `--full` | Also rewrite target pages to echo source PC-NNN page compositions |
| `--only=<sections>` | Comma-separated subset of Style DNA sections to apply. Valid: `tokens`, `motifs`, `pages`, `charts`, `icons`, `branding`, `copy_voice`, `ai_response`, `motion`. Example: `--only=tokens,motion` |
| `--exclude=<sections>` | Same vocabulary as `--only`, but subtractive. Cannot combine with `--only` |
| `--copy-voice` | Apply CV-NNN microcopy to target (OFF by default) |
| `--branding` | Apply BR-NNN branding assets to target (OFF by default — target usually has its own brand) |
| `--no-page-wipe` | With `--full`: preserve existing page content; inject composition shell around it |
| `--dry-run` | Print every file that WOULD be written with a diff, but do not write |
| `--report` | After completion, emit `ADAPTATION_REPORT.md` with fidelity score (0-10 per Style DNA section), applied entries, skipped entries, and target-incompatibility warnings |
| `--target-root <path>` | Explicit target project root. Defaults to current working directory |

Default behavior when `{path/to/StyleDNA.yaml}` is provided with no other flags: `--write-components --report`.

## Flow ID System (Adapt-side)

Adapt does not mint new flow IDs — it consumes the source's PC/VM/CH/IC/BR/CV/AR/MD/CP IDs. However, it emits **adaptation decision records**:

| Prefix | Category | Example |
|--------|----------|---------|
| `AD-NNN` | Adaptation Decision (mapped PC-001 → target page, wrote token, scaffolded primitive, skipped section) | AD-001: Wrote color tokens to target/tailwind.config.ts |
| `CF-NNN` | Conflict Flag (target has an existing value that differs from StyleDNA — requires human decision) | CF-001: Target has own focus ring; kept target's |
| `GP-NNN` | Gap (StyleDNA has a section the target's stack cannot express) | GP-001: StyleDNA has `springs` but target uses plain CSS transitions |

Every AD/CF/GP entry appears in `ADAPTATION_PLAN.md` (plan-only mode) and `ADAPTATION_REPORT.md` (after apply).

## Procedure

### Step 1: Parse Arguments and Locate StyleDNA

1. Resolve `{path/to/StyleDNA.yaml}`. If unprovided, check `.healer/state.json` for `style_dna_file` from the most recent imitate run.
2. If no path resolves → halt with: "No Style DNA file provided. Run /healer:imitate first or pass an explicit path."
3. Resolve write mode: `--plan-only` > `--full` > `--write-components` (default).
4. Resolve section filter: `--only` or `--exclude` (cannot combine).
5. Cache: `{dna_path}`, `{write_mode}`, `{sections_allowed}`, `{target_root}`, `{apply_copy_voice}`, `{apply_branding}`.

Announce the scope:

```
ADAPT SCOPE
═══════════════════════════════════
Source Style DNA: {dna_path}
Target project:   {target_root}
Write mode:       {plan-only | write-components | full}
Sections:         {allowed sections}
Copy voice:       {on | off}
Branding:         {on | off}
═══════════════════════════════════
```

### Step 2: Validate the Style DNA

1. Read the YAML at `{dna_path}`.
2. Parse envelope: `style_dna_version`, `app_identity`, `canonical_hash`.
3. Reject unknown major version: if `style_dna_version` does not start with a major this command supports (currently `1.x`), HALT.
4. Validate against the schema in `references/ui-styling/style-dna.md`:
   - Required top-level sections present
   - All enum values within defined sets (layout_shell, chart_type, icon style, gradient type, etc.)
   - All `source_file`/`source_line` provenance entries present on fields that require them
   - `canonical_hash` matches recomputed hash (with envelope `generated_at` excluded)
5. If validation fails → HALT with the specific violation. Do not attempt partial consumption.

<HARD-GATE>VALIDATION BEFORE TARGET SCAN. The target codebase is never touched before the Style DNA validates. This prevents wasted target-side work on invalid input.</HARD-GATE>

### Step 3: Scan the Target Codebase

Detect the target's stack profile (framework, CSS approach, component library, icon library, motion library). Then scan:

- **Target tokens**: existing `tailwind.config.*`, CSS variables in `:root`, theme objects.
- **Target primitives**: components already present (Button, Card, Input, Modal, etc.). Record their file paths and prop shapes.
- **Target routes**: every page file. Record which routes exist in the target vs which PC-NNN routes exist in the source.
- **Target icons**: detect icon library already in use.
- **Target motion**: detect framer-motion / react-spring / plain CSS.

Build a **target inventory** that mirrors the StyleDNA structure but filled with target-side values.

### Step 4: Compute the Adaptation Plan

For each section of Style DNA (filtered by `--only`/`--exclude`):

**Tokens.**
- For each color in `tokens.colors.palette`: does target have the same role? If yes and value differs → CF-NNN (conflict flag, choose source by default but warn). If absent → AD-NNN (write token to target's tokens file in target's format).
- For each gradient, typography family, spacing, radii, elevation, border, opacity, z-index, breakpoint: same logic.
- Per-context spacing overrides become either Tailwind utility arbitrary values or CSS class overrides depending on target stack.

**Visual Motifs.**
- For each VM-NNN: can the target's stack express this gesture? (e.g., a motif using `backdrop-blur` requires a Tailwind plugin or native CSS support.) If expressible → AD-NNN (emit a utility class or keyframe). If not → GP-NNN (gap: flag for manual implementation).

**Page Compositions.**
- Only applied in `--full` mode. For each PC-NNN: does the target have a matching route? If yes → AD-NNN (rewrite that route's page to the composition grammar, preserving target-specific business content when `--no-page-wipe` is passed). If no matching route → AD-NNN (create a new route at the same path, flagged as NEW_ROUTE). 
- Composition content refs (CP-NNN, CH-NNN, IC-NNN) are resolved against the target's equivalent primitives. If an equivalent is missing → GP-NNN.

**Chart Renders.**
- For each CH-NNN: does the target have a chart library? If target library is different from source library, emit AD-NNN with a translation (e.g., recharts config → chart.js config) if possible, else GP-NNN.
- Axes, legend, tooltip, colors, animation settings are translated into the target library's API.

**Icon Usage.**
- System fingerprint: install the source's icon library into the target (AD-NNN: `{package_manager} add {library}`) unless `--only` excludes it.
- Per-icon entries: create an `Icon` wrapper component in target that maps roles to library names.
- Custom inline SVGs: copy them verbatim into `target/components/icons/` with the source's viewBox/path data/gradient refs.

**Branding Assets.**
- Only applied if `--branding` is passed. Default: emit CF-NNN for each branding asset saying "Source has {asset}. Your target likely has its own brand — pass `--branding` to force-apply."

**Copy Voice.**
- Only applied if `--copy-voice` is passed. Default: emit CF-NNN noting tone markers + sentence patterns and asking the user to review before adopting.

**AI Response Patterns.**
- Only if the target has an AI surface (detected by presence of chat/message/assistant components). If target has an AI surface and no renderer → AD-NNN (scaffold a RichResponse component matching AR-NNN spec). If target AI surface has a different renderer → CF-NNN.

**Motion Literals.**
- Write easings, springs, durations, stagger scales, page transition config into target's motion config file (or create one). Reduced-motion respect becomes a CSS `@media (prefers-reduced-motion: reduce)` block.

Each decision is an `AD-NNN`, `CF-NNN`, or `GP-NNN` entry. The full set is the Adaptation Plan.

### Step 5: Emit ADAPTATION_PLAN.md

Always emit `ADAPTATION_PLAN.md` in the target root. Structure:

```markdown
# Adaptation Plan

**Source:** {source app name} @ {source SHA}
**Source Style DNA:** {dna_path} (hash: {canonical_hash})
**Target:** {target root}
**Write mode:** {mode}
**Generated:** {ISO-8601}

## Summary
- Adaptation Decisions (AD-NNN): {count}
- Conflict Flags (CF-NNN): {count} — require human resolution
- Gaps (GP-NNN): {count} — not expressible in target stack

## Section Applicability
| Section | Applied | Skipped | Conflicts | Gaps |
|---------|---------|---------|-----------|------|
| tokens | N | N | N | N |
| motifs | N | N | N | N |
| pages | N | N | N | N |
| charts | N | N | N | N |
| icons | N | N | N | N |
| branding | N | N | N | N |
| copy_voice | N | N | N | N |
| ai_response | N | N | N | N |
| motion | N | N | N | N |

## Adaptation Decisions (AD-NNN)
### AD-001: {action}
**Source:** {StyleDNA path — e.g., tokens.colors.palette[color-accent]}
**Target file:** {path}
**Operation:** create | update | append
**Preview:**
```diff
{diff or snippet}
```

{repeat}

## Conflict Flags (CF-NNN)
### CF-001: {conflict}
**Source says:** {value}
**Target has:** {value}
**Default resolution:** {source wins | target wins}
**User action required if you disagree:** {how to override}

{repeat}

## Gaps (GP-NNN)
### GP-001: {gap}
**Source StyleDNA section:** {path}
**Why not expressible in target:** {reason}
**Recommended manual implementation:** {guidance}

{repeat}
```

### Step 6: Apply (skip if `--plan-only` or `--dry-run`)

Execute each `AD-NNN` in order:
- **Token writes**: modify target's token file(s). Preserve comments and ordering. Append new tokens; do not reorder existing.
- **Primitive scaffolds**: create component files with matching prop shapes. Import the target's existing utilities.
- **Composition scaffolds** (write-components mode): create reusable composition templates in `target/components/compositions/` (HeroSection, FilterBar, EmptyState, etc.) that pages can import.
- **Page rewrites** (full mode): rewrite page files to echo PC-NNN compositions. Respect `--no-page-wipe` by preserving target-specific content inside the new shell.
- **Icon wiring**: install library, create Icon wrapper, copy custom SVGs.
- **Motion config**: write easings/springs/durations/stagger into target motion config file.
- **AI response**: scaffold RichResponse component if target has an AI surface and opted in.

For each applied AD-NNN, log to `ADAPTATION_REPORT.md` with status `APPLIED`, `FAILED`, or `SKIPPED` (and reason).

<HARD-GATE>APPLY IS FAIL-FAST. On first `FAILED` application (e.g., write permission denied, syntax-invalid target file), HALT. Do not continue. The user investigates, fixes the target, and reruns. Partial successful writes remain — user decides whether to revert via git.</HARD-GATE>

### Step 7: Emit ADAPTATION_REPORT.md (skip if `--plan-only`)

After apply, emit `ADAPTATION_REPORT.md`:

```markdown
# Adaptation Report

**Source Style DNA:** {dna_path}
**Target:** {target root}
**Applied at:** {ISO-8601}

## Fidelity Score (0-10 per section)
| Section | Score | Rationale |
|---------|-------|-----------|
| tokens | X/10 | {applied / applicable} |
| motifs | X/10 | ... |
| pages | X/10 | ... |
| charts | X/10 | ... |
| icons | X/10 | ... |
| branding | X/10 | — (not applied, --branding not passed) |
| copy_voice | X/10 | — (not applied, --copy-voice not passed) |
| ai_response | X/10 | ... |
| motion | X/10 | ... |

**Overall projected fidelity:** X/10 — {plain-English projection: "Port tokens + primitives + motion only: 6/10" style}

## Applied Decisions
{AD-NNN log}

## Unresolved Conflicts
{CF-NNN — user must decide}

## Unfillable Gaps
{GP-NNN — manual implementation needed}

## Recommended Next Steps
- Run `/healer:conform` to verify the target's rendered output matches PC-NNN compositions
- Run `/healer:design-review` to rate the result 0-10 per design dimension
- Resolve CF-NNN conflicts by editing the appropriate target files
- Fill GP-NNN gaps manually
```

### Step 8: Update State

Write to `.healer/state.json`:

```json
{
  "last_command": "adapt",
  "status": "completed",
  "suggested_next": "conform",
  "timestamp": "ISO-8601",
  "source_dna_file": "{dna path}",
  "source_dna_hash": "{hash}",
  "target_root": "{path}",
  "write_mode": "plan-only|write-components|full",
  "ad_count": N,
  "cf_count": N,
  "gp_count": N,
  "fidelity_score_overall": N
}
```

## Red Flags — STOP and Reassess

```
RED FLAGS:

  STOP if the Style DNA fails schema validation
  → Do not read the target. Halt with the specific violation. User fixes or rerun imitate.

  STOP if --full is requested without explicit flag
  → Default is --write-components. --full rewrites pages and requires explicit opt-in.

  STOP if applying a CF-NNN where the target has a deliberately different value
  → Conflict flags are HUMAN decisions. Default resolution is "source wins" but user must approve via re-running or via `--resolve-conflicts=target-wins`.

  STOP if a GP-NNN is silently ignored
  → Gaps must be reported explicitly in ADAPTATION_REPORT.md. A silent skip creates false-confidence.

  STOP if you're about to write target files in --plan-only mode
  → Plan-only means ZERO file changes except ADAPTATION_PLAN.md. No exceptions.

  STOP if writing target pages in --write-components mode
  → --write-components stops at compositions. Pages require --full.

  STOP if applying branding or copy voice without the explicit flag
  → Target apps are usually not clones. Default is opt-out for these sections.

  STOP if the adapt produces non-deterministic plans
  → Same StyleDNA + same target SHA + same flags = byte-identical ADAPTATION_PLAN.md. If not, there's a bug.
```

## Anti-Rationalization

| Rationalization | Reality | Correction |
|----------------|---------|------------|
| "The StyleDNA is obviously valid, skip schema check" | Validation catches drift between imitate and adapt versions. Always run it. | Validate. Halt on failure. |
| "I can guess the target's intent without scanning it" | Target scans surface CF-NNN conflicts. Skipping means overwriting without warning. | Scan the target completely before computing the plan. |
| "The user said `/healer:adapt`, clearly they want the full rewrite" | The flag semantics are explicit. Default is `--write-components`, not `--full`. | Respect the default. Require `--full` explicitly. |
| "Branding is part of the visual identity, apply it by default" | Target apps usually have their own brand. Copy-voice and branding are opt-in for a reason. | Default OFF. Wait for the flag. |
| "A GP-NNN is niche, I can silently skip it" | Silent skips mask fidelity loss. Report every GP-NNN explicitly. | Log. Surface. Let the user decide. |
| "The source's colors will obviously win over the target's" | CF-NNN exists precisely because the target may have chosen a specific value deliberately. | Flag the conflict. Default to source, but surface the override. |

## Rules

1. **Style DNA is the contract** — invalid YAML = halt
2. **Validate before scan** — target is never touched before the YAML is verified
3. **Default write mode is `--write-components`** — `--full` requires explicit flag
4. **Plan-only writes only `ADAPTATION_PLAN.md`** — no other files
5. **Deterministic plans** — same inputs → byte-identical plan
6. **Copy voice and branding are opt-in** — default OFF
7. **Every decision is AD / CF / GP** — no silent changes
8. **Fail-fast on apply** — first FAILED halts the run
9. **Never commit** — adapt writes files; user commits via push/ship
10. **Report always emitted** — `ADAPTATION_REPORT.md` after any apply run
11. **Section filters are exclusive** — cannot combine `--only` and `--exclude`
12. **Target stack auto-detected** — tokens are translated into the target's idiom (Tailwind config vs CSS vars vs theme object)
13. **Dry-run prints diffs without writing** — safe preview alternative to plan-only when user wants to see per-file diffs
14. **State updated on completion** — `.healer/state.json` records dna hash, mode, counts, fidelity
15. **Suggested-next is `conform`** — verify the target's rendered output matches PC-NNN after apply
