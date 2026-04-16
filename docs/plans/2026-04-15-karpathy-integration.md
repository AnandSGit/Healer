# Plan: Karpathy Principles Integration (v9.0.0)

**Date:** 2026-04-15
**Design:** docs/designs/2026-04-15-karpathy-integration.md
**Spec:** docs/specs/2026-04-15-karpathy-integration.md
**Brainstorm:** ~/.healer/brainstorms/2026-04-15-karpathy-in-healer.md
**Research:** ~/.healer/research/2026-04-15-karpathy-in-healer.md

---

## Implementation Order

### Critical Path
```
T0 → T1 → T2 → T3/T4/T5 (parallel) → T6 → T7 → T8
```

### Dependency Graph
```
                ┌──────────────┐
                │ T0: Restore  │
                │ data/ files  │
                └──────┬───────┘
                       │
                ┌──────┴───────┐
                │ T1: Edit     │
                │ _enforcement │
                │ .md (P1-P4)  │
                └──────┬───────┘
                       │
                ┌──────┴───────┐
                │ T2: Create   │
                │ commands/    │
                │ karpathy.md  │
                └──────┬───────┘
                       │
          ┌────────────┼────────────┐
          │            │            │
   ┌──────┴──────┐ ┌──┴──────┐ ┌──┴──────────┐
   │ T3: Update  │ │ T4: Add │ │ T5: Update  │
   │ flow.md     │ │ commands│ │ flows.yaml  │
   │ presets +   │ │ .yaml   │ │ entry       │
   │ next graph  │ │ entry   │ │             │
   └──────┬──────┘ └──┬──────┘ └──┬──────────┘
          │            │            │
          └────────────┼────────────┘
                       │
                ┌──────┴───────┐
                │ T6: Version  │
                │ bump + CLOG  │
                └──────┬───────┘
                       │
                ┌──────┴───────┐
                │ T7: Rebuild  │
                │ help-index   │
                └──────┬───────┘
                       │
                ┌──────┴───────┐
                │ T8: Run ATs  │
                │ (15 tests)   │
                └──────────────┘
```

---

## Task Details

### T0: Restore deleted data files
**Priority:** PREREQUISITE
**Est:** 1 min
**Blocks:** T4, T5, T7

```bash
git checkout HEAD -- data/
ls data/commands.yaml data/flows.yaml data/help-index.json data/schema/
```

**Verify:** All 5 data files exist.

---

### T1: Edit shared/_enforcement.md (6 insertions)
**Priority:** CRITICAL — all commands inherit from this file
**Est:** 45-60 min
**Blocks:** T2
**Traces to:** REQ-F01, REQ-F02, REQ-F03, REQ-F04, REQ-F06, REQ-F07
**Acceptance tests:** AT-01, AT-02, AT-03, AT-04, AT-05, AT-06, AT-12

#### T1a: P1 Enhancement — Surface Tradeoffs
**Insert into:** Research Protocol section, after "NO CODE CHANGES WITHOUT COMPLETING THE RESEARCH PHASE FIRST" (~line 112)
**Add ~4 lines:**
```
Before implementing any solution:
- State your assumptions explicitly. If uncertain, ask.
- If multiple valid approaches exist, present them with tradeoffs —
  do not silently pick one.
- If a simpler approach exists than what was requested, say so.
  Push back when warranted.
```

#### T1b: P4 Documentation Note
**Insert after:** Verification Protocol section (~line 205)
**Add ~3 lines:**
```
NOTE: Karpathy P4 (Goal-Driven Execution) is fully covered by the
Verification Protocol and Fix Verification Protocol above. Transform
tasks into verifiable goals before implementing. No additional gate needed.
```

#### T1c: Anti-Rationalization Entries (5 new rows)
**Append to:** Existing Anti-Rationalization Table (~line 253)
**Add 5 rows:**

| Rationalization | Reality | Correction |
|---|---|---|
| "This abstraction will be reusable later" | Single-use abstractions are debt, not investment. YAGNI. | Write the direct implementation. Extract only when a second caller appears. |
| "I'll add this config flag for future flexibility" | Unrequested configurability is speculative code. | Build what was asked. If they need a flag later, they'll ask. |
| "While I'm here, I'll clean up this adjacent code" | Drive-by cleanups create noisy diffs and hide the real change. | File a separate issue or mention it. Don't mix it into this diff. |
| "This needs a proper architecture" | For a small task, "proper architecture" often means over-architecture. | Match the solution's complexity to the problem's complexity. |
| "The user will want this configured later" | You're speculating about future requirements. | Solve today's problem. Tomorrow's requirements get tomorrow's code. |

#### T1d: Red-Flag Stop Conditions (3 new entries)
**Append to:** Existing Red-Flag Stop Conditions block (~line 287)
**Add ~6 lines:**
```
  STOP if your change touches files not mentioned in the task
  → You're making surgical drift. Trace every file back to the request.

  STOP if you're introducing an abstraction for a single call site
  → That's speculative reuse. Write the direct code. Extract later if needed.

  STOP if your diff includes formatting/style changes unrelated to the task
  → Separate concerns: style changes get their own commit, not mixed in.
```

#### T1e: P2 Simplicity Protocol (new HARD-GATE)
**Insert after:** Red-Flag Stop Conditions section (~line 293, after T1d additions)
**Add ~25 lines:**
```markdown
## HARD-GATE: Simplicity Protocol (Karpathy P2)

<HARD-GATE>
SCOPE: This gate applies when the current command is about to write or
modify source code files (Write or Edit tools on project source). It
does NOT apply to artifacts (~/.healer/), data files, or documentation.
If the current command is purely analytical or ideation, this gate is
dormant.

MINIMUM CODE THAT SOLVES THE PROBLEM. NOTHING SPECULATIVE.

Before writing or modifying code, verify:
1. No features beyond what was asked
2. No abstractions for single-use code paths
3. No "flexibility" or "configurability" that wasn't requested
4. No error handling for scenarios that cannot happen
5. No speculative future-proofing

HEURISTIC TEST: If you write 200 lines and it could be 50, rewrite it.
ASK YOURSELF: "Would a senior engineer say this is overcomplicated?"
If yes, simplify before proceeding.
</HARD-GATE>
```

#### T1f: P3 Surgical Changes Protocol (new HARD-GATE)
**Insert immediately after:** P2 Simplicity Protocol
**Add ~25 lines:**
```markdown
## HARD-GATE: Surgical Changes Protocol (Karpathy P3)

<HARD-GATE>
SCOPE: Same as Simplicity Protocol — applies only when writing/modifying
source code via Write or Edit tools. Dormant for ideation commands.

TOUCH ONLY WHAT YOU MUST. CLEAN UP ONLY YOUR OWN MESS.

When editing existing code:
1. Do NOT "improve" adjacent code, comments, or formatting
2. Do NOT refactor things that aren't broken
3. Match existing style, even if you'd do it differently
4. If you notice unrelated dead code, MENTION it — don't delete it

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused
- Do NOT remove pre-existing dead code unless explicitly asked

TRACEBACK TEST: Every changed line should trace directly to the user's
request. If a line can't be traced, it shouldn't be in the diff.
</HARD-GATE>
```

#### T1 Verification
```bash
grep "Simplicity Protocol" shared/_enforcement.md
grep "Surgical Changes Protocol" shared/_enforcement.md
grep "TRACEBACK TEST" shared/_enforcement.md
grep "Karpathy P4" shared/_enforcement.md
grep -c "abstraction will be reusable\|config flag for future\|clean up.*adjacent\|proper architecture\|configured later" shared/_enforcement.md  # expect ≥5
grep -c "touches files not mentioned\|abstraction for a single call site\|formatting.*style.*unrelated" shared/_enforcement.md  # expect ≥3
wc -l < shared/_enforcement.md  # expect < 800
```

---

### T2: Create commands/karpathy.md (~200 lines)
**Priority:** HIGH — the new user-facing command
**Est:** 60-90 min
**Blocks:** T3, T4, T5
**Traces to:** REQ-F05, REQ-C01, REQ-NF04
**Acceptance tests:** AT-07

#### Structure
```
---
description: "Karpathy-lens code review — checks recent changes against
  the four Karpathy principles (Think Before Coding, Simplicity First,
  Surgical Changes, Goal-Driven Execution) with research-augmented
  validation."
---

<!-- Help metadata: data/commands.yaml -->

# Healer: Karpathy

**ENFORCEMENT:** [standard reference]

## Stack Auto-Detection
[standard reference]

## Input
$ARGUMENTS — same parsing as review.md:
  Empty → git diff (uncommitted)
  PR number → git diff main...branch
  Branch → git diff main...branch
  File → read file + git log
  "last commit" → git diff HEAD~1

## Procedure

### Step 1: Gather Changes
[same as review Step 1]

### Step 2: Research Phase
WebSearch for principle-specific patterns:
  1. WebSearch("{pattern found} over-engineering simplify")
  2. WebSearch("{framework} minimal implementation {feature}")
  3. WebSearch("{change type} surgical diff best practice")

### Step 3: Four-Principle Check

For each changed file, evaluate:

P1 — THINK BEFORE CODING
  - Were assumptions stated?
  - Were alternative approaches considered?
  - Were tradeoffs surfaced?
  - Was simpler approach available?

P2 — SIMPLICITY FIRST
  - Features beyond request?
  - Single-use abstractions?
  - Unrequested configurability?
  - Impossible-scenario error handling?
  - Line count proportional to problem?

P3 — SURGICAL CHANGES
  - All changes trace to request?
  - Adjacent code untouched?
  - Existing style preserved?
  - No drive-by cleanups in diff?
  - Only YOUR orphans removed?

P4 — GOAL-DRIVEN EXECUTION
  - Verifiable goals defined?
  - Each change testable?
  - Success criteria clear?

### Step 4: Produce Karpathy Report

Report format (Option C — per-principle summary + per-file detail):

  HEALER KARPATHY REVIEW
  ═══════════════════════════════════
  Scope: {what was reviewed}
  Stack: {detected stack}
  Files reviewed: {N}
  Verdict: {CLEAN / VIOLATIONS FOUND}

  PRINCIPLE SUMMARY
  ─────────────────────────────────
  P1 — THINK BEFORE CODING     {✅ Clean / ⚠️ N violations}
  P2 — SIMPLICITY FIRST        {✅ Clean / ⚠️ N violations}
  P3 — SURGICAL CHANGES        {✅ Clean / ⚠️ N violations}
  P4 — GOAL-DRIVEN EXECUTION   {✅ Clean / ⚠️ N violations}

  Total: {N} violations across {M} files

  PER-FILE DETAIL
  ─────────────────────────────────
  {file_1}
    [P2] line {N} — {over-engineering description}
    [P3] line {M} — {unrelated change description}

  {file_2}
    [P1] line {N} — {hidden assumption description}

  RECOMMENDATIONS
  ─────────────────────────────────
  1. {specific fix for highest-severity violation}
  2. {specific fix}

  Next: /healer:fix — auto-fix violations
  ═══════════════════════════════════

## Anti-Rationalization Table
[karpathy-specific entries]

## Red Flags — STOP
[karpathy-specific flags]

## Rules
1. Research before judging
2. Cite specific lines, not vague concerns
3. Every violation must have a fix recommendation
4. P2/P3 do not apply to test files unless testing adds speculative code
5. Match severity to impact
6. Acknowledge clean code (positives section)
7. No false positives — uncertain findings get research, not flags
```

#### T2 Verification
```bash
test -f commands/karpathy.md && head -3 commands/karpathy.md | grep "description:"
```

---

### T3: Update commands/flow.md (presets + next graph)
**Priority:** MEDIUM
**Est:** 15-20 min
**Blocked by:** T2
**Traces to:** REQ-F08, REQ-F12
**Acceptance tests:** AT-09, AT-10

#### T3a: Add 2 presets to Built-in Presets section
After existing presets, add:
```
/healer:flow karpathy-review  # Karpathy lens: implement → karpathy !→ push
/healer:flow karpathy-fix     # Karpathy fix loop: karpathy → fix → karpathy !→ push
```

#### T3b: Add 2 preset definitions to Built-in Preset Definitions yaml
```yaml
karpathy-review:
  description: "Karpathy-lens review before shipping"
  steps:
    - command: implement
      gate: auto
    - command: karpathy
      gate: must-pass
    - command: push
      gate: interactive

karpathy-fix:
  description: "Karpathy review + fix loop"
  steps:
    - command: karpathy
      gate: auto
    - command: fix
      gate: auto
    - command: karpathy
      gate: must-pass
    - command: push
      gate: interactive
```

#### T3c: Add karpathy to Suggested Next graph
```
karpathy    → fix, implement, push, review
```

#### T3d: Add karpathy to existing entries
```
implement   → add karpathy (after existing entries)
review      → add karpathy
refactor    → add karpathy
```

#### T3 Verification
```bash
grep "karpathy-review:" commands/flow.md && grep "karpathy-fix:" commands/flow.md
grep "karpathy.*→" commands/flow.md
```

---

### T4: Update data/commands.yaml
**Priority:** MEDIUM
**Est:** 20-30 min
**Blocked by:** T0, T2
**Traces to:** REQ-F10
**Acceptance tests:** AT-08

Add full karpathy entry following existing schema pattern (see brainstorm entry as template):
```yaml
karpathy:
  category: quality
  purpose: |
    Karpathy-lens code review — checks recent changes against the four
    Karpathy principles (Think Before Coding, Simplicity First, Surgical
    Changes, Goal-Driven Execution) with research-augmented validation.
  what_it_does: |
    Gathers code changes (diff, PR, branch, or files), researches
    principle-specific patterns online, checks every change against
    P1-P4 heuristics with per-principle and per-file reporting, and
    produces a structured Karpathy Report with specific violation
    descriptions and fix recommendations.
  input:
    syntax: /healer:karpathy [target]
    args:
      - name: target
        desc: What to review — diff (default), PR number, branch, file, or "last commit"
        required: false
    valid:
      - /healer:karpathy
      - /healer:karpathy last commit
      - /healer:karpathy src/lib/auth.ts
    invalid:
      - text: /healer:karpathy fix
        why: karpathy reviews, it doesn't fix — use /healer:fix after reviewing
  example:
    command: /healer:karpathy last commit
    trace:
      - 'Runs git diff HEAD~1 to gather last commit changes'
      - 'WebSearches "{pattern} over-engineering" for each concern found'
      - 'Checks 4 files against P1-P4: finds P2 violation (unused abstraction in utils.ts) and P3 violation (reformatted adjacent function in api.ts)'
      - 'Reports: 2 violations across 2 files, P1 ✅, P2 ⚠️, P3 ⚠️, P4 ✅'
      - 'Recommends: inline the abstraction, revert the formatting change'
    why_this_example: |
      "last commit" is the most common use case — quick post-commit
      hygiene check. The example shows both P2 and P3 violations,
      demonstrating the dual per-principle + per-file report format.
  input_purpose: |
    [target] scopes what code to review. Empty means all uncommitted
    changes. Specific targets (file, PR, branch) narrow the review.
    "last commit" is the most common quick-check pattern.
  next:
    - fix
    - implement
    - push
    - review
  related:
    - review
    - refactor
    - verify
  errors:
    - If no changes found → reports "No changes to review" and suggests checking git status
    - If target file doesn't exist → error with suggestion
```

#### T4 Verification
```bash
grep "^karpathy:" data/commands.yaml
```

---

### T5: Update data/flows.yaml
**Priority:** MEDIUM
**Est:** 10 min
**Blocked by:** T0, T2
**Traces to:** REQ-F12
**Acceptance tests:** (covered by AT-09 indirectly)

Add karpathy-review and karpathy-fix entries matching the format of existing flow entries.

#### T5 Verification
```bash
grep "karpathy" data/flows.yaml
```

---

### T6: Version bump + CHANGELOG
**Priority:** MEDIUM
**Est:** 15 min
**Blocked by:** T1-T5
**Traces to:** REQ-C04
**Acceptance tests:** AT-11

#### T6a: plugin.json
```json
"version": "9.0.0"
"description": "...44 commands..." (update count from 43 to 44)
```

#### T6b: CHANGELOG.md
Add v9.0.0 entry:
```markdown
## v9.0.0 — Karpathy Principles Integration

### Breaking
- New HARD-GATE enforcement: Simplicity Protocol (P2) and Surgical Changes
  Protocol (P3) now apply to all code-writing commands via self-scoping gates
- Existing commands may flag violations that were previously silent

### Added
- `/healer:karpathy` — focused code review against 4 Karpathy principles
  (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution)
  with dual per-principle + per-file report format
- Flow presets: `karpathy-review`, `karpathy-fix`
- P1 enhancement: Research Protocol now requires surfacing tradeoffs
  and pushing back when simpler approaches exist
- 5 new anti-rationalization entries (YAGNI, speculative config, drive-by
  cleanup, over-architecture, future requirement speculation)
- 3 new red-flag stop conditions (file drift, single-use abstraction,
  unrelated formatting)

### Documented
- P4 (Goal-Driven Execution) noted as already covered by Verification
  and Fix Verification Protocols
```

#### T6 Verification
```bash
grep '"version".*"9.0.0"' plugin.json
```

---

### T7: Rebuild help-index.json
**Priority:** LOW (must run, but mechanical)
**Est:** 5 min
**Blocked by:** T0, T4, T5
**Traces to:** REQ-C03, REQ-F11
**Acceptance tests:** AT-14

```bash
bash scripts/build-help-index.sh
```

#### T7 Verification
```bash
grep "karpathy" data/help-index.json
```

---

### T8: Run all 15 acceptance tests
**Priority:** GATE — must all pass before shipping
**Est:** 10 min
**Blocked by:** T1-T7
**Traces to:** All ATs in spec

Run AT-01 through AT-15 from docs/specs/2026-04-15-karpathy-integration.md.
All 15 must pass. Any failure → fix before proceeding.

---

## Summary

| Task | Description | Est | Dependencies |
|------|-------------|-----|-------------|
| T0 | Restore data/ files | 1 min | none |
| T1 | Edit _enforcement.md (6 insertions) | 45-60 min | T0 |
| T2 | Create commands/karpathy.md | 60-90 min | T1 |
| T3 | Update flow.md (presets + graph) | 15-20 min | T2 |
| T4 | Update data/commands.yaml | 20-30 min | T0, T2 |
| T5 | Update data/flows.yaml | 10 min | T0, T2 |
| T6 | Version bump + CHANGELOG | 15 min | T1-T5 |
| T7 | Rebuild help-index.json | 5 min | T0, T4, T5 |
| T8 | Run 15 acceptance tests | 10 min | T1-T7 |
| **Total** | | **3-4 hours** | |

**Critical path:** T0 → T1 → T2 → T3/T4/T5 (parallel) → T6 → T7 → T8

**Report format decision:** Option C (per-principle summary + per-file detail)
