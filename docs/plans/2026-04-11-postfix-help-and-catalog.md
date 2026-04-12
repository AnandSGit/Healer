# Plan: Universal `?` Postfix Help + Self-Validating Command Catalog

**Date:** 2026-04-11
**Target version:** Healer v7.1.0
**Source flow:** `/healer:flow ideate`
**Estimated effort:** ~22 hours focused (3–5 days at 4–6h/day)

---

## Context

The current `/healer:help` system reads all 41 command files (~13,794 lines total) on every invocation. There is no postfix help convention — users cannot type `/healer:flow ?` to see help for that command. Help is slow and undiscoverable.

This plan introduces:
1. A **`?` (and `--help`) postfix interceptor** living in `shared/_enforcement.md` that fires on every healer command before its procedure executes.
2. A **canonical command catalog** at `data/commands.yaml` and `data/flows.yaml`, validated by JSON Schema, serving as the single source of truth for all help, README, and HTML user-guide content.
3. A **pre-built index** (`data/help-index.json`) for sub-50ms help latency, auto-rebuilt by a PostToolUse hook on every command/YAML edit.
4. A **scaffolder** (`/healer:add-command`) so adding a new command is one atomic operation that updates both the markdown file and the YAML entry.
5. A **README + HTML auto-generator** so command tables in user-facing docs never rot.

---

## Locked Decision Summary

| # | Decision | Choice | Rationale |
|---|---|---|---|
| D1 | `?` interceptor location | `shared/_enforcement.md` | Universal precondition; already loaded by every command |
| D2 | Help architecture | Variant 3 (centralized YAML + JSON Schema + index + hook) | Single source of truth; enables README/HTML auto-gen; complexity is load-bearing |
| D3 | Drill-down format | 3a flat (overview) + 3b six-section (detail) | Matches kubectl `explain` precedent |
| S1 | YAML validator | Python (`PyYAML` + `jsonschema`) | Universal availability on dev machines |
| S2 | Recipes resolution | Runtime read of `~/.healer/recipes.yaml` | User-local data should not be baked into shipped artifacts |
| S3 | Hook timing | PostToolUse with loud error | PreToolUse blocking is too aggressive for in-progress edits |
| S4 | Scope additions | Scaffolder + README gen + `--help` alias | Neutralizes Variant 3's two-place-update cost; hedges `?` convention bet |
| S5 | `?` resolution rule | Standalone token only; literal `?` mid-string passes through | Avoids false positives in user topics |
| Q1 | `data/help-index.json` | Committed to git | First-clone UX > merge friction |
| Q2 | Inline custom flow drill-down | Deferred to v2 | No metadata to drill into |
| Q3 | HTML user-guide gen | Marker sections only (not full HTML) | Same pattern as README; lower risk |
| Q4 | CHANGELOG backfill | v7.0.0 entry only | Single historical entry for context, not full archaeology |

---

## Six-Section Drill-Down Format (Spec)

Every command and flow preset renders the same six sections via `?`:

1. **PURPOSE** — what the command exists to do
2. **WHAT IT DOES** — sub-commands invoked, in order, with gates and outputs
3. **INPUT / EXPECTED TEXT** — syntax, valid examples, invalid examples with reasons
4. **CONCRETE EXAMPLE** — one full command with step-by-step trace and "why this example" justification
5. **PURPOSE OF YOUR INPUT TEXT** — how the user's argument flows through downstream steps
6. **AFTER THIS COMMAND / RELATED** — suggested next, sister presets, errors/halts

---

## Functional Requirements (Reference)

| FR | Subject |
|---|---|
| FR-1 | `?` postfix interceptor (regex, dispatch, lookup, termination) |
| FR-2 | Help catalog (`data/commands.yaml`, `data/flows.yaml`) with bijection to `commands/*.md` |
| FR-3 | Build pipeline (`scripts/build-help-index.sh`) — validate, render, hash, write |
| FR-4 | Validation hook (PostToolUse Write\|Edit) — drift check + rebuild + loud error |
| FR-5 | Scaffolder (`/healer:add-command`) — atomic write of both files + index update + rollback |
| FR-6 | README generator (marker-based) |
| FR-7 | Renderer (`shared/_help_renderer.md`) — variants for command/flow-overview/flow-preset/recipe |
| FR-8 | Documentation pipeline (README, HTML guide, help.md, plugin.json, CHANGELOG, design/spec/plan archives, install.sh) |

## Acceptance Tests (Reference)

26 tests in total — AT-1 through AT-26. Categories:
- AT-1 to AT-7: Interceptor behavior including literal `?` pass-through
- AT-8 to AT-10: Hook + drift + rebuild
- AT-11 to AT-12: Scaffolder happy path + rollback
- AT-13: Build idempotency
- AT-14: Latency under 50ms
- AT-15: README markers replaced; non-marker content untouched
- AT-16: Backwards compat (existing `/healer:help` still works)
- AT-17 to AT-26: Documentation surfaces (README, HTML, CHANGELOG, plugin.json, help.md, install.sh, marker comments in commands/*.md)

## Non-Functional Targets

| NFR | Target |
|---|---|
| Help latency (`?` cold start) | < 50 ms |
| Index file size | < 200 KB |
| Build script runtime | < 2 sec |
| Hook overhead per edit | < 500 ms |
| Schema coverage | 100% of fields |
| Drift detection | 100% of bijection violations |

---

## Phases & Tasks

### Phase 1 — Foundation (Schema + Pilot) — 3h 30m

| # | Task | Files | Effort | Verifies |
|---|---|---|---|---|
| T1 | Create `data/schema/command.schema.json` | NEW | 30m | FR-2 |
| T2 | Create `data/schema/flow.schema.json` | NEW | 25m | FR-2 |
| T3 | Pilot 3 entries in `data/commands.yaml` (brainstorm, flow, help) | NEW | 45m | FR-2.1 |
| T4 | Pilot 3 entries in `data/flows.yaml` (feature, fix, ideate) | NEW | 30m | FR-2.3 |
| T5 | Write `scripts/build-help-index.sh` (Python core) | NEW | 60m | FR-3 |
| T6 | Generate `data/help-index.json` from pilot, manually verify rendering | GENERATED | 20m | AT-13 |

**Gate:** Schema validation passes on 3 commands + 3 flows. Index JSON has correct shape.

### Phase 2 — Renderer + Interceptor — 1h 55m

| # | Task | Files | Effort | Verifies |
|---|---|---|---|---|
| T7 | Write `shared/_help_renderer.md` (variants: command, flow-overview, flow-preset, recipe) | NEW | 45m | FR-7 |
| T8 | Add `?` interceptor block to `shared/_enforcement.md` | MODIFY | 40m | FR-1, AT-7 |
| T9 | Manual test: 5 invocations covering AT-1, AT-2, AT-5, AT-6, AT-7 | n/a | 30m | AT-1, AT-2, AT-5, AT-6, AT-7 |

**Gate:** All 5 manual test invocations render correctly.

### Phase 3 — Full Catalog Migration — 7h 15m

| # | Task | Files | Effort | Verifies |
|---|---|---|---|---|
| T10 | Migrate remaining 38 command entries into `data/commands.yaml` | MODIFY | 4h | FR-2.1, FR-2.2 |
| T11 | Migrate remaining 23 flow presets into `data/flows.yaml` | MODIFY | 2h | FR-2.3 |
| T12 | Write `scripts/validate-help-catalog.sh` (drift checker) | NEW | 30m | FR-4.3, AT-8 |
| T13 | Run validation, fix any drift | various | 30m | AT-8 |
| T14 | Regenerate full `data/help-index.json` and inspect | GENERATED | 15m | AT-13 |

**Gate:** All 41 commands + 26 presets in YAML, schema-valid, bijection-clean, index regenerates idempotently.
**Note:** T10 (4h) can be split per-category into 10 sub-tasks of 25min each for finer granularity.

### Phase 4 — Hook Integration — 1h 10m

| # | Task | Files | Effort | Verifies |
|---|---|---|---|---|
| T15 | Write `scripts/help-catalog-hook.sh` (path-match + validate + build) | NEW | 30m | FR-4.2, FR-4.3 |
| T16 | Write `hooks/help-catalog.hook.json` (PostToolUse Write\|Edit) | NEW | 15m | FR-4.1 |
| T17 | Test edit-rebuild loop and drift error visibility | n/a | 25m | AT-8, AT-9, AT-10 |

**Gate:** Edit-rebuild loop works. Drift produces visible error.

### Phase 5 — Auto-Generated Docs (README + HTML) — 1h 55m

| # | Task | Files | Effort | Verifies |
|---|---|---|---|---|
| T18 | Add HEALER:COMMANDS / HEALER:FLOWS markers to `README.md` | MODIFY | 15m | FR-6.2, AT-15 |
| T19 | Write `scripts/generate-readme.sh` | NEW | 45m | FR-6, AT-18 |
| T20 | Add equivalent markers to `healer-user-guide.html` | MODIFY | 20m | FR-8.2 |
| T21 | Extend `build-help-index.sh` to invoke generators | MODIFY | 35m | FR-8.2, AT-19 |

**Gate:** Editing YAML → README + HTML auto-update on next hook fire.

### Phase 6 — Scaffolder — 1h 55m

| # | Task | Files | Effort | Verifies |
|---|---|---|---|---|
| T22 | Write `commands/add-command.md` (interactive prompts, atomic writes, rollback) | NEW | 90m | FR-5, AT-11, AT-12 |
| T23 | Test scaffolder end-to-end with throwaway command | various | 25m | AT-11 |

**Gate:** Scaffolder produces a working new command + YAML entry + index update atomically.

### Phase 7 — Documentation Surface — 3h 40m

| # | Task | Files | Effort | Verifies |
|---|---|---|---|---|
| T24 | Add `<!-- Help metadata: data/commands.yaml -->` marker to all 41 commands/*.md (script-driven) | MODIFY ×41 | 25m | AT-24 |
| T25 | Update `commands/help.md` — add `?` mentions, remove obsolete category mapping | MODIFY | 30m | AT-23 |
| T26 | Bump `plugin.json`: 7.0.0 → 7.1.0; update description | MODIFY | 10m | AT-22 |
| T27 | Create `CHANGELOG.md` (Keep-a-Changelog format) with v7.0.0 backfill + v7.1.0 entry | NEW | 30m | AT-20, FR-8.5 |
| T28 | Update `install.sh` — post-install build + pre-install validation + success tip | MODIFY | 20m | AT-26 |
| T29 | Write `docs/designs/2026-04-11-postfix-help-and-catalog.md` | NEW | 40m | FR-8.6 |
| T30 | Write `docs/specs/2026-04-11-postfix-help-and-catalog.md` | NEW | 30m | FR-8.7 |
| T31 | (this file is already this plan — confirm it exists at this path) | n/a | 0m | FR-8.8 |
| T32 | Extend hook validation to enforce AT-24 marker presence | MODIFY | 15m | AT-25 |

**Gate:** All doc surfaces updated. Install script verified on a clean clone.

### Phase 8 — Verification — 1h 45m

| # | Task | Effort | Verifies |
|---|---|---|---|
| T33 | Execute all 26 acceptance tests; record results | 90m | All AT |
| T34 | Performance benchmark: `/healer:flow ?` cold start < 50ms | 15m | NFR-latency |

**Gate:** 26/26 acceptance tests pass. Latency under 50ms.

---

## Dependency Graph

```
Phase 1 (T1-T6) ──→ Phase 2 (T7-T9) ──→ Phase 3 (T10-T14)
                          │                    │
                          ↓                    ↓
                     Phase 4 (T15-T17) ←──────┘
                          │
                          ↓
                     Phase 5 (T18-T21)
                          │
                          ↓
                     Phase 6 (T22-T23)
                          │
                          ↓
                     Phase 7 (T24-T32)
                          │
                          ↓
                     Phase 8 (T33-T34)
```

Parallelization opportunities:
- T7 (renderer) can start while T5 (build script) is being written
- T10/T11 (data migration) and T15/T16 (hook scripts) are independent — Phases 3 and 4 partially parallel
- T29/T30/T31 (doc archives) can be drafted any time after Phase 6

---

## Verification Protocol

**Per phase:**
1. Run the acceptance tests in the Verifies column for that phase
2. If any AT fails → halt phase, fix, re-run, do NOT advance
3. Update `.healer/state.json` with phase progress
4. Commit with message `feat(help): phase N — <title>` (one commit per phase)

**Final (after T34):**
1. Run `/healer:flow ?` — verify output matches spec example
2. Run `/healer:diagnose` — ensure no regressions in existing commands
3. Manual smoke: pick 3 random commands, append `?`, confirm output
4. Tag release: `git tag v7.1.0` + write release notes from CHANGELOG entry

---

## Risk Register

| Risk | Likelihood | Mitigation |
|---|---|---|
| Migrating 41 commands' help into YAML reveals frontmatter inconsistencies | High | Phase 1 pilot catches schema gaps before scale |
| `?` regex catches false positives in real user input | Medium | AT-7 explicitly tests this; expand test cases if found |
| PostToolUse hook latency is noticeable | Low | Hook is path-filtered; only fires on relevant edits |
| Python missing on a user's machine | Low | install.sh checks for Python3 and prints clear error |
| Auto-generated README clobbers manual edits between markers | Medium | Document the markers prominently in CONTRIBUTING.md or README itself |
| Scaffolder rollback fails partially (write atomicity hard in shell) | Medium | T22 + T23 explicitly test simulated failures |

---

## Out of Scope (v1)

- MCP resource server exposing `healer://commands/<name>`
- Locale support (`data/commands.es.yaml` etc.)
- Versioned catalog diffs (`data/commands.v7.yaml` → v8)
- IDE extension integration
- Help search becoming structured query (current grep-based search continues to work)
- Inline custom flow drill-down (e.g., `/healer:flow brainstorm → plan ?`)
- Translating existing commands' procedure bodies into structured YAML (only metadata is in scope)

---

## Status Tracking

```
PHASE        STATUS    COMPLETED   AT-PASSED   NOTES
─────────    ──────    ─────────   ─────────   ──────────────
Phase 1      pending   0/6         0
Phase 2      pending   0/3         0
Phase 3      pending   0/5         0
Phase 4      pending   0/3         0
Phase 5      pending   0/4         0
Phase 6      pending   0/2         0
Phase 7      pending   0/9         0
Phase 8      pending   0/2         0
─────────    ──────    ─────────   ─────────
TOTAL        pending   0/34        0/26
```

Update this table after each phase completes.

---

## Execution Trigger

This plan is ready for execution. To start:

```
/healer:flow feature   (treats this plan as the spec input)
   OR
/healer:execute-plan docs/plans/2026-04-11-postfix-help-and-catalog.md
   OR
manually walk Phase 1, T1 first
```
