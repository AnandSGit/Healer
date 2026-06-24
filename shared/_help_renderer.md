# Healer Help Renderer

**Purpose:** This file documents how the help-flag interceptor (`?` / `-h` / `--help`) in `_enforcement.md` renders help pages. Pages are PRE-RENDERED at build time by `scripts/build_help_index.py` and stored in `data/help-index.json` — this document explains the dispatch and rendering contract.

Healer help follows the **Linux man-page convention** (see `man-pages(7)` and the GNU `--help` standard): a centered header/footer banner plus the standard section order. The goal is that `/healer:<cmd> --help` reads like `man <cmd>` — familiar to anyone who uses a Unix shell.

---

## Panel Variants

There are FOUR rendering variants, all pre-built in `data/help-index.json` (except recipes):

| Variant | Lookup Path | Used For |
|---|---|---|
| `command` | `commands.<name>.panel` | `/healer:<name> --help` (or `-h` / `?`) for any command in the catalog |
| `flow-overview` | `flow_overview` (top-level string) | `/healer:flow --help` (no preset specified) |
| `flow-preset` | `flows.<preset>.panel` | `/healer:flow <preset> --help` for a specific preset |
| `recipe` | rendered AT RUNTIME from `~/.healer/recipes.yaml` | `/healer:flow <recipe> --help` for a user recipe |

For the first three variants, the interceptor reads the pre-rendered string directly from the index and prints it VERBATIM. **No formatting work happens at runtime** — that is the entire point of the pre-built index.

For the recipe variant, the interceptor reads `~/.healer/recipes.yaml` directly, finds the matching recipe, and renders using the same man-page format below. Recipe rendering is not pre-built because user recipes are local and change without contributor knowledge.

---

## Man-Page Format (Reference)

Every command and flow-preset page uses the standard man layout: a header banner,
the conventional section order, then a footer banner. Sections that have no data
are omitted (e.g. a command with no arguments has no OPTIONS section).

```
HEALER:<NAME>(1)                  Healer Manual                  HEALER:<NAME>(1)

NAME
       healer:<name> — <one-line tagline>

SYNOPSIS
       <syntax string>
       /healer:<name> (-h | --help | ?)

DESCRIPTION
       <purpose, wrapped>

       <what it does, wrapped>

       <how the user's input flows downstream, wrapped>

OPTIONS
       <arg-name>  (required|optional)
              <description>

EXAMPLES
       <full invocation>
              <why this example>
              Trace:
                → <step>
       Valid input:    '<x>', '<y>'
       Invalid input:  '<z>' — <why it is rejected>

EXIT STATUS                       (commands: must-pass halt conditions)
       The command halts (must-pass gate failure) when:
         ! <condition>

SEE ALSO
       healer:<next>, healer:<related>

ENFORCEMENT
       Runs under the shared enforcement protocol (research + verification gates).

Healer <version>                   <category>                   HEALER:<NAME>(1)
```

**Flow presets** use the same skeleton with two differences: a **PIPELINE** section
(a numbered step table with gate operators and what each step produces) replaces
OPTIONS-heavy detail, and the footer center reads `flow preset`.

### Section mapping (catalog field → man section)

| `commands.yaml` field | Man section |
|---|---|
| `purpose` (text before the em-dash) | NAME tagline |
| `input.syntax` | SYNOPSIS |
| `purpose` + `what_it_does` + `input_purpose` | DESCRIPTION |
| `input.args[]` (name, required, desc) | OPTIONS |
| `example` + `input.valid` / `input.invalid` | EXAMPLES |
| `errors` (commands) / `after.on_failure` (flows) | EXIT STATUS |
| `next` + `related` (commands) / `after.next` + `after.sister_presets` (flows) | SEE ALSO |
| `steps[]` (flows only) | PIPELINE |

Because every section is derived from existing catalog fields, **adding the man
format required no schema change** — only the renderer in `build_help_index.py`.

---

## Recipe Rendering (Runtime Variant)

When the interceptor encounters `/healer:flow <name> --help` and `<name>` is NOT in the built-in flows index, it falls through to recipe lookup:

```
1. Read ~/.healer/recipes.yaml (silently skip if missing)
2. If recipes.<name> exists:
     a. Map recipe fields to the man-page format above
     b. Render and HALT
   Else:
     Render "Unknown" page with Levenshtein-suggested alternatives
     from both built-in flows AND user recipes
```

Recipes have a leaner schema than flow presets — typically only `description` and `steps[]`. Missing sections are simply omitted (man-page sections are optional).

---

## Unknown Page (Fallback)

When the interceptor cannot find a matching command/flow/recipe:

```
HEALER:UNKNOWN(1)                 Healer Manual                 HEALER:UNKNOWN(1)

NAME
       <input> — no such command, flow, or recipe

DESCRIPTION
       No help entry for `<input>`.

       Did you mean?
         /healer:<close-match-1>
         /healer:<close-match-2>

SEE ALSO
       healer:help              overview
       healer:help commands     all commands
       healer:help flows        all flow presets

HEALER:UNKNOWN(1)                 Healer Manual                 HEALER:UNKNOWN(1)
```

---

## Performance Contract

- **Cold-start latency target:** < 50 ms (one JSON read + one dict lookup + one print)
- **Index size target:** < 250 KB (currently ~180 KB at 44 commands + 27 flows)
- **No runtime markdown processing** — pages are stored as final-form text strings
- **Deterministic** — pages contain no timestamps, so identical sources produce an identical index (only `_meta.generated_at` changes between builds)

---

## Why Not Render at Runtime?

We considered runtime rendering. Three reasons we pre-build instead:

1. **Latency** — wrapping + table assembly + banner drawing per invocation adds ~30-100 ms
2. **Determinism** — pre-rendered text means identical output across every invocation
3. **Failure isolation** — a rendering bug fails at build time (before shipping), never on a live `--help` invocation in the field

The price is that changing the man format requires updating `build_help_index.py` and rebuilding. This is acceptable: the renderer is small and variants are rare.

---

## Related Files

- `scripts/build_help_index.py` — performs all man-page rendering, writes the index
- `scripts/build-help-index.sh` — Bash wrapper for the Python script
- `scripts/help_catalog_hook.sh` — PostToolUse hook that rebuilds the index on catalog edits
- `data/commands.yaml` — source of truth for command metadata
- `data/flows.yaml` — source of truth for flow preset metadata
- `data/schema/command.schema.json` — schema for commands.yaml
- `data/schema/flow.schema.json` — schema for flows.yaml
- `data/help-index.json` — generated artifact (committed to git)
- `shared/_enforcement.md` — contains the help-flag interceptor that USES this renderer
- `commands/help.md` — the `/healer:help` command (man index + apropos search)
