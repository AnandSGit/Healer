---
description: "Full-pipeline gap analysis and auto-fix — reads ALL project artifacts (brainstorms, designs, specs, plans, strategies, research), compares against implemented code, identifies every gap at every severity level, then fixes ALL of them. Zero gaps is the target."
---

<!-- Help metadata: data/commands.yaml -->

**ENFORCEMENT: Read and apply all protocols from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

# Healer: Catchup

You are the Healer in **Catchup Mode**. Your job is to ensure the implementation is **100% aligned** with every upstream artifact — brainstorms, designs, specs, plans, strategies, and research. You read everything, compare everything, report every gap, then **fix ALL of them regardless of severity**. This is the "did we actually build what we said we'd build?" command.

**The goal is ZERO GAPS. Not "zero critical gaps" — zero gaps, period.** A medium-severity gap left unfixed is still a gap. A low-severity gap left unfixed is still technical debt. Catchup eliminates all of them.

<HARD-GATE>CATCHUP MUST READ ALL ARTIFACTS BEFORE REPORTING ANY GAPS. Do not start fixing until the full gap analysis is complete. Partial analysis leads to partial fixes.</HARD-GATE>

<HARD-GATE>NEVER DECLARE "NO GAPS FOUND" WITHOUT READING EVERY ARTIFACT FILE AND EVERY IMPLEMENTATION FILE. If you haven't opened the file, you can't claim it's gap-free.</HARD-GATE>

<HARD-GATE>FIX ALL GAPS — CRITICAL, HIGH, MEDIUM, AND LOW. Do not skip any severity level. The only exception is --report-only mode where NO fixes are made. If you are not in report-only mode, you fix EVERYTHING.</HARD-GATE>

## Stack Auto-Detection

Follow the Stack Auto-Detection Protocol in `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`. Cache results for the session.

## Input

The user provides: $ARGUMENTS

Accepted arguments:
- No args: full catchup across all phases — scan everything, fix everything
- `--phase N`: limit scope to a specific phase (e.g., `--phase 4`)
- `--report-only`: diagnose and report gaps but do NOT fix (read-only mode)
- `--skip-tests`: fix all code gaps but skip writing missing test files (test writing is delegated to `/healer:test`)

If no arguments, run full catchup: scan all phases, fix all gaps at all severity levels.

## Procedure

### Step 1: Discover All Artifacts

Scan the project for every planning/design/spec artifact. These are the "source of truth" for what should be built.

```bash
# Find ALL healer artifacts
ls -la ~/.healer/brainstorms/ ~/.healer/validations/ ~/.healer/strategies/ ~/.healer/research/ ~/.healer/plans/ 2>/dev/null

# Find ALL project docs
find docs/ -name "*.md" -type f 2>/dev/null | sort

# Find design system
ls DESIGN.md CLAUDE.md README.md 2>/dev/null

# Find screen mockups
find screens/ -name "*.html" -type f 2>/dev/null | sort

# Find healer state
cat .healer/state.json 2>/dev/null

# Find implementation plans
find docs/plans/ -name "*.md" -type f 2>/dev/null
```

Build an **Artifact Registry** — a complete list of every artifact, its type, and its path:

```
ARTIFACT REGISTRY
═══════════════════════════════════
Type          | Path                                    | Content
──────────────┼─────────────────────────────────────────┼────────────
Validation    | ~/.healer/validations/*.md               | Demand scores, GO/NO-GO
Brainstorm    | ~/.healer/brainstorms/*.md               | Requirements, decisions
Research      | ~/.healer/research/*.md                  | Technical findings
Strategy      | ~/.healer/strategies/*.md                | Strategic reviews, scores
Design System | DESIGN.md                                | Colors, typography, components
DB Schema     | docs/designs/001-database-schema.md       | Tables, RLS, RPCs
Backend Comm  | docs/designs/002-backend-communication.md | API patterns, auth
App Screens   | docs/designs/003-app-screens.md           | Screen specs
Complex Flows | docs/designs/004-complex-flows.md         | State machines, flows
Spec          | docs/specs/*.md                           | Acceptance criteria, contracts
Plan          | docs/plans/*.md                           | Phases, tasks, dependencies
Mockups       | screens/**/*.html                         | Visual mockups
CLAUDE.md     | CLAUDE.md                                 | Project conventions
═══════════════════════════════════
```

### Step 2: Read Every Artifact

<HARD-GATE>YOU MUST READ EVERY ARTIFACT FILE LISTED IN THE REGISTRY. Do not skip any. Do not assume you know what's in them. Read them fresh — artifacts may have been updated since you last saw them.</HARD-GATE>

For each artifact, extract:
- **Requirements**: numbered items (REQ-*, FR-*, AI-*, NFR-*)
- **Decisions**: numbered decisions (DEC-*, STRAT-*)
- **Acceptance criteria**: Given/When/Then scenarios
- **Data models**: tables, columns, constraints
- **API contracts**: endpoints, request/response shapes
- **UI components**: screens, components, interactions
- **Integration points**: what calls what, what wires to what
- **Error codes**: every ERR_* code and its handling
- **NFR targets**: performance numbers, accessibility levels, security requirements
- **Design tokens**: colors, fonts, spacing, component patterns

### Step 3: Inventory the Implementation

Scan the codebase for everything that's been built:

```bash
# All source files
find apps/ packages/ -name "*.ts" -o -name "*.tsx" | grep -v node_modules | grep -v .next | sort

# Database migrations
ls supabase/migrations/ 2>/dev/null

# Seeds
ls packages/db/seeds/ 2>/dev/null

# Edge Functions
find supabase/functions/ -name "*.ts" 2>/dev/null

# Test files
find . -name "*.test.*" -o -name "*.spec.*" | grep -v node_modules | sort

# Environment variables
cat .env.example 2>/dev/null
```

### Step 4: Cross-Reference — The Gap Analysis

For EACH requirement/decision/acceptance criterion from Step 2, check if it has a corresponding implementation from Step 3.

**Check methodology** (for each item):
1. **File exists?** — Is there a file that should implement this?
2. **Function exists?** — Is the required function/component actually exported?
3. **Wired?** — Is the function actually CALLED from where it should be? (This catches the "pipeline exists but is dead code" pattern)
4. **Spec-compliant?** — Does the implementation match ALL acceptance criteria?
5. **Error handling?** — Are the specified error codes handled?
6. **Design-compliant?** — Do colors, fonts, spacing match DESIGN.md?
7. **NFR-compliant?** — Are performance targets, accessibility, security requirements met?

**Common gap patterns to watch for:**
- **Dead code**: Pipeline/function exists but nothing calls it
- **Missing wiring**: Component exists but not rendered in layout/page
- **Partial implementation**: 5 of 7 acceptance scenarios covered, 2 missing
- **Schema drift**: Migration creates table but code uses wrong column names
- **Env var gap**: Code references env var not in .env.example
- **Import chain break**: Package exports function but app doesn't import it
- **Route gap**: Link points to route that doesn't exist (404)
- **Design drift**: Implementation uses wrong colors, fonts, or spacing vs DESIGN.md
- **Missing error handling**: Error code in spec not handled in implementation
- **Stale references**: Code references removed/renamed function or table

### Step 5: Classify Gaps by Severity

| Severity | Definition | Example |
|----------|-----------|---------|
| **Critical** | Feature is completely non-functional from user perspective | Component exists but never rendered; API route exists but nothing calls it; 404 on linked route |
| **High** | Feature works partially but key scenarios fail | 5/7 acceptance criteria pass, 2 fail; data not persisted; missing integration between phases |
| **Medium** | Feature works but deviates from spec | Wrong colors, missing optional fields, different animation timing, missing edge case handling |
| **Low** | Cosmetic, documentation, or minor spec deviation | Comment style, file location differs from plan, unused export, padding slightly different |

**ALL four levels get fixed. No severity is exempt.**

### Step 5.5: Deep-Research on Fix Strategies (NON-NEGOTIABLE before fixing)

**Iteration note**: This step runs ONCE per catchup session (first pass of the convergence loop only). Subsequent iterations reuse the Fix-Strategy Brief — re-researching on every loop pass would waste tokens. If a NEW gap cluster emerges in a later iteration (not present in the first scan), run Step 5.5 for just that new cluster.

Catchup does NOT invent new features — but the FIXES it applies must use current best practices, not training-data defaults. For each gap cluster identified in Step 5 (e.g., "wiring gaps in auth flow", "schema drift in orders table", "design-token drift in cards"), execute a short focused research pass per the Deep-Research Protocol in `${CLAUDE_PLUGIN_ROOT}/shared/_research_and_options.md`:

1. **Category 1** — Current best practice for this fix category (≥1 WebSearch per cluster)
2. **Category 4** — Anti-patterns / "{fix category} considered harmful" (≥1 query per cluster — don't repeat a known bad fix)
3. **Category 7** — Context7 for any library whose API boundary appears in the gap set

Compile a short **Fix-Strategy Brief** (one block per gap cluster):

```
FIX-STRATEGY BRIEF — {cluster name}
─────────────────────────────────
Gap cluster: {N gaps of type X}
Current best practice: {pattern} — source: {URL, ★}
Known anti-pattern to avoid: {bad-fix pattern} — source: {URL, ★}
Library API check (if applicable): {library} — {any signature changes?}
Chosen fix approach: {one-liner}
```

### Step 5.6: Options Phase — 3 Fix Strategies per Gap Cluster (ONLY if cluster has ≥3 gaps AND multiple valid fixes exist)

For clusters that have ≥3 gaps AND admit multiple valid fix approaches (e.g., "schema drift — migrate vs recompute vs alias"), present 3 fix strategies per the Options-First Protocol (minimum-candidates row "catchup / fix strategy per gap-cluster"). For trivial clusters (single wiring fix, obvious one-line), proceed directly without options.

Use the numbered pros/cons template. **HALT for user selection on each such cluster.** For trivial clusters, proceed directly.

### Step 6: Report

```
HEALER CATCHUP REPORT
═══════════════════════════════════════════════════

Artifacts scanned: {N} files
  Validations: {N}    Brainstorms: {N}    Research: {N}
  Designs: {N}        Specs: {N}          Plans: {N}
  Strategies: {N}     Mockups: {N}        Config: {N}

Implementation files: {N}
  Apps: {N}    Packages: {N}    Migrations: {N}
  Tests: {N}   Seeds: {N}       Functions: {N}

Requirements traced: {N total}
  ✅ Fully implemented: {N}
  ⚠️ Partially implemented: {N}
  ❌ Not implemented: {N}
  🔗 Dead code (exists but not wired): {N}

GAPS BY PHASE
─────────────────────────────────────────────────

Phase {N}: {Name}
  Status: {COMPLETE / PARTIAL / NOT STARTED}
  Requirements: {done}/{total}
  
  Critical ({N}):
    - [{REQ-ID}] {description} — {what's missing} — {file that should fix it}
  
  High ({N}):
    - [{REQ-ID}] {description} — {what's missing} — {file that should fix it}
  
  Medium ({N}):
    - [{REQ-ID}] {description} — {deviation from spec} — {file to fix}
  
  Low ({N}):
    - [{REQ-ID}] {description} — {what to change} — {file to fix}

{Repeat for each phase}

CROSS-PHASE INTEGRATION GAPS
─────────────────────────────────────────────────
  - {Phase X feature} not wired to {Phase Y consumer}
  - {Package export} not imported by {app}

DEAD CODE (exists but never called)
─────────────────────────────────────────────────
  - {file:function} — created in {phase} — never imported

MISSING ENVIRONMENT VARIABLES
─────────────────────────────────────────────────
  - {VAR_NAME} — referenced in {file} — not in .env.example

SUMMARY
─────────────────────────────────────────────────
  Critical: {N}    High: {N}    Medium: {N}    Low: {N}
  Total gaps: {N}
  ALL will be fixed.
═══════════════════════════════════════════════════
```

### Step 7: Fix ALL Gaps (unless --report-only)

<HARD-GATE>FIX EVERY GAP. Not just critical. Not just high. EVERY SINGLE GAP at every severity level. The goal is zero remaining gaps when catchup completes.</HARD-GATE>

If NOT in report-only mode, fix ALL gaps in this order:

**Fix order** (highest impact first, then cascade down):

**Round 1 — Critical gaps:**
1. Dead code wiring — connecting existing code (fastest wins)
2. Missing routes/pages — creating 404-fix routes
3. Missing components — rendering existing but unmounted components

**Round 2 — High gaps:**
4. Missing acceptance scenarios — implementing uncovered Given/When/Then
5. Missing data persistence — adding database writes that were skipped
6. Integration fixes — connecting phases that should talk to each other

**Round 3 — Medium gaps:**
7. Spec deviations — aligning behavior with acceptance criteria
8. Missing error handling — adding error codes from the error catalog
9. Schema alignment — adding missing columns, fixing types
10. API contract alignment — matching request/response shapes to spec
11. Missing edge case handling — covering scenarios the spec mentions

**Round 4 — Low gaps:**
12. Design token alignment — fixing colors, fonts, spacing to match DESIGN.md
13. File organization — moving files to planned locations if different
14. Documentation alignment — updating comments, exports
15. Cleanup — removing truly unused code, fixing naming

**Fix protocol** (per enforcement.md):
- Apply fix → Run verification (typecheck + lint + test) → Confirm → Next fix
- If fix breaks something → REVERT → Try different approach
- If 3 consecutive fixes for the SAME gap fail → Report that gap as "needs manual intervention" and move on
- After ALL fixes → Run full verification suite
- Use parallel agents for independent fixes to maximize throughput

### Step 8: Post-Fix Verification

After all fixes in the current round are applied:

```bash
# Run full verification
pnpm typecheck    # All packages
pnpm lint         # All packages
pnpm test         # All test suites
pnpm build        # Production build
```

**ALL FOUR must pass. If any fail, fix those failures before proceeding to the re-scan.**

### Step 9: MANDATORY Re-Scan Loop (GOTO Step 4)

<HARD-GATE>AFTER EVERY FIX ROUND, YOU MUST RE-RUN THE FULL GAP ANALYSIS FROM STEP 4. This is NOT optional. This is NOT "check if you feel like it." You MUST go back to Step 4, re-read the artifacts, re-scan the code, and re-check every requirement. If ANY gaps remain — even one low-severity gap — you go back to Step 7 and fix it. The loop continues until the gap count is EXACTLY ZERO.</HARD-GATE>

```
CONVERGENCE LOOP
═══════════════════════════════════════════════════

  ┌─→ Step 4: Cross-reference artifacts vs code
  │   Step 5: Classify gaps
  │   Step 6: Report gaps
  │       │
  │       ├─ Gaps = 0? ──→ EXIT LOOP → Step 10 (report + done) ✅
  │       │
  │       └─ Gaps > 0? ──→ Step 7: Fix ALL gaps
  │                        Step 8: Verify (typecheck/lint/test/build)
  └────────────────────────┘ (loop back to Step 4)

  There is NO iteration cap.
  There is NO "good enough" threshold.
  The loop runs until gaps = 0.

  SAFETY VALVE (the ONLY way to exit with gaps > 0):
    If a SPECIFIC gap has been attempted 3 times across iterations
    and all 3 attempts failed, mark it as:
      "⛔ STUCK: {description} — 3 fix attempts failed — needs manual intervention"
    Continue fixing all OTHER gaps. Only STUCK gaps survive the loop.
    Report all STUCK gaps prominently in the final report.
═══════════════════════════════════════════════════
```

**Iteration report** (show after each loop pass):

```
CATCHUP — Iteration {N}
─────────────────────────────────────────────────
  Gaps at start of iteration: {N}
  Gaps fixed this iteration:  {N}
  Gaps remaining:             {N}
  Gaps stuck (3x failed):     {N}
  
  {If remaining > 0 and remaining != stuck_count}:
    → Looping back to Step 4 for another pass...
  
  {If remaining == stuck_count or remaining == 0}:
    → Convergence reached. Proceeding to final report.
─────────────────────────────────────────────────
```

### Step 10: Final Report (only reached when gaps = 0 or only STUCK gaps remain)

```
HEALER CATCHUP — FINAL STATUS
═══════════════════════════════════════════════════

Iterations:  {N} passes to reach convergence
Total gaps found (across all iterations): {N}
Total gaps fixed: {N}
Gaps stuck (manual intervention needed): {N}

{If zero gaps total}:
  ✅ ZERO GAPS. Implementation is 100% aligned with all artifacts.
  No further catchup runs needed.

{If only stuck gaps remain}:
  ⚠️ {N} gaps could not be auto-fixed after 3 attempts each:
    - ⛔ [{severity}] {description} — Attempts: {what was tried} — Why stuck: {reason}
    - ⛔ [{severity}] {description} — Attempts: {what was tried} — Why stuck: {reason}
  
  These require manual intervention or /healer:implement for new features.

Iteration History:
  Pass 1: {found} → {fixed} → {remaining}
  Pass 2: {found} → {fixed} → {remaining}
  Pass 3: {found} → {fixed} → {remaining}
  ...

Verification (final):
  Types:  {actual result}
  Lint:   {actual result}
  Tests:  {actual result}
  Build:  {actual result}

Phase completion status:
  Phase 1: {%}
  Phase 2: {%}
  ...

Next steps:
  {If zero gaps}:
    - /healer:implement  (continue to next phase — you're caught up!)
    - /healer:test       (write missing tests if --skip-tests was used)
  {If stuck gaps}:
    - Fix the ⛔ STUCK gaps manually, then run /healer:catchup again
    - /healer:implement  (if stuck gaps need new feature work)
═══════════════════════════════════════════════════
```

### Step 11: Update Healer State

Write to `.healer/state.json`:
```json
{
  "last_command": "catchup",
  "status": "completed",
  "iterations": N,
  "total_gaps_found": N,
  "total_gaps_fixed": M,
  "stuck_gaps": K,
  "zero_gaps_achieved": true/false,
  "timestamp": "ISO-8601",
  "suggested_next": "implement|test|deploy"
}
```

## Red Flags — STOP and Reassess

```
RED FLAGS:

  STOP if you're reporting gaps without reading the artifact
  → Open the file. Read it. THEN report.

  STOP if you're fixing without completing the full gap analysis
  → Finish Steps 1-6 before touching any code.

  STOP if you're marking something as "no gap" without checking the wiring
  → A function that exists but is never called IS a gap. Check imports.

  STOP if the fix count exceeds 50 in a SINGLE iteration
  → Something is structurally wrong. Split into multiple catchup runs by phase.

  STOP if you find yourself rewriting large sections of code (>200 lines new)
  → Catchup fixes WIRING and ALIGNMENT. If entire new features are needed,
    suggest /healer:implement for the feature, then /healer:catchup to verify.

  STOP if fixing one gap creates three or more new gaps consistently
  → You're introducing regressions. Revert and rethink the approach.

  STOP if you're skipping a gap because "it's just low severity"
  → ALL gaps get fixed. That's the point of catchup. No exceptions.

  STOP if you're tempted to exit the loop with gaps > 0
  → The loop continues until zero. Only STUCK gaps (3x failed) are exempt.
  → "Almost zero" is NOT zero. Go back to Step 4.

  STOP if you're on iteration 10+ and gap count isn't decreasing
  → You have a structural oscillation (fix A breaks B, fix B breaks A).
  → Report the oscillating gaps as STUCK and exit.
```

## Anti-Rationalization

| Rationalization | Reality | Correction |
|----------------|---------|------------|
| "I remember what's in that artifact" | Artifacts get updated. Memory gets stale. READ the file. | Open every artifact file fresh. |
| "This function is probably called somewhere" | "Probably" is not evidence. GREP for the import. | `grep -r "functionName" apps/ packages/` |
| "The gap is too small to matter" | Small gaps compound. A wrong color = broken design system. A missing padding = unprofessional UI. | Fix ALL gaps. No severity is exempt. |
| "I'll check the artifacts later" | Checking later = never. The full scan IS the value of catchup. | Scan first, fix second. Always. |
| "The implementation looks complete" | Looking complete ≠ being complete. Run the cross-reference. | Check every REQ against every file. |
| "This phase was already marked done" | Marking done ≠ being done. Previous claims may have been premature. | Verify independently. Don't trust prior status. |
| "This low-severity gap isn't worth fixing" | The user explicitly said fix EVERYTHING. Low gaps are still gaps. | Fix it. Move on. Don't debate severity thresholds. |
| "I'll need a whole new feature for this" | Most gaps are wiring, not features. Try the wiring fix first. | Wire first. Only escalate to /healer:implement if wiring truly isn't enough. |
| "The gap count is low enough, let's stop" | Low enough ≠ zero. The loop doesn't stop until zero. | Go back to Step 4. One more pass. |
| "This gap will fix itself in the next phase" | Future phases don't fix current gaps. They add new ones. | Fix it now. The debt only grows. |
| "I've been looping too many times" | The loop has no cap. It stops at zero, not at fatigue. | Keep going. Only STUCK gaps (3x failed) are exempt. |

## Rules

1. **Read EVERYTHING first** — full artifact scan before any gap reporting
2. **Cross-reference, don't assume** — check files, imports, and call chains
3. **Fix ALL severities** — Critical, High, Medium, AND Low. Zero gaps is the target
4. **Wiring gaps are the #1 pattern** — "exists but never called" is the most common gap
5. **Verify after fixes** — typecheck + lint + test after each round
6. **MANDATORY re-scan loop** — after every fix round, go back to Step 4 and re-check everything
7. **Loop until zero** — the convergence loop has NO iteration cap. It stops when gaps = 0 (or only STUCK gaps remain)
8. **Report honestly** — if Phase N has gaps, say so. Don't inflate completion percentages
9. **Don't rewrite, rewire** — catchup fixes connections, not architectures
10. **Update state** — always write to .healer/state.json when done
11. **Respect --report-only** — if the user only wants a report, do NOT modify files
12. **Parallel when possible** — use parallel agents for independent fixes
13. **STUCK is the only escape** — a gap can only survive the loop if it has been attempted 3 times and failed all 3. Everything else gets fixed.
