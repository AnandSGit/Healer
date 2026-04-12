# Changelog

All notable changes to Healer are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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
