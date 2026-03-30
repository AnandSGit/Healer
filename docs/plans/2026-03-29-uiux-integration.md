# Implementation Plan: UI-UX-Pro-Max Integration into Healer

## Metadata
- **Date**: 2026-03-29
- **Stack**: Claude Code Plugin (Markdown + Python 3 + CSV + Bash)
- **Estimated tasks**: 29 total
- **AI-assisted time**: ~13 hours
- **Traditional estimate**: ~11.5 days (92 hours)
- **Compression ratio**: ~7x overall
- **Research sources**: 15+ across all ideate phases
- **Requirements traced**: 22 FRs + 4 NFRs from spec

## Requirements Registry (from spec FR-1 through FR-22)
- REQ-1: Data directory with all CSVs — source: FR-1/REQ-F01
- REQ-2: Reference documents — source: FR-2/REQ-F02
- REQ-3: Python search scripts — source: FR-3/REQ-F03
- REQ-4: SessionStart sync hook — source: FR-4/REQ-F04
- REQ-5: Plugin manifest — source: FR-5
- REQ-6: healer:brand command — source: FR-6/REQ-F06
- REQ-7: healer:logo command — source: FR-7/REQ-F07
- REQ-8: healer:cip command — source: FR-8/REQ-F08
- REQ-9: healer:banner command — source: FR-9/REQ-F09
- REQ-10: healer:icon command — source: FR-10/REQ-F10
- REQ-11: healer:slides command — source: FR-11/REQ-F11
- REQ-12: healer:design enhanced — source: FR-12/REQ-F12
- REQ-13: healer:design-system enhanced — source: FR-13/REQ-F13
- REQ-14: healer:design-review enhanced — source: FR-14/REQ-F14
- REQ-15: healer:implement enhanced — source: FR-15/REQ-F15
- REQ-16: healer:audit enhanced — source: FR-16/REQ-F16
- REQ-17: Flow presets (identity, brand-to-production) — source: FR-17
- REQ-18: Visual preset enhanced — source: FR-18
- REQ-19: Flow recipes (4 new) — source: FR-19
- REQ-20: Help system update — source: FR-20
- REQ-21: healer.md update — source: FR-21
- REQ-22: Suggested-next graph update — source: FR-22

## File Map
========================================

### CREATE:
| File | Purpose | Depends On | Traces |
|------|---------|------------|--------|
| `.claude-plugin/plugin.json` | Plugin manifest | Nothing | REQ-5 |
| `data/*.csv` (14 core files) | Design intelligence CSVs | Nothing | REQ-1 |
| `data/stacks/*.csv` (15 files) | Stack-specific guidelines | Nothing | REQ-1 |
| `references/brand/*.md` (10 files) | Brand reference docs | Nothing | REQ-2 |
| `references/design/*.md` (10 files) | Design reference docs | Nothing | REQ-2 |
| `references/design-system/*.md` (7 files) | Design system refs | Nothing | REQ-2 |
| `references/ui-styling/*.md` (7 files) | UI styling refs | Nothing | REQ-2 |
| `references/slides/*.md` (8 files) | Slides reference docs | Nothing | REQ-2 |
| `scripts/search.py` | BM25 search entry point | Nothing | REQ-3 |
| `scripts/core.py` | CSV config + search logic | Nothing | REQ-3 |
| `scripts/design_system.py` | Design system generation | Nothing | REQ-3 |
| `scripts/sync-upstream.sh` | SessionStart sync script | REQ-3 | REQ-4 |
| `hooks/hooks.json` | Hook registration | sync-upstream.sh | REQ-4 |
| `commands/healer:brand.md` | Brand command | REQ-1, REQ-2, REQ-3 | REQ-6 |
| `commands/healer:logo.md` | Logo command | REQ-2 | REQ-7 |
| `commands/healer:cip.md` | CIP command | REQ-2 | REQ-8 |
| `commands/healer:banner.md` | Banner command | REQ-2 | REQ-9 |
| `commands/healer:icon.md` | Icon command | REQ-1, REQ-2, REQ-3 | REQ-10 |
| `commands/healer:slides.md` | Slides command | REQ-1, REQ-2, REQ-3 | REQ-11 |

### MODIFY:
| File | What Changes | Traces |
|------|-------------|--------|
| `commands/healer:design.md` | Add Step 0.5 (CSV lookup) | REQ-12 |
| `commands/healer:design-system.md` | Add Step 0.5 (colors/typography/stacks) | REQ-13 |
| `commands/healer:design-review.md` | Add UX guidelines to 7-dimension checklist | REQ-14 |
| `commands/healer:implement.md` | Add stack-specific guidelines | REQ-15 |
| `commands/healer:audit.md` | Add UX audit dimensions | REQ-16 |
| `commands/healer:flow.md` | Add identity, brand-to-production, update visual | REQ-17, REQ-18, REQ-22 |
| `commands/healer:help.md` | Document all new commands/presets | REQ-20 |
| `commands/healer.md` | Add 6 new sub-commands to listing | REQ-21 |
| `config/recipes.yaml` | Add 4 new flow recipes | REQ-19 |
| `README.md` | Document new capabilities + MIT attribution | REQ-5 |

========================================

## Implementation Order

### Wave 1: Infrastructure + Pattern Validation (~3 hours AI-assisted / 4 days human)

**Purpose**: Set up all infrastructure and validate the integration pattern with 2 commands.

**1.1** Create `.claude-plugin/plugin.json` — traces: REQ-5
  - Write manifest with name, version "6.0.0", commands, hooks paths
  - Verify: `cat .claude-plugin/plugin.json | python3 -c "import json,sys; json.load(sys.stdin); print('valid')"`

**1.2** Copy CSV data files from UI-UX-Pro-Max — traces: REQ-1
  - Copy `~/.claude/plugins/marketplaces/ui-ux-pro-max-skill/src/ui-ux-pro-max/data/` → `data/`
  - Verify: `ls data/*.csv | wc -l` returns ≥14; `ls data/stacks/*.csv | wc -l` returns ≥14

**1.3** Copy reference documents from UI-UX-Pro-Max — traces: REQ-2
  - Copy skill reference docs → `references/` with 5 subdirectories
  - Verify: `find references/ -name "*.md" | wc -l` returns ≥42

**1.4** Copy Python scripts from UI-UX-Pro-Max — traces: REQ-3
  - Copy search.py, core.py, design_system.py → `scripts/`
  - Verify: `python3 scripts/search.py "test" --domain style` returns results

**1.5** Fix core.py DATA_DIR path if needed — traces: REQ-3
  - Verify `Path(__file__).parent.parent / "data"` resolves to `data/` from `scripts/`
  - If not, update DATA_DIR
  - Verify: `python3 -c "from scripts.core import DATA_DIR; print(DATA_DIR)"` or run search

**1.6** Create `scripts/sync-upstream.sh` — traces: REQ-4
  - Implement per spec Section 6.3 pseudocode
  - Include: staleness check, upstream detection, header validation, atomic swap, version pin
  - `chmod +x scripts/sync-upstream.sh`
  - Verify: `bash scripts/sync-upstream.sh` exits 0

**1.7** Create `hooks/hooks.json` — traces: REQ-4
  - SessionStart hook pointing to sync-upstream.sh
  - Verify: JSON is valid, path uses ${CLAUDE_PLUGIN_ROOT}

**1.8** Write `commands/healer:brand.md` — traces: REQ-6
  - Follow command template from design Section 6.4
  - Include: enforcement, HARD-GATEs, Step 0.5 (CSV + reference lookup), web research, anti-rationalization
  - Verify: File follows Healer command conventions (frontmatter, enforcement header)

**1.9** Enhance `commands/healer:design-system.md` — traces: REQ-13
  - Insert Step 0.5 between existing Step 0 and Step 1
  - Add search.py calls for colors, typography, stack-specific
  - Verify: Diff shows ONLY additions, no deletions of existing content

**1.10** End-to-end test: invoke healer:brand and healer:design-system — traces: REQ-6, REQ-13
  - Run both commands with sample inputs
  - Verify CSV data appears in output AND web research still runs
  - Verify: Output format is Healer-native, not UI-UX-Pro-Max format

**1.11** Commit Wave 1 — traces: all Wave 1 REQs
  - `git add` all new/modified files
  - Commit: "feat: Healer v6 Wave 1 — infrastructure + brand + design-system enhancement"
  - Verify: `git status` clean

**⏸️ GATE: Use Wave 1 for 1 week. Track: plugin-switch count, search.py reliability.**

---

### Wave 2: New Commands (5 remaining) (~4 hours AI-assisted / 4 days human)

**Purpose**: Write all remaining new commands following the validated pattern from Wave 1.

**Parallel Group A** (touch different files, can run simultaneously):

**2.1** Write `commands/healer:logo.md` — traces: REQ-7
  - Reference doc lookup pattern (no CSV search)
  - Read logo-design.md, logo-style-guide.md, logo-color-psychology.md, logo-prompt-engineering.md
  - Verify: File has enforcement header, HARD-GATEs, anti-rationalization table

**2.2** Write `commands/healer:cip.md` — traces: REQ-8
  - Reference doc lookup pattern
  - Read cip-design.md, cip-deliverable-guide.md, cip-prompt-engineering.md, cip-style-guide.md
  - Verify: File has enforcement header, HARD-GATEs

**2.3** Write `commands/healer:banner.md` — traces: REQ-9
  - Reference doc lookup pattern
  - Read banner-sizes-and-styles.md
  - Verify: File has enforcement header, HARD-GATEs

**2.4** Write `commands/healer:icon.md` — traces: REQ-10
  - CSV + reference doc pattern (like brand)
  - search.py --domain icons + icon-design.md reference
  - Verify: File has CSV lookup AND reference doc read AND web research

**2.5** Write `commands/healer:slides.md` — traces: REQ-11
  - CSV + reference doc pattern
  - search.py --domain chart + slides references
  - Verify: File has CSV lookup AND multiple reference reads

**2.6** Test all 5 new commands individually — traces: REQ-7-11
  - Invoke each with sample input
  - Verify: Each produces output, follows Healer format, includes research

**2.7** Commit Wave 2 — traces: REQ-7-11
  - Commit: "feat: Healer v6 Wave 2 — add logo, cip, banner, icon, slides commands"

---

### Wave 3: Enhanced Commands (4 remaining) (~4 hours AI-assisted / 3 days human)

**Purpose**: Add Step 0.5 to the remaining enhanced commands.

**Parallel Group B** (touch different files, can run simultaneously):

**3.1** Enhance `commands/healer:design.md` — traces: REQ-12
  - Insert Step 0.5 with styles/products/reasoning CSV lookups
  - Verify: Diff shows ONLY additions; existing steps preserved

**3.2** Enhance `commands/healer:design-review.md` — traces: REQ-14
  - Embed UX guidelines into 7-dimension checklist
  - Add search.py --domain ux calls within each dimension
  - Verify: All 7 existing dimensions still present; UX guidelines added

**3.3** Enhance `commands/healer:implement.md` — traces: REQ-15
  - Add stack-specific guidelines lookup
  - search.py --stack {detected_stack}
  - Verify: Diff shows ONLY additions

**3.4** Enhance `commands/healer:audit.md` — traces: REQ-16
  - Add UX audit dimensions (animation, navigation, forms, touch)
  - search.py --domain ux for UX-specific checks
  - Verify: Existing audit checks preserved; new UX dimensions added

**3.5** Test all 4 enhanced commands — traces: REQ-12, 14-16
  - Invoke each with sample input
  - Verify: CSV lookup occurs BEFORE web research in each

**3.6** Regression check: run original 26 commands quick-check — traces: REQ-C01
  - Verify no existing command behavior changed
  - Spot-check 3-4 non-enhanced commands still work identically

**3.7** Commit Wave 3 — traces: REQ-12, 14-16
  - Commit: "feat: Healer v6 Wave 3 — enhance design, design-review, implement, audit with CSV data"

---

### Wave 4: Flow + Help + Polish (~2 hours AI-assisted / 1 day human)

**Purpose**: Wire everything together in the flow system and documentation.

**4.1** Update `commands/healer:flow.md` — traces: REQ-17, REQ-18, REQ-22
  - Add `identity` preset definition
  - Add `brand-to-production` preset definition
  - Update `visual` preset (add brand step)
  - Update suggested-next graph (brand, logo, cip, banner, icon, slides)
  - Verify: Preset definitions parse correctly; visual includes brand

**4.2** Update `config/recipes.yaml` — traces: REQ-19
  - Add 4 new recipes: brand-identity, visual-full, marketing-kit, design-polish
  - Verify: `python3 -c "import yaml; yaml.safe_load(open('config/recipes.yaml'))"` valid

**4.3** Update `commands/healer:help.md` — traces: REQ-20
  - Add all 6 new commands with descriptions
  - Add new flow presets and recipes
  - Document data/ directory structure and sync hook
  - Verify: Help file lists 32 sub-commands

**4.4** Update `commands/healer.md` — traces: REQ-21
  - Add 6 new sub-commands to the listing
  - Update description to mention design intelligence
  - Verify: Sub-command count is 32

**4.5** Update `README.md` — traces: REQ-5
  - Add section on design intelligence integration
  - Add MIT license attribution for UI-UX-Pro-Max
  - Document new commands and flow presets
  - Verify: README mentions all 6 new commands

**4.6** End-to-end flow test: `/healer:flow identity` — traces: REQ-17
  - Run the identity flow (brand → logo → cip → design-system)
  - Verify: All 4 steps execute, gates work, state.json updates

**4.7** Metrics baseline — traces: Strategy rec #1
  - Record current plugin-switch count baseline
  - Record flow completion time baseline
  - Set up sync-state.json for 30-day uptime tracking

**4.8** Final commit — traces: all REQs
  - Commit: "feat: Healer v6 Wave 4 — flow presets, recipes, help, polish"
  - Version bump to 6.0.0

**4.9** Run verification checklist — traces: all REQs
  - Verify all 22 FRs against spec acceptance criteria
  - Verify all 4 NFRs against numeric targets
  - Verify all 5 constraints respected
  - Document results in .healer/state.json

---

## Effort Estimation Summary

| Wave | Tasks | AI-assisted | Human team | Compression | Type |
|------|-------|-------------|-----------|-------------|------|
| Wave 1: Infrastructure | 11 | ~3 hours | ~4 days | ~10x | Boilerplate + Feature |
| Wave 2: New Commands | 7 | ~4 hours | ~4 days | ~8x | Feature |
| Wave 3: Enhanced Commands | 7 | ~4 hours | ~3 days | ~6x | Feature + Architecture |
| Wave 4: Flow + Polish | 9 | ~2 hours | ~1 day | ~4x | Feature + Documentation |
| **Total** | **34** | **~13 hours** | **~12 days** | **~7x** |  |

## Parallel Execution Groups

**Wave 1**: Sequential (dependency chain: data → scripts → test → hook → commands)
**Wave 2**: Tasks 2.1-2.5 are fully parallel (each touches a different command file)
**Wave 3**: Tasks 3.1-3.4 are fully parallel (each touches a different command file)
**Wave 4**: Mostly sequential (flow depends on all commands existing)

## Review Checkpoints

| Checkpoint | After | What to Verify |
|-----------|-------|---------------|
| RC-1 | Task 1.4 | search.py works from Healer's data/ directory |
| RC-2 | Task 1.10 | Full data flow: command → script → CSV → output |
| RC-3 | Wave 1 gate | 1-week real usage validates the pattern |
| RC-4 | Task 2.6 | All 6 new commands work standalone |
| RC-5 | Task 3.6 | No regression in existing 26 commands |
| RC-6 | Task 4.6 | Flow pipeline works end-to-end |
| RC-7 | Task 4.9 | All 22 FRs verified against spec |

## Post-Implementation Verification Checklist

- [ ] **REQ-1**: `ls data/*.csv | wc -l` ≥ 14 — Expected: 14+ CSV files
- [ ] **REQ-2**: `find references/ -name "*.md" | wc -l` ≥ 42 — Expected: 42+ docs
- [ ] **REQ-3**: `python3 scripts/search.py "test" --domain style` — Expected: results with "Style Category"
- [ ] **REQ-4**: `bash scripts/sync-upstream.sh` — Expected: exit 0, sync or skip message
- [ ] **REQ-5**: `.claude-plugin/plugin.json` is valid JSON — Expected: parseable
- [ ] **REQ-6 through REQ-11**: Each new command file exists with enforcement header
- [ ] **REQ-12 through REQ-16**: Each enhanced command has Step 0.5 with search.py calls
- [ ] **REQ-17**: `/healer:flow identity` executes 4-step pipeline
- [ ] **REQ-18**: `/healer:flow visual` includes brand as first step
- [ ] **REQ-19**: `config/recipes.yaml` contains 4 new recipes (valid YAML)
- [ ] **REQ-20**: `healer:help.md` lists all 32 sub-commands
- [ ] **REQ-21**: `healer.md` lists all 32 sub-commands
- [ ] **REQ-22**: State.json suggested_next works for brand, logo, cip, banner, icon, slides
- [ ] **REQ-C01**: Zero existing command files deleted — `git diff --stat` shows no deletions
- [ ] **REQ-C02**: `_enforcement.md` unchanged — `git diff commands/_enforcement.md` shows nothing
- [ ] **NFR-1**: sync-upstream.sh no-op < 500ms — `time bash scripts/sync-upstream.sh`
- [ ] **NFR-2**: Atomic swap works — simulate by running sync twice
- [ ] **Metrics baseline recorded**: plugin-switch count, flow time, sync uptime

## Rollback Strategy

Each wave is a single git commit. Rollback = `git revert <commit>`.
- Wave 4 rollback: revert flow/help changes, commands still work standalone
- Wave 3 rollback: revert enhanced commands, new commands still work
- Wave 2 rollback: revert new commands, infrastructure still works
- Wave 1 rollback: revert everything, return to Healer v5
