# Design: Karpathy Principles Integration (v9.0.0)

**Date:** 2026-04-15
**Target version:** Healer v9.0.0 (breaking: new enforcement rules)
**Status:** Designed — pending spec → plan → implementation
**Approach:** B — Big Bang (all deliverables in single release)
**Traces to:** ~/.healer/brainstorms/2026-04-15-karpathy-in-healer.md

---

## Problem Statement

Two overlapping command systems are active: Healer (41 commands) and forrestchang's andrej-karpathy-skills (7 slash commands + 1 skill). Six of the 7 forrestchang commands collide with Healer equivalents, causing ambiguous dispatch. Additionally, Karpathy's coding principles (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) are delivered as a passive CLAUDE.md skill — Claude may ignore them when context is long or task seems unrelated. Two of the four principles (P2 Simplicity, P3 Surgical) have no enforcement in Healer today.

## Design Goals

1. **Consolidation** — eliminate command collision by incorporating Karpathy into Healer natively
2. **Enforcement** — upgrade from passive skill to HARD-GATE enforcement (active, not suggested)
3. **Dedup** — no parallel commands; existing Healer commands become Karpathy-aware via enforcement
4. **Flow-composable** — Karpathy checks usable as flow steps and gates
5. **Self-scoping** — P2/P3 gates activate only during code-writing, dormant during ideation

---

## Architecture

```
┌──────────────────────────────────────────────────────────────┐
│  _enforcement.md (shared by all 41+ commands)                │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ EXISTING                                                │ │
│  │  • Research Protocol HARD-GATE (P1 partial)             │ │
│  │  • Verification Protocol HARD-GATE (P4 covered)         │ │
│  │  • Fix Verification Protocol HARD-GATE                  │ │
│  │  • Anti-Rationalization Table                           │ │
│  │  • Red-Flag Stop Conditions                             │ │
│  └─────────────────────────────────────────────────────────┘ │
│  ┌─────────────────────────────────────────────────────────┐ │
│  │ NEW (v9.0.0)                                            │ │
│  │  • P1 Enhancement (surface tradeoffs) → into Research   │ │
│  │  • P2 Simplicity Protocol HARD-GATE (self-scoped)       │ │
│  │  • P3 Surgical Changes Protocol HARD-GATE (self-scoped) │ │
│  │  • P4 Documentation note (already covered)              │ │
│  │  • 5 new anti-rationalization entries                   │ │
│  │  • 3 new red-flag stop conditions                      │ │
│  └─────────────────────────────────────────────────────────┘ │
└──────────────────────────────────────────────────────────────┘
           │ read by every command
           ▼
┌──────────────────────┐  ┌──────────────────────┐
│ commands/karpathy.md │  │ commands/review.md   │
│ (NEW — focused lens) │  │ (UNCHANGED)          │
│                      │  │                      │
│ P1-P4 check on diff  │  │ Full review:         │
│ Per-file pass/fail   │  │ correctness, security│
│ Karpathy Report      │  │ performance, etc.    │
└──────────┬───────────┘  └──────────────────────┘
           │
           ▼
┌──────────────────────────────────────────────────────────────┐
│  flow.md — new presets                                       │
│  • karpathy-review: implement → karpathy !→ push             │
│  • karpathy-fix: karpathy → fix → karpathy !→ push           │
│  • suggested_next graph: karpathy → fix, implement, push     │
└──────────────────────────────────────────────────────────────┘
```

---

## Deliverable 1: _enforcement.md Insertions (~150 lines)

### 1A. P1 Enhancement — Surface Tradeoffs
**Location:** Insert into existing Research Protocol section (~line 112)
**Content:**
```
Before implementing any solution:
- State your assumptions explicitly. If uncertain, ask.
- If multiple valid approaches exist, present them with tradeoffs —
  do not silently pick one.
- If a simpler approach exists than what was requested, say so.
  Push back when warranted.
```
**Traces to:** REQ-F03

### 1B. P2 Simplicity Protocol (new HARD-GATE)
**Location:** After Red-Flag Stop Conditions (~line 288), before Stack Auto-Detection
**Scoping:** Self-scoped via SCOPE clause — applies only when using Write/Edit on source
**Heuristic test:** "If you write 200 lines and it could be 50, rewrite it"
**Self-check:** "Would a senior engineer say this is overcomplicated?"
**Rules:**
1. No features beyond what was asked
2. No abstractions for single-use code
3. No unrequested flexibility/configurability
4. No error handling for impossible scenarios
5. No speculative future-proofing
**Traces to:** REQ-F01, REQ-C05

### 1C. P3 Surgical Changes Protocol (new HARD-GATE)
**Location:** Immediately after P2
**Scoping:** Same self-scoped clause
**Traceback test:** "Every changed line should trace directly to the user's request"
**Rules:**
1. Don't improve adjacent code, comments, or formatting
2. Don't refactor things that aren't broken
3. Match existing style
4. Mention unrelated dead code — don't delete it
5. Remove only orphans YOUR changes created
**Traces to:** REQ-F02, REQ-C06

### 1D. P4 Documentation Note
**Location:** After Verification Protocol (~line 205)
**Content:** 3-line note: "Karpathy P4 is fully covered by Verification + Fix Verification Protocols above."
**Traces to:** REQ-F04

### 1E. Anti-Rationalization Entries (5 new rows)
**Location:** Append to existing table (~line 253)
**Entries:**
1. "This abstraction will be reusable later" → YAGNI
2. "I'll add this config flag for future flexibility" → speculative
3. "While I'm here, I'll clean up adjacent code" → drive-by P3 violation
4. "This needs a proper architecture" → over-architecture for small tasks
5. "The user will want this configured later" → future requirement speculation
**Traces to:** REQ-F06

### 1F. Red-Flag Stop Conditions (3 new entries)
**Location:** Append to existing red flags (~line 287)
**Entries:**
1. STOP if change touches files not mentioned in the task
2. STOP if introducing abstraction for single call site
3. STOP if diff includes unrelated formatting/style changes
**Traces to:** REQ-F07

### Line budget
Current: 542 | Additions: ~150 | Projected: ~692 | Cap: 800 | Headroom: ~108
**Traces to:** REQ-NF01

---

## Deliverable 2: commands/karpathy.md (new, ~200 lines)

**Category:** quality (alongside review)
**Relationship to review:** Focused lens (4 principles only) vs full review (correctness, security, performance, conventions, maintainability). Complementary, not competing.

### Procedure
1. **Gather Changes** — same input parsing as review (diff, PR, branch, file, last commit)
2. **Research Phase** — WebSearch for principle-specific patterns relevant to the changes
3. **Four-Principle Check** — evaluate every changed file against P1-P4:
   - P1: Were assumptions surfaced? Tradeoffs presented?
   - P2: Speculative code? Unused abstractions? Over-engineering?
   - P3: All changes trace to request? Drive-by cleanups?
   - P4: Verifiable goals? Testable changes?
4. **Produce Karpathy Report** — per-principle, per-file pass/fail with specific citations

### Report format
```
HEALER KARPATHY REVIEW
═══════════════════════════════════
Scope: {scope}
Verdict: {CLEAN / VIOLATIONS FOUND}

P1 — THINK BEFORE CODING     {✅/⚠️}
P2 — SIMPLICITY FIRST        {✅/⚠️}
P3 — SURGICAL CHANGES        {✅/⚠️}
P4 — GOAL-DRIVEN EXECUTION   {✅/⚠️}

[per-principle violation details]

SUMMARY: {N} violations across {M} files
Next: /healer:fix
═══════════════════════════════════
```

**Traces to:** REQ-F05, REQ-C01

---

## Deliverable 3: Flow Integration

### 3A. New presets in flow.md
```yaml
karpathy-review:
  description: "Karpathy-lens review before shipping"
  steps: implement → karpathy !→ push

karpathy-fix:
  description: "Karpathy review + fix loop"
  steps: karpathy → fix → karpathy !→ push
```

### 3B. Suggested-next graph additions
```
karpathy    → fix, implement, push, review
implement   → add karpathy to existing list
review      → add karpathy to existing list
refactor    → add karpathy to existing list
```

**Traces to:** REQ-F08, REQ-F12

---

## Deliverable 4: Data Files

### Prerequisites
```bash
git checkout HEAD -- data/   # restore deleted data files
```

### 4A. data/commands.yaml — new karpathy entry (~70 lines)
Category: quality | Next: fix, implement, push, review | Related: review, refactor, verify

### 4B. data/flows.yaml — new karpathy-review and karpathy-fix presets

### 4C. Rebuild: `bash scripts/build-help-index.sh`

**Traces to:** REQ-F10, REQ-F11

---

## Deliverable 5: Version + Changelog

- plugin.json: 8.1.0 → 9.0.0
- CHANGELOG.md: document all changes with REQ traceability

**Traces to:** REQ-C04

---

## Self-Scoping Design (key innovation)

Instead of a command-type metadata system, each HARD-GATE contains a SCOPE clause:

```
SCOPE: This gate applies when the current command is about to write or
modify source code files (Write or Edit tools on project source). It
does NOT apply to artifacts, data files, or documentation. If the
current command is purely analytical or ideation, this gate is dormant.
```

This handles mixed commands naturally: /healer:fix in research phase → dormant; /healer:fix writing code → active. Zero per-command edits needed.

**Traces to:** REQ-F09, REQ-C07

---

## Risk Register

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| HARD-GATE text ignored on long context | Medium | High | Primacy placement + HARD-GATE wording + anti-rationalization table |
| P2/P3 conflict with /healer:refactor | Low | Medium | Self-scoping: refactor writes code (gates active) but its PURPOSE is broad change — the gate says "trace to request" and refactor's request IS broad change |
| Enforcement bloat (>800 lines) | Low | Medium | Budget tracked: 692/800 projected. Future additions monitored. |
| forrestchang plugin still installed | Low | Low | User manually removes when ready. Collision reduced since Healer commands take priority via explicit invocation. |

---

## Requirement Traceability

| REQ | Deliverable | Location |
|-----|-------------|----------|
| REQ-F01 | 1B | _enforcement.md: P2 HARD-GATE |
| REQ-F02 | 1C | _enforcement.md: P3 HARD-GATE |
| REQ-F03 | 1A | _enforcement.md: Research Protocol enhancement |
| REQ-F04 | 1D | _enforcement.md: P4 documentation note |
| REQ-F05 | 2 | commands/karpathy.md |
| REQ-F06 | 1E | _enforcement.md: anti-rationalization entries |
| REQ-F07 | 1F | _enforcement.md: red-flag entries |
| REQ-F08 | 3A | flow.md: presets |
| REQ-F09 | self-scoping | SCOPE clause in each HARD-GATE |
| REQ-F10 | 4A | data/commands.yaml |
| REQ-F11 | 4C | scripts/build-help-index.sh |
| REQ-F12 | 3A+3B | flow.md: presets + suggested-next |
| REQ-NF01 | all | 692/800 line budget |
| REQ-NF02 | all | No existing command files modified |
| REQ-NF03 | self-scoping | SCOPE clause makes gates dormant for ideation |
| REQ-NF04 | 2 | karpathy command research phase uses WebSearch |
| REQ-C01-C07 | all | Traced above |
