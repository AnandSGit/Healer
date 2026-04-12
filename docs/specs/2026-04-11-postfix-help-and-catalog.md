# Spec: Postfix `?` Help + Self-Validating Command Catalog

**Date:** 2026-04-11
**Target version:** Healer v7.1.0
**Design ref:** docs/designs/2026-04-11-postfix-help-and-catalog.md
**Plan ref:** docs/plans/2026-04-11-postfix-help-and-catalog.md

---

## Functional Requirements

### FR-1: `?` Postfix Interceptor

Lives in `shared/_enforcement.md`, runs as the FIRST hard-gate of every command.

- **FR-1.1** Trigger detection — regex match per design doc; mid-string `?` does NOT trigger
- **FR-1.2** Drill-down resolution — empty target = command overview; named target = drill-down (e.g., `flow feature ?` → `flows.feature.panel`)
- **FR-1.3** Lookup order: built-in flows → user recipes → "unknown" panel with Levenshtein suggestions
- **FR-1.4** After rendering, command MUST halt — no further procedure execution

### FR-2: Help Catalog

- **FR-2.1** Every entry MUST have all six drill-down sections per `data/schema/command.schema.json`
- **FR-2.2** Bijection: every `commands/<name>.md` MUST have a key in `data/commands.yaml` (and vice versa). Drift = build failure (with pilot-phase warning until full migration)
- **FR-2.3** Every flow preset in `data/flows.yaml` MUST have all sections including `steps[]` with `command`, `gate`, `produces`

### FR-3: Build Pipeline

- **FR-3.1** Inputs: `data/commands.yaml`, `data/flows.yaml`, `data/schema/*.json`
- **FR-3.2** Output: `data/help-index.json` (committed to git)
- **FR-3.3** Steps: parse YAML → validate schema → check bijection → pre-render panels → compute SHA-256 hashes → write JSON
- **FR-3.4** Idempotent — running twice produces byte-identical output

### FR-4: Validation Hook

- **FR-4.1** Trigger: PostToolUse, matcher `Write|Edit`
- **FR-4.2** Activates only if edited path matches `commands/*.md`, `data/*.yaml`, or `data/schema/*.json`
- **FR-4.3** On activation: drift check + index rebuild; failures print loud error to stderr
- **FR-4.4** Hook errors do not undo the edit (PostToolUse can't), but are visible enough to prompt manual fix

### FR-5: Scaffolder (deferred — see plan Phase 6)

- **FR-5.1** Interactive prompts for all required catalog fields
- **FR-5.2** Atomic writes to both `commands/<name>.md` and `data/commands.yaml`
- **FR-5.3** Rollback on partial failure

### FR-6: README Auto-Generator (deferred — see plan Phase 5)

- **FR-6.1** Read YAMLs, replace marker sections in README.md
- **FR-6.2** Markers: `<!-- HEALER:COMMANDS:START --> ... <!-- HEALER:COMMANDS:END -->`

### FR-7: Renderer

- **FR-7.1** Six-section format documented in `shared/_help_renderer.md`
- **FR-7.2** Variants: command, flow-overview, flow-preset, recipe
- **FR-7.3** All output uses `═══` box-drawing convention consistent with existing `/healer:help`

### FR-8: Documentation Pipeline

See `docs/plans/2026-04-11-postfix-help-and-catalog.md` Phase 7 for breakdown.

---

## Non-Functional Requirements

| NFR | Target | Measured (pilot) |
|---|---|---|
| Help latency (`?` cold start) | < 50 ms | TBD (Phase 8) |
| Index file size | < 200 KB | 23.8 KB |
| Build script runtime | < 2 sec | < 1 sec |
| Hook overhead per edit | < 500 ms | Path-filtered: ~10 ms; activated: < 1 sec |
| Schema coverage | 100% of fields validated | ✓ (jsonschema strict mode via `additionalProperties: false`) |
| Drift detection | 100% of bijection violations caught | ✓ (verified in hook test 3) |
| Backwards compatibility | `/healer:help <name>` still works | ✓ (commands/help.md unchanged) |

---

## Acceptance Tests

| ID | Test | Status |
|---|---|---|
| AT-1 | `/healer:flow ?` renders flow overview + preset table | Renders correctly per pilot |
| AT-2 | `/healer:flow feature ?` renders six-section drill-down | ✓ (verified in build output) |
| AT-3 | `/healer:flow my-recipe ?` renders six-section using `~/.healer/recipes.yaml` | Pending Phase 6 manual test |
| AT-4 | `/healer:flow ghost ?` renders "Unknown preset. Did you mean: …?" | Spec'd in renderer; pending end-to-end test |
| AT-5 | `/healer:brainstorm ?` renders six-section for brainstorm | ✓ |
| AT-6 | `/healer:brainstorm --help` same output as AT-5 | ✓ (regex covers both) |
| AT-7 | `/healer:debug "why ? "` passes through to debug (literal `?` in topic) | ✓ (regex requires standalone token) |
| AT-8 | Edit `commands/foo.md` without YAML entry → hook fails loudly | ✓ (warning during pilot; will be hard-fail post-migration) |
| AT-9 | Edit YAML with invalid schema → hook fails with line-numbered error | ✓ (verified in hook test 3) |
| AT-10 | Edit YAML validly → index rebuilds, no error | ✓ (verified in hook test 2) |
| AT-11 | `/healer:add-command my-new` scaffolds atomically | Pending Phase 6 |
| AT-12 | Scaffolder fails mid-write → all touched files restored | Pending Phase 6 |
| AT-13 | Run build twice → byte-identical output | ✓ (sorted keys + deterministic dict ordering) |
| AT-14 | Help latency < 50ms cold start | Pending Phase 8 measurement |
| AT-15 | README markers replaced; non-marker content untouched | Pending Phase 5 |
| AT-16 | Pre-existing `/healer:help commands` still works | ✓ (no changes to commands/help.md procedure) |
| AT-17 | README contains `?` usage example in Quick Start | Pending Phase 5 |
| AT-18 | README marker sections populated from YAML | Pending Phase 5 |
| AT-19 | healer-user-guide.html includes `?` section | Pending Phase 5 |
| AT-20 | CHANGELOG.md exists with v7.1.0 entry | ✓ |
| AT-21 | docs/{designs,specs,plans} each gain a 2026-04-11 file | ✓ |
| AT-22 | plugin.json version === "7.1.0" and description mentions discoverability | ✓ |
| AT-23 | commands/help.md mentions `?` in overview/gates/all modes | Pending |
| AT-24 | Every commands/*.md has `<!-- Help metadata: data/commands.yaml -->` marker | Pending Phase 7 |
| AT-25 | Hook validates AT-24 marker presence | Pending Phase 7 |
| AT-26 | install.sh runs build script and validates catalog | ✓ |

---

## Edge Cases

| Case | Behavior | Status |
|---|---|---|
| `?` in code block in help text | Not triggered — interceptor only checks `$ARGUMENTS` | ✓ by design |
| User has no `~/.healer/recipes.yaml` | Recipe lookup silently skipped, falls through to "Unknown" | Spec'd; pending Phase 6 test |
| `data/help-index.json` missing or corrupt | Interceptor falls back to dynamic read with warning | Spec'd in interceptor pseudocode |
| Two recipes with same name (built-in + user) | User recipe wins (matches existing /healer:flow precedence) | Spec'd |
| Schema file missing | Build fails immediately with "Schema not found" (exit 3) | ✓ (verified in build script) |
| Hook itself crashes | PostToolUse error reported, edit stays, user re-runs build manually | ✓ (set -uo pipefail; clear stderr message) |
| User edits `data/help-index.json` directly | Drift detected on next hook run via source_hashes mismatch (future enhancement) | Partial — hashes recorded but mismatch check not yet enforced |

---

## Traceability Matrix

| Source | Spec FR | Acceptance Test |
|---|---|---|
| D1 (B) | FR-1 | AT-1, AT-2, AT-5 |
| D2 (Variant 3 + hook) | FR-2, FR-3, FR-4 | AT-8, AT-9, AT-10, AT-13 |
| D3 (3a + 3b) | FR-1.2, FR-7.2 | AT-1, AT-2 |
| Strategy Q1 (3x scope) | FR-5, FR-6 | AT-11, AT-12, AT-15 |
| Strategy Q2 (`?` resolution rule) | FR-1.1 | AT-7 |
| Strategy Q3 (`--help` hedge) | FR-1.1 | AT-6 |
| User original (perf) | NFR latency, FR-3 | AT-14 |
| User original (`?` works on any command) | FR-1 | AT-1 to AT-7 |
| User Q3 addendum (docs) | FR-8 | AT-17 to AT-26 |
