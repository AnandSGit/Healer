# Healer Help Renderer

**Purpose:** This file documents how the postfix `?` (and `--help`) interceptor in `_enforcement.md` renders help panels. Panels themselves are PRE-RENDERED at build time by `scripts/build_help_index.py` and stored in `data/help-index.json` — this document explains the dispatch and rendering contract.

---

## Panel Variants

There are FOUR rendering variants, all pre-built in `data/help-index.json`:

| Variant | Lookup Path | Used For |
|---|---|---|
| `command` | `commands.<name>.panel` | `/healer:<name> ?` for any command in the catalog |
| `flow-overview` | `flow_overview` (top-level string) | `/healer:flow ?` (no preset specified) |
| `flow-preset` | `flows.<preset>.panel` | `/healer:flow <preset> ?` for a specific preset |
| `recipe` | rendered AT RUNTIME from `~/.healer/recipes.yaml` | `/healer:flow <recipe> ?` for a user recipe |

For the first three variants, the interceptor reads the pre-rendered string directly from the index and prints it. **No formatting work happens at runtime** — that is the entire point of the pre-built index.

For the recipe variant, the interceptor reads `~/.healer/recipes.yaml` directly, finds the matching recipe entry, and renders using the same six-section format. Recipe rendering is intentionally not pre-built because user recipes are local and change without contributor knowledge.

---

## Six-Section Format (Reference)

Every command and flow-preset panel uses this format:

```
═══════════════════════════════════════════════════════════
HEALER — /healer:<name>     (or /healer:flow <preset>)
═══════════════════════════════════════════════════════════

1. PURPOSE
   <one-paragraph statement of why this exists>

2. WHAT IT DOES (sub-commands, in order)
   <brief mechanical description>
   <step table for flows>

3. INPUT / EXPECTED TEXT
   Syntax: <syntax string>
   Arguments: <arg list>
   Valid examples: <list>
   Invalid examples: <list with "why" reasons>

4. CONCRETE EXAMPLE
   Command: <full invocation>
   Trace: <step-by-step bullets>
   Why this example: <justification>

5. PURPOSE OF YOUR INPUT TEXT
   <how the user's input flows through downstream steps>

6. AFTER THIS COMMAND   (or AFTER THIS FLOW)
   Suggested next: <chain>
   Sister presets / Related: <chain>
   Errors / On failure: <list>
═══════════════════════════════════════════════════════════
```

---

## Recipe Rendering (Runtime Variant)

When the interceptor encounters `/healer:flow <name> ?` and `<name>` is NOT in the built-in flows index, it falls through to recipe lookup:

```
1. Read ~/.healer/recipes.yaml (silently skip if missing)
2. If recipes.<name> exists:
     a. Map recipe entry to the same six-section format
     b. Render and HALT
   Else:
     Render "Unknown preset/recipe" panel with Levenshtein-suggested
     alternatives from both built-in flows AND user recipes
```

Recipes have a leaner schema than flow presets — they typically only have `description` and `steps[]`. Missing fields are rendered as `(not specified)` rather than failing.

---

## Unknown Panel (Fallback)

When the interceptor cannot find a matching command/flow/recipe:

```
═══════════════════════════════════════════════════════════
HEALER — Unknown: <input>
═══════════════════════════════════════════════════════════

No help entry for `<input>`.

Did you mean?
  /healer:<close-match-1>
  /healer:<close-match-2>

For full reference:
  /healer:help              overview
  /healer:help commands     all commands
  /healer:help flows        all flow presets
═══════════════════════════════════════════════════════════
```

---

## Performance Contract

- **Cold-start latency target:** < 50 ms (one JSON read + one dict lookup + one print)
- **Index size target:** < 200 KB (currently ~24 KB at 3 commands + 3 flows; ~330 KB extrapolated for 41+26)
- **No runtime markdown processing** — panels are stored as final-form text strings
- **No template engine** — Python f-strings handle pre-rendering at build time

---

## Why Not Render at Runtime?

We considered runtime rendering (Variant C in the brainstorm). Three reasons we rejected it:

1. **Latency** — markdown formatting + table assembly + box drawing per invocation adds ~30-100ms even for small files
2. **Determinism** — pre-rendered text means identical output across every invocation forever
3. **Failure isolation** — a bug in rendering logic can't crash a `?` invocation in the field; it would have failed at build time, before shipping

The price is that adding a new panel variant requires updating `build_help_index.py`. This is acceptable: variants are rare (we have four), and the build script is small.

---

## Related Files

- `scripts/build_help_index.py` — performs all rendering, writes the index
- `scripts/build-help-index.sh` — Bash wrapper for the Python script
- `data/commands.yaml` — source of truth for command metadata
- `data/flows.yaml` — source of truth for flow preset metadata
- `data/schema/command.schema.json` — schema for commands.yaml
- `data/schema/flow.schema.json` — schema for flows.yaml
- `data/help-index.json` — generated artifact (committed to git)
- `shared/_enforcement.md` — contains the `?` interceptor that USES this renderer
