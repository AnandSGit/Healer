# Design: Postfix `?` Help + Self-Validating Command Catalog

**Date:** 2026-04-11
**Target version:** Healer v7.1.0
**Status:** Implemented (Phase 1, 2, 4, 5–7 complete; Phase 3 migration in progress)

---

## Problem Statement

`/healer:help` reads all 41 command files (~13,794 lines) on every invocation. There is no postfix help convention — users cannot type `/healer:flow ?` to get help for flow. Help is slow and undiscoverable.

## Design Goals

1. **Discoverability** — let users type `?` after any command for instant help
2. **Performance** — sub-50ms cold-start latency for `?` invocations
3. **Single source of truth** — eliminate help drift between docs, README, code
4. **Auto-validation** — drift between command files and help catalog is caught at edit time, not in production

---

## Architecture (Variant 3 — Help-as-Data)

```
┌─────────────────────────────────────────────────────────────┐
│ User: /healer:flow feature ?                                │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ shared/_enforcement.md (loaded by every command)             │
│ ├─ Postfix `?` interceptor (FIRST hard-gate)                │
│ │  • regex match `?` or `--help`                            │
│ │  • parse drill-down target ("feature")                    │
│ │  • read data/help-index.json                              │
│ │  • print pre-rendered panel                               │
│ │  • HALT (skip command procedure)                          │
└─────────────────────────────────────────────────────────────┘
                         │ (reads)
                         ▼
┌─────────────────────────────────────────────────────────────┐
│ data/help-index.json (committed, ~24 KB at pilot scale)     │
│ ├─ commands.<name>.panel  — pre-rendered six-section text   │
│ ├─ flows.<preset>.panel   — pre-rendered six-section text   │
│ ├─ flow_overview          — pre-rendered overview panel     │
│ └─ _meta.source_hashes    — staleness detection             │
└─────────────────────────────────────────────────────────────┘
                         ▲ (built from)
                         │
┌─────────────────────────────────────────────────────────────┐
│ data/commands.yaml + data/flows.yaml (sources of truth)     │
│ ├─ Validated against data/schema/*.json                      │
│ └─ Bijection-checked against commands/*.md filenames         │
└─────────────────────────────────────────────────────────────┘
                         ▲ (rebuilt by)
                         │
┌─────────────────────────────────────────────────────────────┐
│ scripts/build_help_index.py                                  │
│  + scripts/build-help-index.sh (Bash wrapper)               │
│  + hooks/hooks.json PostToolUse Write|Edit                  │
│  + scripts/help_catalog_hook.sh (path-filter + rebuild)     │
└─────────────────────────────────────────────────────────────┘
```

---

## Locked Decisions (Conversation Outcome)

| # | Decision | Choice | Rationale |
|---|---|---|---|
| D1 | `?` interceptor location | `shared/_enforcement.md` | Universal precondition; loaded by every command |
| D2 | Help architecture | Variant 3 (centralized YAML + JSON Schema + index + hook) | Single source of truth; enables README/HTML auto-gen; complexity is load-bearing |
| D3 | Drill-down format | 3a flat (overview) + 3b six-section (detail) | Matches kubectl `explain` precedent |
| S1 | YAML validator | Python (PyYAML + jsonschema) | Universal availability on dev machines |
| S2 | Recipes resolution | Runtime read of `~/.healer/recipes.yaml` | User-local data should not be baked into shipped artifacts |
| S3 | Hook timing | PostToolUse with loud error | PreToolUse blocking is too aggressive for in-progress edits |
| S4 | Scope additions | Scaffolder + README gen + `--help` alias | Neutralizes Variant 3's two-place-update cost; hedges `?` convention bet |
| S5 | `?` resolution rule | Standalone token only; literal `?` mid-string passes through | Avoids false positives in user topics |
| Q1 | `data/help-index.json` | Committed to git | First-clone UX > merge friction |
| Q2 | Inline custom flow drill-down | Deferred to v2 | No metadata to drill into |
| Q3 | HTML user-guide gen | Marker sections only (not full HTML) | Same pattern as README; lower risk |
| Q4 | CHANGELOG backfill | v7.0.0 entry only | Single historical entry for context, not full archaeology |

---

## Why Variant 3 Won (Not Variant 2)

Initial brainstorm produced three variants:

- **V1: Enforcement Interceptor** — parse markdown at runtime; high fragility
- **V2: Frontmatter-Rich** — expand each command's YAML frontmatter; low complexity but limited capabilities
- **V3: Help-as-Data** — centralized `data/commands.yaml`; higher complexity but unlocks downstream value

**Strategic rigor (CEO review) flagged that V2 was attractive because of low complexity, not because of architectural fitness.** V3 was selected after the user explicitly pushed back: "if a complex option is genuinely better, pick that."

V3's load-bearing complexity:
- Schema-validated help (catches typos, missing fields)
- Auto-generated README command tables
- Auto-generated HTML user-guide sections (marker-based)
- Machine-readable catalog for `/healer:help search` (O(1) structured query)
- Future MCP resource server (`healer://commands/<name>`) — deferred to v2
- Future locale support — deferred to v2

---

## `?` Resolution Rule (Critical Detail)

To avoid false positives when `?` appears in user input (e.g., "/healer:debug why does this ? happen"), the regex matches:

```
^\s*\?\s*$              # exactly "?"
^--help\s*$             # exactly "--help"
^\s*\?\s+\S             # "? <rest>"
^--help\s+\S            # "--help <rest>"
\S+\s+\?\s*$            # "<token> ?" (last token surrounded by whitespace)
\S+\s+--help\s*$        # "<token> --help"
```

Mid-string `?` (e.g., `"why is this ?"`) DOES NOT trigger help — passes through to the command's procedure as a literal topic.

---

## Performance Characteristics

| Metric | Before | After (target) | After (measured at pilot) |
|---|---|---|---|
| Help cold-start latency | ~14k lines parsed per invocation | < 50 ms | One JSON read (~24 KB) + dict lookup + print |
| Index file size | n/a | < 200 KB | 23.8 KB at 3 commands + 3 flows |
| Build script runtime | n/a | < 2 sec | < 1 sec at pilot scale |
| Hook overhead per edit | n/a | < 500 ms | < 1 sec on activation, 0 ms on path-filtered no-op |

---

## Trade-offs Acknowledged

1. **Two-place updates** — adding a new command requires editing both `commands/<name>.md` AND `data/commands.yaml`. **Mitigation:** the planned `/healer:add-command <name>` scaffolder (Phase 6) makes this atomic. Until then, contributors must remember both edits or trigger the drift error.

2. **Python dependency** — PyYAML and jsonschema must be installed. **Mitigation:** install.sh installs them via `pip3 install --user`. macOS and most Linux distros ship Python3 by default.

3. **Pre-built index commit churn** — every catalog edit produces a diff in `data/help-index.json`. **Mitigation:** index is deterministic (sorted keys), so diffs are minimal and merge cleanly. Rejected the alternative (gitignored index) because first-clone UX matters more.

4. **`?` is a non-standard convention** — most CLIs use `--help` or `-h`. **Mitigation:** support BOTH `?` and `--help` as triggers.

---

## Out of Scope (v1, deferred to v2)

- MCP resource server exposing `healer://commands/<name>`
- Locale support (`data/commands.es.yaml` etc.)
- Versioned catalog diffs (`data/commands.v7.yaml` → v8)
- IDE extension integration
- Help search becoming structured query (current grep-based search continues to work)
- Inline custom flow drill-down (e.g., `/healer:flow brainstorm → plan ?`)
- Translating existing commands' procedure bodies into structured YAML (only metadata is in scope)

---

## Related Artifacts

- `docs/specs/2026-04-11-postfix-help-and-catalog.md` — full spec (FRs, NFRs, ATs)
- `docs/plans/2026-04-11-postfix-help-and-catalog.md` — implementation plan (8 phases, 34 tasks)
- `CHANGELOG.md` — v7.1.0 entry summarizing user-visible changes
