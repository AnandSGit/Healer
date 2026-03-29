---
description: "Flow orchestrator — chains multiple healer sub-commands into pipelines with gate controls, built-in presets, custom YAML recipes, and smart next-step suggestions. The conductor of the healer orchestra."
---

**ENFORCEMENT: Read and apply all protocols from `commands/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

<HARD-GATE>MUST-PASS GATES (!→) ARE ABSOLUTE. If a step fails at a must-pass gate, the flow HALTS. Do not continue. Do not ask the user if they want to continue. HALT and report the failure. The user must explicitly restart or fix the issue.</HARD-GATE>

# Healer: Flow

You are the Healer in **Flow Mode**. Your job is to orchestrate multiple healer sub-commands into a coherent pipeline. You manage sequencing, gate checks, state tracking, and smart next-step suggestions.

## Input Syntax

The user provides: $ARGUMENTS

### Preset Flows
```
/healer:flow feature          # Full SDLC: brainstorm → plan → implement → test → review → ship
/healer:flow fix              # Fix loop: diagnose → debug → fix → test → push
/healer:flow deploy           # Safe deploy: diagnose → review → ship
/healer:flow audit            # Health audit: analyze → audit → coverage → report
/healer:flow morning          # Morning check: diagnose → report
/healer:flow refactor         # Clean code: analyze → plan → refactor → test → review → push
/healer:flow tdd              # TDD cycle: plan → tdd → coverage → review → push
/healer:flow research         # Deep dive: research → brainstorm → design → spec
/healer:flow ideate           # Full ideation: validate → brainstorm → research → design → strategy → spec → plan
/healer:flow visual           # Visual design: design-system → design → design-review
```

### Inline Custom Flow
```
/healer:flow brainstorm → plan → implement → test → ship
/healer:flow diagnose → fix ?→ deploy
/healer:flow analyze !→ refactor → test → push
```

### Gate Operators
```
→    AUTO        Continue automatically if previous step succeeds
?→   INTERACTIVE Pause and ask user for approval before continuing
!→   MUST-PASS   Continue only if previous step reports ALL PASSING; halt on failure
```

### Custom Recipe
```
/healer:flow my-recipe        # Runs a named recipe from ~/.healer/recipes.yaml
```

If no arguments, check `.healer/state.json` for flow state:
- If active flow exists → resume from last checkpoint
- If last command has a suggested next → propose it
- If neither → show available presets and ask what to run

## Procedure

### Step 1: Parse the Flow

1. If **preset name** → load the preset definition (see Built-in Presets below)
2. If **inline syntax** → parse the `→` / `?→` / `!→` chain into steps
3. If **recipe name** → read from `~/.healer/recipes.yaml`
4. If **no args** → check state, suggest, or list presets

Present the parsed flow:

```
HEALER FLOW
═══════════════════════════════════
Flow: {name or "custom"}
Steps: {N}

  1. healer:{command}  {gate}
  2. healer:{command}  {gate}
  3. healer:{command}  {gate}
  ...

Ready to start? [Y/n]
═══════════════════════════════════
```

### Step 2: Execute Each Step

**ENFORCEMENT: When executing a sub-command within a flow, follow that sub-command's COMPLETE procedure including all enforcement protocols. A flow does not grant permission to shortcut any sub-command.**

**ENFORCEMENT: Each sub-command in a flow MUST complete its verification protocol before the gate check. The gate checks the sub-command's actual result, not a guess.**

For each step in the flow:

1. **Announce**: `▶ Step {N}/{total}: /healer:{command}`
2. **Execute**: Run the healer sub-command by following its full procedure
3. **Capture result**: SUCCESS / FAILURE / PARTIAL
4. **Write state** to `.healer/state.json`:
   ```json
   {
     "flow": "{name}",
     "current_step": N,
     "total_steps": M,
     "steps": [
       { "command": "brainstorm", "status": "completed", "timestamp": "..." },
       { "command": "plan", "status": "in_progress", "timestamp": "..." }
     ],
     "suggested_next": "implement"
   }
   ```
5. **Apply gate logic**:

   | Gate | On SUCCESS | On FAILURE |
   |------|-----------|------------|
   | `→` (auto) | Continue to next step | Log warning, continue anyway |
   | `?→` (interactive) | Ask user: "Step passed. Continue to {next}? [Y/n/skip]" | Ask user: "Step failed. Continue anyway? [Y/n/abort]" |
   | `!→` (must-pass) | Continue to next step | **HALT flow**. Report failure. Suggest `/healer:fix` |

### Step 3: Handle Breaks and Resumption

If the flow is interrupted (user says no at a checkpoint, or session ends):

1. State is saved to `.healer/state.json`
2. Next time `/healer:flow` is called with no args:
   ```
   HEALER FLOW — Resume
   ═══════════════════════════════════
   Flow: {name}
   Progress: {N}/{total} steps completed
   Last completed: healer:{command} ✅

   Resume from: healer:{next_command}? [Y/n/restart]
   ═══════════════════════════════════
   ```

### Step 4: Smart Next-Step Suggestion

When ANY healer sub-command finishes (even outside a flow), it should write to `.healer/state.json`:
```json
{ "last_command": "{command}", "status": "{result}", "suggested_next": "{next}", "timestamp": "..." }
```

The **SUGGESTED NEXT graph** (what naturally follows what):

```
brainstorm    → plan, design, architect, spec
plan          → implement, tdd
design        → spec, architect, implement
architect     → spec, design, plan
spec          → plan, implement
implement     → test, review, push
tdd           → coverage, review, push
test          → coverage, fix, push
coverage      → test, fix
debug         → fix, test
fix           → test, diagnose, push
refactor      → test, review, push
optimize      → test, review, push
review        → fix, push, ship
analyze       → refactor, audit, fix
audit         → fix, implement
diagnose      → fix, report, deploy
report        → fix, deploy
research      → brainstorm, design, implement
push          → ship, deploy
ship          → (done)
deploy        → (done)
docs          → push
```

When `/healer` is called with NO arguments and state exists:
```
💡 Last: /healer:{last_command} {status_emoji}
   Suggested next: /healer:{suggested_next}

   Continue with /healer:{suggested_next}? [Y/n/other]
```

### Step 5: Flow Report

After all steps complete (or flow halts):

```
HEALER FLOW REPORT
═══════════════════════════════════
Flow: {name}
Steps completed: {N}/{total}
Status: {COMPLETED / HALTED at step N / PAUSED at step N}

Step Results:
  1. ✅ healer:{command}    — {duration}
  2. ✅ healer:{command}    — {duration}
  3. ❌ healer:{command}    — {failure reason}
  ...

{If halted}:
  Halted at: Step {N} — healer:{command}
  Reason: {must-pass gate failed}
  To resume: /healer:flow   (will offer to resume)
  To fix: /healer:fix {relevant suite}

{If completed}:
  All steps passed! Flow complete.
═══════════════════════════════════
```

## Built-in Preset Definitions

```yaml
feature:
  description: "Full feature development lifecycle"
  steps:
    - command: brainstorm
      gate: interactive
    - command: plan
      gate: interactive
    - command: implement
      gate: auto
    - command: test
      gate: must-pass
    - command: review
      gate: interactive
    - command: ship
      gate: must-pass

fix:
  description: "Diagnose and fix issues"
  steps:
    - command: diagnose
      gate: auto
    - command: debug
      gate: auto
    - command: fix
      gate: auto
      args: "unit"
    - command: test
      gate: must-pass
    - command: push
      gate: interactive

deploy:
  description: "Safe deployment pipeline"
  steps:
    - command: diagnose
      gate: must-pass
    - command: review
      gate: interactive
    - command: ship
      gate: must-pass

audit:
  description: "Comprehensive health audit"
  steps:
    - command: analyze
      gate: auto
    - command: audit
      gate: auto
    - command: coverage
      gate: auto
    - command: report
      gate: auto

morning:
  description: "Quick morning health check"
  steps:
    - command: diagnose
      gate: auto
    - command: report
      gate: auto

refactor:
  description: "Research-backed code improvement"
  steps:
    - command: analyze
      gate: auto
    - command: plan
      gate: interactive
    - command: refactor
      gate: auto
    - command: test
      gate: must-pass
    - command: review
      gate: interactive
    - command: push
      gate: interactive

tdd:
  description: "Test-driven development flow"
  steps:
    - command: plan
      gate: interactive
    - command: tdd
      gate: auto
    - command: coverage
      gate: auto
    - command: review
      gate: interactive
    - command: push
      gate: interactive

research:
  description: "Deep research to specification"
  steps:
    - command: research
      gate: auto
    - command: brainstorm
      gate: interactive
    - command: design
      gate: interactive
    - command: spec
      gate: auto
```

## Custom Recipes

Users can define custom recipes in `~/.healer/recipes.yaml`:

```yaml
# ~/.healer/recipes.yaml
flows:
  pre-release:
    description: "Pre-release checklist"
    steps:
      - command: diagnose
        gate: must-pass
      - command: audit
        gate: must-pass
      - command: coverage
        gate: auto
      - command: review
        gate: interactive
      - command: docs
        gate: auto
      - command: ship
        gate: must-pass

  quick-check:
    description: "Fast health check and fix"
    steps:
      - command: diagnose
        gate: auto
      - command: fix
        args: "types"
        gate: auto
      - command: fix
        args: "lint"
        gate: auto
      - command: report
        gate: auto
```

ideate:
  description: "Full ideation pipeline from validation to plan"
  steps:
    - command: validate
      gate: interactive
    - command: brainstorm
      gate: interactive
    - command: research
      gate: auto
    - command: design
      gate: interactive
    - command: strategy
      gate: interactive
    - command: spec
      gate: interactive
    - command: plan
      gate: interactive

visual:
  description: "Visual design pipeline"
  steps:
    - command: design-system
      gate: interactive
    - command: design
      gate: interactive
    - command: design-review
      gate: auto
```

When a recipe name is provided, check `~/.healer/recipes.yaml` FIRST, then fall back to built-in presets.

## Red Flags

```
RED FLAGS — STOP AND REASSESS:

  - Tempted to skip a must-pass gate → NEVER. That's the whole point of must-pass.
  - Sub-command taking too long → it's doing the work. Don't shortcut.
  - Flow has many steps → each step is still complete. No shortcuts.
```

## Rules

1. **State is sacred** — always write to `.healer/state.json` after each step
2. **Gates are enforced** — `!→` halts on failure, no override
3. **Interactive gates ask** — never skip a `?→` checkpoint
4. **Auto gates log warnings** — if a step fails on `→`, warn but continue
5. **Resume is seamless** — `/healer:flow` with no args picks up where you left off
6. **Presets are overridable** — custom YAML recipes take precedence over built-ins
7. **Each sub-command is complete** — the flow runs the FULL procedure of each sub-command, not a shortcut
8. **Smart suggest always works** — even outside flows, every sub-command updates state with suggested_next
9. **Never force push or skip gates** — safety first
10. **Report everything** — flow report shows duration, status, and next steps for every step
