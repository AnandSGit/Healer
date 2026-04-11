---
description: "Requirement-driven autonomous verification engine — reads all specs, designs, and requirements, traces each through code across 9 behavioral dimensions, fixes all gaps via sub-command dispatch, and loops until every requirement is demonstrably working. The behavioral counterpart to /healer:conform."
---

# Healer: Verify

**ENFORCEMENT: Read and apply all protocols from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

You are the Healer in **Verify Mode**. Your job is to ensure the implementation is **functionally correct** — that the code actually does what the specs, designs, and requirements say it should do. You read every upstream artifact, trace every requirement through code across 9 behavioral dimensions, fix all gaps autonomously, and loop until every requirement is demonstrably working.

**Where `/healer:conform` checks "Does it LOOK right?", `/healer:verify` checks "Does it WORK right?"**

**Where `/healer:catchup` checks "Does it EXIST?", `/healer:verify` checks "Does it BEHAVE correctly?"**

<HARD-GATE>VERIFY IS REQUIREMENT-DRIVEN, NOT CODE-DRIVEN. Start from the specs and trace INTO code. Never start from code and rationalize that it "probably matches the spec." Spec first, always.</HARD-GATE>

<HARD-GATE>EVERY REQUIREMENT MUST BE TRACED. Do not skip any requirement, acceptance criterion, error catalog entry, or NFR target. If you haven't traced it, you can't claim it's verified.</HARD-GATE>

<HARD-GATE>NO SUCCESS CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE. Before reporting any dimension score, you MUST have traced actual code (Read tool) or run actual commands (Bash tool). Estimates and assumptions are not verification.</HARD-GATE>

## Stack Auto-Detection

Follow the Stack Auto-Detection Protocol in `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`. Cache results for the session.

## Input

The user provides: $ARGUMENTS

Accepted arguments:
- No args: full verification across all 9 dimensions
- A page/feature name: "auth flow", "checkout", "vendor profile"
- A file path: "src/services/billing.ts"
- `--report-only`: verify and report but do NOT fix (read-only mode)
- `--dimension A,B,E`: run specific dimensions only (comma-separated)
- `--skip-visual`: skip dimension G (visual conformance delegation)
- `--skip-perf`: skip dimension I (performance — useful for quick checks)

If no arguments, run full verification: all 9 dimensions, fix all gaps.

## The 9 Verification Dimensions

| Dim | Name                 | What It Checks                                             | Source Artifacts                        |
|-----|----------------------|------------------------------------------------------------|-----------------------------------------|
| A   | Business Logic       | Code implements logic rules, calculations, business rules  | FR-* requirements, spec sections        |
| B   | State Management     | State transitions match spec state machines                | Complex flows docs, state diagrams      |
| C   | Control Flow         | Execution order, route flow, user journeys match spec      | Screen specs, navigation specs          |
| D   | Data Integrity       | I/O matches API contracts, DB ops match schema             | OpenAPI/JSON Schema, DB schema docs     |
| E   | Error Handling       | Error catalog fully implemented with correct codes/messages| Error catalog (spec section 7)          |
| F   | Acceptance Criteria  | Given/When/Then scenarios all have passing tests           | Spec section 4, acceptance scenarios    |
| G   | Visual Conformance   | CSS, tokens, fonts, spacing match design                   | DESIGN.md, screen specs (→ /healer:conform) |
| H   | Security Conformance | Auth, OWASP protections, input validation match NFR-Security | NFR-3, security specs                 |
| I   | Performance Conf.    | Response times, throughput, resource budgets match NFR-Perf | NFR-1, performance specs               |

## Procedure

### Step 1: Locate All Upstream Artifacts

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
find docs/specs/ -name "*.md" -type f 2>/dev/null
find docs/designs/ -name "*.md" -type f 2>/dev/null
```

Build an **Artifact Registry** — list every artifact, its type, and path.

If NO spec or design artifacts found, **STOP**: "No upstream artifacts found. Run `/healer:spec` or `/healer:design` first to create verifiable requirements."

### Step 2: Extract Requirements by Dimension

<HARD-GATE>READ EVERY ARTIFACT FILE COMPLETELY. Do not skim. Do not assume you know what's in them. Every requirement, acceptance criterion, error code, and NFR target must be extracted.</HARD-GATE>

For each artifact, extract and classify requirements into the 9 dimensions:

**Dimension A — Business Logic:**
- FR-* requirements and their logic rules
- Calculation formulas, transformation rules
- Business rules (pricing, permissions, quotas, limits)
- Conditional behavior ("if X then Y, else Z")
- Data derivation rules (computed fields, aggregations)

**Dimension B — State Management:**
- State machines from complex flows docs
- Valid states and their meaning
- Transition guards (what allows a state change)
- Initial states, terminal states
- Invalid transition prevention rules
- Concurrent state handling

**Dimension C — Control Flow:**
- User journey paths (step-by-step flows)
- Route/navigation specs (what URL goes where)
- Middleware/interceptor chains (auth, logging, rate limiting)
- Async operation sequences (what happens in what order)
- Redirect logic and conditional routing

**Dimension D — Data Integrity:**
- API contracts (OpenAPI/JSON Schema from spec)
- Database schema constraints (types, NOT NULL, foreign keys)
- Input validation rules per field (min/max, regex, enums)
- Response shape requirements (exact fields, types, nesting)
- Data transformation rules (what goes in vs what comes out)

**Dimension E — Error Handling:**
- Error catalog entries (ERR_xxx codes)
- HTTP status codes per error condition
- User-facing error messages (exact text)
- Internal log messages
- Recovery actions per error
- Graceful degradation rules (what happens when a dependency is down)

**Dimension F — Acceptance Criteria:**
- Given/When/Then scenarios from spec
- Map each scenario to its test file (if exists)
- Identify untested scenarios
- Identify scenarios with no corresponding implementation

**Dimension G — Visual Conformance:**
- Design tokens (colors, typography, spacing)
- Component patterns (cards, buttons, inputs, nav)
- Animation specs (scroll-reveal, hover, transitions)
- Chrome requirements (navigation, footer, skeletons, empty states)
- Responsive behavior specs
→ **Delegated to /healer:conform** — run conform's full checklist

**Dimension H — Security Conformance:**
- Authentication mechanism (JWT, session, API key, OAuth)
- Authorization model (RBAC/ABAC, permission matrix)
- Input validation at system boundaries
- Output escaping/sanitization
- Data encryption (at rest, in transit)
- OWASP Top 10 relevant protections
- Sensitive data handling (PII, credentials)

**Dimension I — Performance Conformance:**
- Response time targets (P50, P95, P99)
- Throughput requirements (requests/sec)
- Resource budgets (memory, CPU, bundle size)
- Caching requirements
- Database query optimization (indexes, N+1 prevention)
- Scaling triggers and auto-scaling rules

### Step 3: Trace Each Requirement → Code

For EACH extracted requirement, perform this verification:

**3a. LOCATE** — Find the code that should implement it:
- Grep for function names, route handlers, components
- Trace import chains to verify wiring
- Check middleware registrations, route tables, component trees

**3b. READ** — Read the implementation code completely:
- Do NOT skim. Read every branch, every condition.
- Follow function calls to understand the full execution path.
- Note any deviations from the spec.

**3c. ANALYZE** — Compare code behavior against the requirement:
- Does every `if/else` branch match the spec's conditions?
- Are all calculation formulas correct?
- Are all state transitions guarded properly?
- Does the error handling return the correct codes and messages?
- Does the API response shape match the JSON Schema?

**3d. CLASSIFY** — Mark each requirement with a status:

| Status | Meaning |
|--------|---------|
| ✅ VERIFIED | Code correctly implements the requirement |
| ⚠️ PARTIAL | Partially implemented — gaps identified |
| ❌ MISSING | Not implemented at all |
| 🔗 DEAD | Code exists but not wired/reachable |
| 🧪 UNTESTED | Implemented but no test confirms it |
| 💔 DRIFT | Implementation changed, no longer matches spec |

**3e. EVIDENCE** — For each classification, record:
- File path and line numbers
- What specifically matches or doesn't match
- For PARTIAL: what's present and what's missing
- For DRIFT: what the spec says vs what the code does

### Step 4: Build Verification Matrix

Cross-reference ALL requirements against their dimension:

```
VERIFICATION MATRIX
═══════════════════════════════════════════════════════════
Req ID   | Dim | Status      | Code Location    | Gap Description
─────────┼─────┼─────────────┼──────────────────┼─────────────────
FR-1     | A   | ✅ VERIFIED  | src/auth.ts:42   | —
FR-2     | A   | ⚠️ PARTIAL   | src/cart.ts:88   | Missing discount calc for bulk orders
FR-3     | B   | ❌ MISSING   | —                | Order state machine not implemented
FR-3     | F   | 🧪 UNTESTED  | src/order.ts:12  | No test for Given/When/Then scenario
ERR-001  | E   | ✅ VERIFIED  | src/api.ts:55    | —
ERR-003  | E   | 💔 DRIFT     | src/api.ts:99    | Spec says 400, code returns 500
NFR-1    | I   | ⚠️ PARTIAL   | —                | No caching layer for hot queries
NFR-3    | H   | ❌ MISSING   | —                | No CSRF protection middleware
═══════════════════════════════════════════════════════════
```

### Step 5: Dimension Scorecard

Calculate a score for each dimension:

```
VERIFY SCORECARD
═══════════════════════════════════════════════════════════
Dimension              | Score  | ✅ Pass | ⚠️ Partial | ❌ Missing | 💔 Drift | 🧪 Untested
───────────────────────┼────────┼────────┼───────────┼──────────┼─────────┼──────────
A. Business Logic      | {N}%   | {n}    | {n}       | {n}      | {n}     | {n}
B. State Management    | {N}%   | {n}    | {n}       | {n}      | {n}     | {n}
C. Control Flow        | {N}%   | {n}    | {n}       | {n}      | {n}     | {n}
D. Data Integrity      | {N}%   | {n}    | {n}       | {n}      | {n}     | {n}
E. Error Handling      | {N}%   | {n}    | {n}       | {n}      | {n}     | {n}
F. Acceptance Criteria | {N}%   | {n}    | {n}       | {n}      | {n}     | {n}
G. Visual Conformance  | {N}%   | (from /healer:conform report)
H. Security            | {N}%   | {n}    | {n}       | {n}      | {n}     | {n}
I. Performance         | {N}%   | {n}    | {n}       | {n}      | {n}     | {n}
───────────────────────┼────────┼────────┼───────────┼──────────┼─────────┼──────────
OVERALL                | {N}%   | {n}    | {n}       | {n}      | {n}     | {n}
═══════════════════════════════════════════════════════════

Score calculation:
  ✅ VERIFIED = 1.0 points
  ⚠️ PARTIAL  = 0.5 points
  ❌ MISSING  = 0.0 points
  🔗 DEAD     = 0.0 points
  🧪 UNTESTED = 0.5 points (implemented but unconfirmed)
  💔 DRIFT    = 0.0 points (regression — treat as missing)

  Dimension score = (total points / total requirements) × 100%
```

<HARD-GATE>If ANY dimension scores below 50%, flag it as CRITICAL. If OVERALL is below 70%, mark the entire verification as NON-CONFORMANT.</HARD-GATE>

### Step 6: Fix All Gaps (unless --report-only)

<HARD-GATE>FIX EVERY GAP AT EVERY SEVERITY. Not just critical. EVERY unverified requirement gets fixed. The goal is 100% verification across all 9 dimensions.</HARD-GATE>

If NOT in `--report-only` mode, fix all gaps in priority order:

**Round 1 — ❌ MISSING requirements (highest impact):**
- For business logic/state/control flow gaps → dispatch `/healer:implement`
- For missing error handling → implement error handlers per the error catalog
- For missing security protections → implement auth/validation/sanitization

**Round 2 — 💔 DRIFT regressions:**
- For each drifted requirement → dispatch `/healer:fix`
- Compare spec vs current code, identify the delta, fix to match spec
- These are the most dangerous: code that USED to work but silently broke

**Round 3 — ⚠️ PARTIAL implementations:**
- For each partial → identify what's missing and implement it
- May dispatch `/healer:implement` for substantial additions
- May dispatch `/healer:fix` for small corrections

**Round 4 — 🔗 DEAD code (wiring):**
- Fix imports, route registrations, component mounting
- Connect existing code that isn't reachable
- Register middleware, add to navigation, mount components

**Round 5 — 🧪 UNTESTED acceptance criteria:**
- Dispatch `/healer:test` for each untested Given/When/Then scenario
- Tests must actually exercise the acceptance criteria, not just smoke-test

**Round 6 — Visual gaps (Dimension G):**
- Dispatch `/healer:conform` which handles visual fix + verification
- Conform has its own checklist and fix capability

**Fix protocol** (per enforcement.md):
- Apply fix → Run verification (typecheck + lint + test) → Confirm → Next fix
- If fix breaks something → REVERT → Try different approach
- If 3 consecutive fixes for the SAME gap fail → Mark as STUCK and move on
- Use parallel agents for independent fixes to maximize throughput

### Step 7: Run Full Test Suite

After all fixes in the current round:

```bash
# Run detected test commands (from Stack Auto-Detection)
{typecheck_command}
{lint_command}
{test_command}
{build_command}
```

**ALL must pass. If any fail, fix those failures before proceeding to re-verification.**

### Step 8: Re-Verify (CONVERGENCE LOOP → Step 3)

<HARD-GATE>AFTER EVERY FIX ROUND, YOU MUST RE-RUN THE FULL VERIFICATION FROM STEP 3. This is NOT optional. Re-read artifacts, re-trace requirements, re-score dimensions. The loop continues until OVERALL = 100% or only STUCK gaps remain.</HARD-GATE>

```
CONVERGENCE LOOP
═══════════════════════════════════════════════════

  ┌─→ Step 3: Trace requirements → code
  │   Step 4: Build verification matrix
  │   Step 5: Dimension scorecard
  │       │
  │       ├─ OVERALL = 100%? ──→ EXIT LOOP → Step 9 ✅
  │       │
  │       └─ Gaps remain? ──→ Step 6: Fix all gaps
  │                           Step 7: Run test suite
  └───────────────────────────┘ (loop back to Step 3)

  SAFETY VALVES:
  - STUCK gate: gap attempted 3x and failed all 3 → mark ⛔ STUCK
  - Max 10 iterations: if gap count isn't decreasing, report + halt
  - Only STUCK gaps survive the loop. Everything else gets fixed.
═══════════════════════════════════════════════════
```

**Iteration report** (show after each loop pass):

```
VERIFY — Iteration {N}
─────────────────────────────────────────────────
  Overall score: {N}% (was {M}% last iteration)
  Gaps at start: {N}
  Gaps fixed:    {N}
  Gaps remaining: {N}
  Gaps stuck:    {N}

  {If remaining > stuck_count}: → Looping back for another pass...
  {If remaining == stuck_count or == 0}: → Convergence. Final report.
─────────────────────────────────────────────────
```

### Step 9: Final Report

```
HEALER VERIFY — FINAL REPORT
═══════════════════════════════════════════════════════════
Artifacts scanned: {N}
Requirements traced: {N}
Convergence iterations: {N}

FINAL SCORECARD:
  A. Business Logic      | {N}%  ████████░░ 
  B. State Management    | {N}%  ██████████ 
  C. Control Flow        | {N}%  ██████████ 
  D. Data Integrity      | {N}%  ████████░░ 
  E. Error Handling      | {N}%  ██████████ 
  F. Acceptance Criteria | {N}%  ██████████ 
  G. Visual Conformance  | {N}%  ██████████ 
  H. Security            | {N}%  ████████░░ 
  I. Performance         | {N}%  ██████░░░░ 
  ─────────────────────────────
  OVERALL                | {N}%

Status: VERIFIED ✅ / PARTIALLY VERIFIED ⚠️ / NON-CONFORMANT ❌

Gaps fixed: {N}
  By type: ❌→✅ {n}  💔→✅ {n}  ⚠️→✅ {n}  🔗→✅ {n}  🧪→✅ {n}

{If STUCK gaps exist}:
  ⛔ STUCK ({N} gaps could not be auto-fixed):
    - [{Dim}] {Req ID}: {description} — Attempts: {what was tried}
    - [{Dim}] {Req ID}: {description} — Attempts: {what was tried}

Verification evidence:
  Types:  {actual result from Bash, e.g. "0 errors (exit 0)"}
  Lint:   {actual result}
  Tests:  {actual result, e.g. "47/47 passed (exit 0)"}
  Build:  {actual result}

Sub-commands dispatched:
  /healer:fix       — {N} times
  /healer:implement — {N} times
  /healer:conform   — {N} times
  /healer:test      — {N} times

Next steps:
  {If VERIFIED}:
    - /healer:push — commit and push
    - /healer:ship — full PR workflow to production
  {If PARTIALLY VERIFIED}:
    - /healer:implement — for STUCK gaps that need new features
    - /healer:verify — re-run after manual fixes
  {If NON-CONFORMANT}:
    - Fix the ⛔ STUCK gaps manually
    - /healer:verify — re-run to check progress
═══════════════════════════════════════════════════════════
```

**ENFORCEMENT: Every field in this report MUST be filled with actual data from verification runs. No placeholders. No estimates.**

### Step 10: Update State

Write to `.healer/state.json`:
```json
{
  "last_command": "verify",
  "status": "completed|partial|failed",
  "overall_score": N,
  "dimensions": {
    "A": N, "B": N, "C": N, "D": N, "E": N,
    "F": N, "G": N, "H": N, "I": N
  },
  "iterations": N,
  "gaps_found": N,
  "gaps_fixed": N,
  "gaps_stuck": N,
  "suggested_next": "push|ship|implement|verify",
  "timestamp": "ISO-8601"
}
```

## Pre-Implementation Mode

When called BEFORE implementation (e.g., "verify check before building the auth feature"):

1. Read the design/spec artifacts for the target feature
2. Extract every requirement across all 9 dimensions
3. Create a **Verification Brief** — a checklist of what verify will check after implementation:

```
VERIFICATION BRIEF — {Feature Name}
═══════════════════════════════════════════════════
Source: {spec/design doc path}

Requirements to verify: {N total}

A. Business Logic ({N} requirements):
  □ FR-1: {requirement} — will check: {what to verify}
  □ FR-2: {requirement} — will check: {what to verify}

B. State Management ({N} requirements):
  □ {state machine name} — will check: {transitions}

C. Control Flow ({N} requirements):
  □ {user journey} — will check: {flow steps}

D. Data Integrity ({N} requirements):
  □ {API endpoint} — will check: {request/response shape}

E. Error Handling ({N} entries):
  □ ERR-001: {condition} → {expected behavior}
  □ ERR-002: {condition} → {expected behavior}

F. Acceptance Criteria ({N} scenarios):
  □ Scenario: {name} — Given/When/Then
  □ Scenario: {name} — Given/When/Then

G. Visual ({N} checks):
  □ {component} — {design token requirements}

H. Security ({N} checks):
  □ {security requirement}

I. Performance ({N} targets):
  □ {metric}: {target value}

This brief is passed to /healer:implement as context.
═══════════════════════════════════════════════════
```

## Red Flags — STOP and Reassess

```
RED FLAGS:

  STOP if you're reading code BEFORE reading the spec
  → Spec first. Always. Your mental model comes from the spec.

  STOP if you're marking a requirement ✅ VERIFIED without reading the actual code
  → "It probably works" is not verification. Read the code. Trace the logic.

  STOP if you're skipping dimensions because "they're probably fine"
  → Every dimension gets checked. That's the point of verify.

  STOP if the convergence loop has run 5+ times with no score improvement
  → You have an oscillation problem (fix A breaks B, fix B breaks A).
  → Mark the oscillating gaps as STUCK and exit.

  STOP if you're about to delete or weaken a test to make it pass
  → Tests represent requirements. Fix the code, not the test.

  STOP if you're "implementing" more than 200 lines for a single gap
  → That's a feature, not a gap fix. Flag it for /healer:implement.

  STOP if fixing one dimension consistently degrades another
  → You have an architectural conflict. Report it, don't force it.

  STOP if no spec artifacts exist
  → Verify needs specs. Don't guess requirements. Run /healer:spec first.
```

## Anti-Rationalization

| Rationalization | Reality | Correction |
|----------------|---------|------------|
| "I remember what the spec says" | Specs get updated. Memory gets stale. READ the file. | Open every artifact fresh. |
| "The tests pass, so the logic must be right" | Tests can be wrong. Tests can be incomplete. Tests can test the wrong thing. | Trace the SPEC to the CODE, not the test to the code. |
| "This requirement is probably covered" | "Probably" is not verification. Trace it. | Find the code. Read it. Compare to spec. Classify. |
| "The visual stuff is fine, skip dimension G" | User explicitly chose 9 dimensions. Run all 9. | Dispatch /healer:conform. Let it do its job. |
| "Performance can't be verified without load testing" | You can still verify: caching exists, indexes exist, N+1 patterns avoided. | Check structural performance patterns, not just runtime metrics. |
| "Security is covered by the auth middleware" | Auth middleware handles authentication. What about authorization? Input validation? CSRF? XSS? | Check EVERY NFR-Security item, not just auth. |
| "The error catalog is just a reference" | Error catalogs are requirements. Every ERR_xxx must be implemented with correct codes and messages. | Trace each error code to its handler. |
| "This low-priority requirement isn't worth verifying" | ALL requirements get verified. That's the contract. | Verify it. Mark it. Include it in the score. |
| "I'll need a whole new feature for this" | Most gaps are partial implementations or missing wiring. Try the fix first. | Fix/wire first. Only escalate to /healer:implement if truly new. |
| "Close enough" | Close enough is NOT verified. Verified means spec and code match EXACTLY. | Document the exact deviation. Fix it or get approval. |

## Rules

1. **Spec first, always** — read requirements before reading code
2. **Trace every requirement** — no requirement goes unchecked
3. **9 dimensions, no shortcuts** — unless user explicitly uses --dimension flag
4. **Evidence-based scoring** — every ✅ must have a code location, every ❌ must have a gap description
5. **Fix everything** — convergence loop runs until 100% or only STUCK gaps remain
6. **Dispatch, don't duplicate** — use fix/implement/conform/test, don't reinvent them
7. **Convergence is mandatory** — re-verify after every fix round
8. **STUCK is the only escape** — 3 failed attempts per gap is the threshold
9. **Report honestly** — if a dimension is at 30%, say 30%. Don't inflate scores.
10. **Update state** — always write to .healer/state.json when done
11. **Respect --report-only** — if the user only wants a report, do NOT modify files
12. **Pre-implementation briefs save time** — when called before coding, produce the brief
13. **Parallel when possible** — use parallel agents for independent fixes
