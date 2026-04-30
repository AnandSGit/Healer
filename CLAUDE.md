# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

Healer is a **Claude Code plugin** (not an application) — it ships ~44 slash commands under the `/healer:*` namespace plus a flow orchestrator that chains them into pipelines. There is no compiler, no server, no test suite in the traditional sense. The "code" is markdown procedure files, YAML catalogs, and Python tooling that keeps them consistent.

Entry points:
- `plugin.json` / `.claude-plugin/{plugin,marketplace}.json` — plugin manifest, registers `healer@healer` with Claude Code.
- `install.sh` — registers the directory as a local Claude Code marketplace, enables the plugin, installs PyYAML+jsonschema, builds the help index, copies `config/recipes.yaml` → `~/.healer/recipes.yaml`.
- `hooks/hooks.json` — `SessionStart` runs `scripts/sync-upstream.sh`; `PostToolUse` on `Write|Edit` runs `scripts/help_catalog_hook.sh`.

## Common commands

Install/reinstall the plugin (also rebuilds the help index):
```bash
./install.sh
```

Rebuild the help index by hand (validates schemas + bijection, exit codes 1/2/3/4 distinguish failure modes):
```bash
bash scripts/build-help-index.sh
# or directly: python3 scripts/build_help_index.py
```

Regenerate the auto-generated tables in `README.md` and `docs/healer-user-guide.html`:
```bash
python3 scripts/generate_readme.py
```

Force an upstream design-data resync (otherwise it skips when synced within `sync_frequency_days`):
```bash
rm -f ~/.claude/plugins/data/healer/sync-state.json
bash scripts/sync-upstream.sh
```

Exercise the BM25 design-intel search engine (used internally by `design`/`brand`/`logo`/etc.):
```bash
python3 scripts/search.py "<query>" [--domain style|color|ux|typography|chart|landing|product|google-fonts] [--stack react|nextjs|vue|...]
python3 scripts/search.py "<query>" --design-system --persist -p "Project" --page "dashboard"
```

There are **no unit tests**. Validation runs through `build_help_index.py` (schemas + bijection) and the PostToolUse hook on every catalog edit.

## Architecture: the catalog is the source of truth

Three things must stay in lockstep for any command:

1. `commands/<name>.md` — the procedure Claude Code executes when the user types `/healer:<name>`. Frontmatter `description` is what Claude Code shows in the slash-command picker. Each file must contain the marker `<!-- Help metadata: data/commands.yaml -->` so contributors know where to edit help text.
2. `data/commands.yaml` — the help-system source of truth (purpose, what_it_does, input syntax/args/valid/invalid, example with trace, input_purpose, next, related, errors). Validated against `data/schema/command.schema.json`.
3. `data/help-index.json` — pre-rendered six-section help panels keyed by command/flow name, plus source hashes for drift detection. Built from #1 and #2 by `scripts/build_help_index.py`.

`build_help_index.py` enforces a **bijection**: every `commands/*.md` must have a key in `commands.yaml` and vice versa, and every command file must contain the help-metadata marker. Drift exits non-zero (code 2) and the PostToolUse hook surfaces a loud error to stderr.

**Never hand-edit commands and the YAML separately.** Use `/healer:add-command <name>` to scaffold both atomically. If you must edit by hand, edit both, then run `bash scripts/build-help-index.sh` to verify and rebuild.

Flow presets follow the same pattern: `data/flows.yaml` (validated against `data/schema/flow.schema.json`) is the source of truth; `commands/flow.md` consumes it. User-local custom recipes live in `~/.healer/recipes.yaml` (copied from `config/recipes.yaml` at install) and resolve at runtime — they take precedence over built-in presets with the same name.

## Architecture: shared protocol layer

`shared/_enforcement.md` and `shared/_research_and_options.md` are referenced by every command's procedure (look for "Read and apply all protocols from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`" near the top of each `commands/*.md`). They define:

- **Postfix `?` / `--help` interceptor** — runs *before* any other protocol. If `$ARGUMENTS` matches the help patterns (see `_enforcement.md` regex table), the command reads `data/help-index.json`, prints the pre-rendered panel verbatim, and HALTS. Crucially, `?` mid-string (e.g., `/healer:debug "why is this ?"`) passes through as literal input.
- **HARD-GATEs** — absolute blockers (research-before-options, evidence-before-claims, fix-verify cycles, must-pass flow gates, Karpathy P2 Simplicity / P3 Surgical Changes for code-writing commands). Commands must not proceed past a HARD-GATE without satisfying it.
- **Deep-Research + Options-First** (`_research_and_options.md`) — 8-category research matrix and minimum candidate counts (brainstorm: 7, design-UI: 10, design-API: 7, spec: 5, plan: 4, architect: 5, refactor: 5, optimize: 5). Commands present a curated menu; the user picks. UI commands additionally produce a self-contained HTML option gallery under `docs/design-previews/options/`.

When editing any `commands/*.md`, preserve the enforcement reference and any `<HARD-GATE>...</HARD-GATE>` blocks — they are non-negotiable runtime contracts, not flavor text.

## Architecture: plugin paths vs user state

Plugin assets are read at runtime via `${CLAUDE_PLUGIN_ROOT}` (Claude Code resolves it to this repo when installed):
- `${CLAUDE_PLUGIN_ROOT}/data/*.csv` — design-intel databases (colors, fonts, ux-guidelines, charts, landing, products, styles, icons, typography, ui-reasoning, react-performance, app-interface, draft, design, google-fonts).
- `${CLAUDE_PLUGIN_ROOT}/data/stacks/*.csv` — per-stack guidelines (react, nextjs, vue, svelte, astro, swiftui, react-native, flutter, nuxtjs, nuxt-ui, html-tailwind, shadcn, jetpack-compose, threejs, angular, laravel).
- `${CLAUDE_PLUGIN_ROOT}/references/{brand,design,design-system,slides,ui-styling}/*.md` — long-form reference docs.
- `${CLAUDE_PLUGIN_ROOT}/scripts/{search,core,design_system}.py` — BM25 search engine over the CSVs.

User state lives in `~/.healer/`:
- `recipes.yaml` — custom flow pipelines (resolved by `/healer:flow <name>`).
- `brainstorms/`, `research/`, `validations/`, `strategies/` — cross-session artifacts written by ideation commands and consumed by downstream ones (e.g., `brainstorm` writes a doc that `plan` reads).
- `state.json` (gitignored, lives under `.healer/state.json` in user projects) — last-command tracker that powers smart next-step suggestions when `/healer` is invoked with no args.

Sync state for upstream design data: `~/.claude/plugins/data/healer/sync-state.json`.

## Upstream design-data sync

`scripts/sync-upstream.sh` (run on `SessionStart`) pulls CSVs from the locally-installed UI-UX-Pro-Max plugin at `~/.claude/plugins/marketplaces/ui-ux-pro-max-skill/src/ui-ux-pro-max/data` into `data/`. It:
- Skips silently if upstream is absent or last sync is fresher than `sync_frequency_days` (default 7).
- Validates expected headers on `styles.csv`, `colors.csv`, `typography.csv`, `ux-guidelines.csv` before swapping.
- Does an atomic directory swap (`data/.new` → `data/`, with `data/.backup` rollback).
- Prints a one-line warning on major-version bumps so the user can review.

This means `data/*.csv` is **not** authored in this repo — only `data/commands.yaml`, `data/flows.yaml`, `data/schema/*.json`, and `data/help-index.json` are. If you find yourself diffing CSV churn, it's the sync hook, not your edits.

## Adding a new command

Use `/healer:add-command <kebab-name>`. It enforces bijection by writing `commands/<name>.md` and the `data/commands.yaml` entry in one operation, then runs `build_help_index.py` to validate and rebuild. Manual two-place edits are the most common drift source.

If you must add manually:
1. Create `commands/<name>.md` with frontmatter `description:` and the `<!-- Help metadata: data/commands.yaml -->` marker, plus the enforcement reference.
2. Add a `<name>:` entry to `data/commands.yaml` matching the schema.
3. Run `bash scripts/build-help-index.sh` — fix anything it reports until it exits 0.
4. Run `python3 scripts/generate_readme.py` to update the auto-generated tables in `README.md` and `docs/healer-user-guide.html`.

## Editing README.md / user-guide.html

The `<!-- HEALER:COMMANDS:START -->...<!-- HEALER:COMMANDS:END -->` and `<!-- HEALER:FLOWS:START -->...<!-- HEALER:FLOWS:END -->` regions are **overwritten** by `scripts/generate_readme.py`. Edit `data/commands.yaml` / `data/flows.yaml` (the `purpose` field's first line is what shows up in the table), then run the generator. Edits inside the markers will be lost.

## Conventions worth knowing

- Command files reference `${CLAUDE_PLUGIN_ROOT}` for cross-file reads — do not hardcode absolute paths or `$HOME`.
- The `flow` command treats `→`, `?→`, `!→` as gate operators (auto / interactive / must-pass). `!→` failures **halt** the pipeline — do not add "ask the user to continue" logic around them.
- The `healer` command (bare `/healer`) is special-cased throughout: in `generate_readme.py` it renders as `/healer` not `/healer:healer`, and its catalog key is just `healer`.
- Every command writing to source code is bound by the Karpathy Simplicity (P2) and Surgical Changes (P3) HARD-GATEs in `_enforcement.md`. When editing those commands, do not weaken those gates without updating the rationale in `docs/designs/2026-04-15-karpathy-integration.md`.
- Design history lives under `docs/designs/`, plans under `docs/plans/`, specs under `docs/specs/` — dated `YYYY-MM-DD-<slug>.md`. New protocol-level changes should land a design doc in this format and link from `CHANGELOG.md`.
