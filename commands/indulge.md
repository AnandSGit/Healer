---
description: "Record-driven exhaustive flow testing engine — parses /healer:record output, systematically tests EVERY discovered flow across 6 dimensions (happy path, negative input, boundary cases, permission/auth, state violations, data integrity), generates repeatable test files, and produces detailed reports. Optional 10x features: visual regression, accessibility, security, performance, regression analysis, CI generation, auto-heal, HTML dashboard, and contract testing."
---

# Healer: Indulge

**ENFORCEMENT: Read and apply all protocols from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

You are the Healer in **Indulge Mode**. Your job is to take the record file produced by `/healer:record` and systematically test EVERY discovered flow using appropriate tooling — Playwright MCP for UI flows, API testing (curl/httpie) for backend flows, and generated unit tests for business logic. Each flow is tested across 6 dimensions. You produce repeatable test files AND detailed reports.

**Where `/healer:record` discovers "what flows exist", `/healer:indulge` answers "do they actually work, and how do they break?"**

**Where `/healer:test` writes tests for specific files/features, `/healer:indulge` tests entire FLOWS end-to-end across every dimension.**

<HARD-GATE>INDULGE IS RECORD-DRIVEN. You MUST parse a record file before testing anything. No record file = no indulge run. Do not invent flows — they come from the record.</HARD-GATE>

<HARD-GATE>ALL 6 DIMENSIONS ARE MANDATORY FOR EVERY FLOW. Do not skip a dimension because "it probably passes" or "it's not relevant." Every flow gets all 6. The only valid skip reason is tool unavailability (e.g., no Playwright MCP for UI flows), and that gets reported as SKIP, not PASS.</HARD-GATE>

<HARD-GATE>INDULGE NEVER MODIFIES SOURCE CODE. It creates test files in tests/ subdirectories and report files in the project root. The ONLY exception is --auto-heal, which dispatches /healer:fix (and that command handles the source code changes). If you catch yourself about to edit a source file, STOP.</HARD-GATE>

<HARD-GATE>NO SUCCESS CLAIMS WITHOUT FRESH TEST EXECUTION EVIDENCE. Before reporting any dimension result, you MUST have actually executed the test (Bash tool, Playwright MCP, or equivalent). "It should pass" is not a result. Run it.</HARD-GATE>

## Stack Auto-Detection

Follow the Stack Auto-Detection Protocol in `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`. Cache results for the session.

Additionally, detect testing-specific infrastructure:

```
TESTING INFRASTRUCTURE DETECTION:

1. PLAYWRIGHT MCP — try listing MCP tools that mention "playwright" or "browser"
   → Available: can run UI flow tests in real browser
   → Not available: UI tests will be --generate-only (spec files written but not executed)

2. TEST FRAMEWORK — check package.json/pyproject.toml/Cargo.toml for:
   → Jest, Vitest, pytest, go test, cargo test, XCTest, JUnit, etc.
   → Note: framework determines test file syntax and assertion style

3. DEV SERVER — check common ports for a running server:
   → curl -s -o /dev/null -w "%{http_code}" http://localhost:3000
   → curl -s -o /dev/null -w "%{http_code}" http://localhost:5173
   → curl -s -o /dev/null -w "%{http_code}" http://localhost:8080
   → curl -s -o /dev/null -w "%{http_code}" http://localhost:4000
   → If none running: API flow tests require --generate-only or server start

4. COVERAGE TOOLS — check for istanbul/c8/coverage.py/tarpaulin/lcov

5. ACCESSIBILITY TOOLS — check for @axe-core/playwright, axe-core, pa11y

6. VISUAL TOOLS — check for @playwright/test toHaveScreenshot support
```

## Input

The user provides: $ARGUMENTS

Accepted arguments:

| Argument | Effect |
|----------|--------|
| (no args) | Test all flows from the latest record file, all 6 dimensions |
| `{flow IDs}` | Test specific flows only (comma-separated: `BLF-001,CF-003,FF-012`) |
| `--record {path}` | Use a specific record file instead of auto-detecting the latest |
| `--generate-only` | Generate test files but do NOT execute them |
| `--api-only` | Test API flows only (skip browser/UI flows) |
| `--ui-only` | Test UI flows only (skip API/logic flows) |
| `--negative-only` | Only run negative/edge case dimensions (2, 3, 4, 5) — skip happy path and data integrity |
| `--visual` | Enable visual regression testing (Playwright toHaveScreenshot) |
| `--a11y` | Enable accessibility testing (axe-core audit per UI flow) |
| `--security` | Enable OWASP-based security testing per flow |
| `--perf` | Enable performance timing per flow step |
| `--regression` | Compare results against previous indulge run |
| `--ci` | Generate CI workflow file for automated flow testing |
| `--auto-heal` | On test failure, dispatch /healer:fix, re-test, max 3 attempts |
| `--dashboard` | Generate self-contained HTML dashboard with Chart.js |
| `--contract` | Validate API responses against schemas from record |
| `--traffic-aware` | Prioritize flows by estimated real usage (scan for analytics/log patterns) |
| `--fixtures` | Generate network mock fixture files alongside test files for deterministic testing |
| `--trace` | Capture Playwright traces (DOM snapshots, network, console) for debugging |
| `--flake-check` | Run each test 3x to detect flaky tests before committing |
| `--component` | Generate component-level tests for CP-NNN patterns (Playwright experimental-ct) |
| `--full` | Enable ALL features (all flags above) |

If no arguments, test all flows from the latest record, 6 dimensions, base features only.

## The 6 Test Dimensions (Always-On)

Every flow is tested across all 6 dimensions. These are not optional.

| Dim | Name | What It Tests | Example Checks |
|-----|------|---------------|----------------|
| 1 | **Happy Path** | Does the flow work as discovered in the record? | Execute the exact steps from the record; verify expected outcome |
| 2 | **Negative Input** | Bad data, missing fields, wrong types, invalid formats | Empty required fields, strings in number fields, SQL injection strings, XSS payloads, malformed JSON |
| 3 | **Boundary Cases** | Empty values, max length, special characters, zero, negative numbers | Empty string, 1-char string, max-length+1 string, 0, -1, MAX_INT, unicode, emoji, null bytes |
| 4 | **Permission/Auth** | Wrong role, no auth, expired token, other user's data | No auth header, expired JWT, wrong role token, accessing another user's resource (IDOR) |
| 5 | **State Violations** | Skip steps, go backward, duplicate actions, invalid transitions | Submit step 3 before step 1, double-submit a form, go from "shipped" back to "draft" |
| 6 | **Data Integrity** | Is data consistent in DB/state after flow completes? | Check DB records match expected state, no orphaned rows, no stale cache, referential integrity holds |

## Testing Strategy by Flow Type

| Flow Type | Primary Tool | Fallback | How |
|-----------|-------------|----------|-----|
| **UI/Frontend (FF-*)** | Playwright MCP | Generated Playwright spec files | Navigate to URL, interact with elements, assert DOM state |
| **API (API-*)** | Bash (curl/httpie) | Generated test files | Send HTTP requests, check status codes + response bodies |
| **Business Logic (BLF-*)** | Unit test generation | Manual test plan | Import functions, test with various inputs, assert outputs |
| **State Machine (SF-*)** | Unit test generation | Manual test plan | Verify all valid transitions pass, all invalid transitions rejected |
| **Data (DA-*)** | SQL queries via Bash | Generated test files | Check constraints, relationships, triggers, cascades |
| **Integration (INT-*)** | API calls + mocks | Manual test plan | Test service boundaries, mock external dependencies |
| **Composite (CF-*)** | Combined approach | Manual test plan | Chain multiple flow types, verify end-to-end |

## Procedure

### Step 1: Locate Record File

Find the record file to parse.

```bash
# If --record flag provided, use that path directly
# Otherwise, find the latest record file
ls -t *_Business_Flows_Helper_*.md 2>/dev/null | head -1

# Also check common locations
ls -t .healer/*_Business_Flows_Helper_*.md 2>/dev/null | head -1
ls -t docs/*_Business_Flows_Helper_*.md 2>/dev/null | head -1
```

**Error handling:**
- If no record file found → **ERR_NO_RECORD**: "No record file found. Run `/healer:record` first."
- If record file is older than 30 days → **ERR_RECORD_STALE**: "Record is {N} days old. Re-run `/healer:record` for fresh flow discovery."
- If --record path doesn't exist → **ERR_FLOW_NOT_FOUND**: "Record file not found at {path}."

### Step 2: Parse Record File

Read the record file completely. Extract ALL flow IDs with their details.

<HARD-GATE>READ THE ENTIRE RECORD FILE. Do not skim. Every flow ID, every step, every file reference, every decision point must be extracted. Missing a flow means missing test coverage.</HARD-GATE>

For each flow, extract:
- **Flow ID** (e.g., BLF-001, FF-012, API-005, SF-003, CF-008)
- **Flow name** and description
- **Type** (UI/API/Business Logic/State Machine/Data/Integration/Composite)
- **Trigger** (what starts this flow)
- **Steps** (ordered list of actions)
- **Files involved** (source files that implement this flow)
- **Decision points** (branches, conditions, guards)
- **Expected outcomes** (what happens when the flow completes successfully)
- **Error conditions** (documented failure modes)
- **API schemas** (request/response shapes, if API flow)
- **Risk score** (if the record includes risk assessment)

Build a **Flow Registry**:

```
FLOW REGISTRY (from record)
═══════════════════════════════════════════════════
Total flows: {N}
  FF (UI):       {N}
  API:           {N}
  BLF (Logic):   {N}
  SF (State):    {N}
  CF (Composite):{N}
  DA (Data):     {N}
  INT (Integration): {N}

{flow_id}: {name} [{type}]
  Trigger: {trigger}
  Steps: {N} steps
  Files: {file list}
  Risk: {score if available}
  ...
═══════════════════════════════════════════════════
```

If specific flow IDs were requested via arguments, filter to only those. If any requested ID is not in the record → **ERR_FLOW_NOT_FOUND**: "Flow {ID} not found in record file."

### Step 3: Detect Testing Infrastructure

Run the testing infrastructure detection (see Stack Auto-Detection section above).

```bash
# Check for Playwright MCP
# (attempt to list browser-related MCP tools)

# Check for test framework
cat package.json 2>/dev/null | grep -E '"(jest|vitest|mocha|playwright|cypress)"'
cat pyproject.toml 2>/dev/null | grep -E '(pytest|unittest)'
ls Cargo.toml 2>/dev/null && grep -E 'test' Cargo.toml

# Check for running dev server
for port in 3000 5173 8080 4000 8000; do
  curl -s -o /dev/null -w "Port $port: %{http_code}\n" "http://localhost:$port" 2>/dev/null || true
done

# Check for a11y tools
grep -r "axe-core\|pa11y\|@axe-core/playwright" package.json 2>/dev/null

# Check for existing test directories
ls -d tests/ test/ __tests__/ spec/ e2e/ 2>/dev/null
```

Build a **Tool Availability Matrix**:

```
TESTING TOOLS
═══════════════════════════════════════
Playwright MCP:    {available/not available}
Test framework:    {Jest/Vitest/pytest/etc. or none}
Dev server:        {port N running / not running}
Coverage tool:     {c8/istanbul/etc. or none}
A11y tool:         {axe-core/pa11y or none}
Existing tests:    {path to test directory}
═══════════════════════════════════════
```

**Error handling:**
- UI flows but no Playwright MCP → **ERR_NO_PLAYWRIGHT**: "Playwright MCP not available. UI flows will be tested via generated spec files only (--generate-only for UI)."
- API flows but no running server → **ERR_NO_SERVER**: "No running dev server detected. Start the dev server or use `--generate-only`."

### Step 4: Check 10x Flags

Determine which optional features are enabled:

```
10x FEATURE STATUS
═══════════════════════════════════════
--visual:     {enabled/disabled}  Visual regression (Playwright screenshots)
--a11y:       {enabled/disabled}  Accessibility (axe-core)
--security:   {enabled/disabled}  OWASP security testing
--perf:       {enabled/disabled}  Performance profiling
--regression: {enabled/disabled}  Compare against previous run
--ci:         {enabled/disabled}  Generate CI workflow
--auto-heal:  {enabled/disabled}  Auto-fix failures via /healer:fix
--dashboard:  {enabled/disabled}  HTML dashboard generation
--contract:   {enabled/disabled}  API contract validation
═══════════════════════════════════════
```

If `--full` is specified, enable ALL of the above.

### Step 5: Prioritize Flows

Order flows for testing by priority:

**If the record includes risk scores:**
- Test highest-risk flows first

**Otherwise, use type-based priority:**
1. **FF (UI flows)** — user-facing journeys, highest visibility
2. **BLF (Business Logic)** — core correctness
3. **API** — integration surface
4. **SF (State Machines)** — transition correctness
5. **CF (Composite)** — cross-cutting flows
6. **INT (Integration)** — external service boundaries
7. **DA (Data)** — storage-level checks

Within each type, order by: number of steps (more steps = more risk) descending.

**If `--traffic-aware` or `--full` — Traffic-Weighted Priority:**
Before applying the above ordering, scan the project for analytics/logging integration:
1. Search for analytics SDKs: Mixpanel, Amplitude, PostHog, Google Analytics, Segment, Plausible
   `grep -rn "mixpanel\|amplitude\|posthog\|gtag\|analytics\|segment" --include="*.ts" --include="*.tsx" --include="*.js" | head -20`
2. Search for page view / event tracking calls to estimate which flows are most-used
3. Search for server access logs or request logging patterns
4. If analytics found, estimate relative usage frequency per flow
5. Combine with risk score: `Combined Priority = (risk_score × 0.6) + (usage_frequency × 0.4)`
6. Reorder flows by combined priority
7. If no analytics/logging found, fall back to type-based priority and note: "No analytics integration detected. Priority is risk-based only."

If `--api-only`, filter to API/BLF/SF/DA flows only.
If `--ui-only`, filter to FF flows only.

### Step 6: Test Each Flow (THE MAIN LOOP)

For each flow in priority order:

#### 6a. Generate Test Scenarios Across All 6 Dimensions

For this specific flow, generate concrete test scenarios:

**Dimension 1 — Happy Path:**
- Replay the exact steps from the record
- Use valid data matching the expected types
- Assert the documented expected outcome

**Dimension 2 — Negative Input:**
- For each input field in the flow:
  - Empty/null value
  - Wrong type (string where number expected, etc.)
  - Invalid format (bad email, negative price, future date for birthdate)
  - Known injection strings (SQL: `'; DROP TABLE--`, XSS: `<script>alert(1)</script>`)
- Assert: proper error messages, no crashes, no data corruption

**Dimension 3 — Boundary Cases:**
- For each input field:
  - Minimum valid value, maximum valid value
  - One below minimum, one above maximum
  - Empty string, single character, maximum length + 1
  - Zero, negative, MAX_INT, MIN_INT (for numbers)
  - Unicode characters, emoji, RTL text, null bytes
- Assert: graceful handling, correct validation messages

**Dimension 4 — Permission/Auth:**
- Execute the flow with:
  - No authentication (missing auth header/cookie)
  - Expired authentication (expired JWT/session)
  - Wrong role (viewer trying admin actions)
  - Another user's context (IDOR — accessing resource with wrong user's ID)
- Assert: 401/403 responses, no data leakage, no unauthorized state changes

**Dimension 5 — State Violations:**
- Attempt invalid flow sequences:
  - Skip required steps (submit step 3 without completing step 1)
  - Go backward (try to "un-submit" after submission)
  - Duplicate actions (submit the same form twice)
  - Invalid state transitions (move from "completed" to "draft")
- Assert: proper rejection, no partial state corruption

**Dimension 6 — Data Integrity:**
- After happy path completes:
  - Query the database/state to verify records exist
  - Check referential integrity (foreign keys, associations)
  - Verify no orphaned records
  - Check computed fields match expected values
  - Verify timestamps, audit fields
- Assert: data consistency matches expected post-flow state

#### 6b. Execute Tests

**For UI flows (FF-*):**
- Use Playwright MCP if available: navigate to URL, fill forms, click buttons, assert page state
- If no Playwright MCP: generate Playwright spec file at `tests/e2e/flows/{flow_id}.spec.ts`

**For API flows (API-*):**
- Use Bash with curl:
  ```bash
  curl -s -w "\n%{http_code}" -X {METHOD} http://localhost:{port}/{endpoint} \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer {token}" \
    -d '{payload}'
  ```
- Check status codes, response bodies, headers

**For Business Logic flows (BLF-*):**
- Generate unit test file at `tests/unit/flows/{flow_id}.test.{ext}`
- Import the relevant functions
- Test with dimension-specific inputs

**For State Machine flows (SF-*):**
- Generate unit test file testing all transitions
- Valid transitions: verify they succeed
- Invalid transitions: verify they throw/reject

**For Data flows (DA-*):**
- Run SQL queries via Bash to check constraints
- Test INSERT with invalid data, verify rejection
- Test cascading deletes, foreign key constraints

#### 6c. Generate-Only Mode

If `--generate-only`, write test files but do NOT execute them:
- `tests/e2e/flows/{flow_id}.spec.ts` for UI flows
- `tests/api/flows/{flow_id}.test.ts` for API flows
- `tests/unit/flows/{flow_id}.test.ts` for logic/state flows

Each file includes all 6 dimensions as describe blocks.

#### 6d. Capture Per-Dimension Results

For each dimension, record:
- **PASS**: Test executed and assertions succeeded
- **FAIL**: Test executed and assertions failed (with details)
- **SKIP**: Test could not be executed (tool not available) — with reason
- **ERROR**: Test execution itself crashed (with error message)

#### 6e. Visual Regression (if --visual)

For UI flows only:
- Capture screenshots at key states (before action, after action, final state)
- If baselines exist in `tests/visual/baselines/`, compare using Playwright `toHaveScreenshot()`
- If no baselines, save current screenshots AS baselines
- Report: pixel diff percentage, threshold comparison

#### 6f. Accessibility Testing (if --a11y)

For UI flows only:
- Run axe-core accessibility audit on each page state
- Score each page (0-100 based on violations)
- Classify violations by WCAG level (A, AA, AAA)
- Flag auto-fixable issues vs manual-fix-required

#### 6g. Security Testing (if --security)

For each flow, run OWASP-based checks:
- **Injection**: SQL injection, NoSQL injection, command injection in inputs
- **XSS**: Reflected and stored XSS via input fields
- **Auth bypass**: Direct object reference without auth, JWT manipulation
- **Mass assignment**: Send extra fields in API requests, check if they're accepted
- **IDOR**: Access resources with another user's ID
- **Rate limiting**: Rapid-fire same request, check for throttling
- **JWT validation**: Tampered tokens, algorithm confusion, missing signature

#### 6h. Performance Profiling (if --perf)

For each flow:
- Time each step individually (start-to-response)
- Measure total flow duration
- Compare against thresholds (if defined in record or NFRs):
  - API response < 200ms
  - Page load < 3s
  - Flow completion < 10s
- Identify bottleneck step (slowest step in the flow)
- Track memory delta (if measurable)
- Flag potential N+1 query patterns (multiple sequential similar requests)

#### 6i. Contract Testing (if --contract and flow is API)

For API flows:
- Compare actual response shape against schema from record
- Flag: extra fields (not in schema), missing fields (in schema but not in response), wrong types
- Validate status codes match documented codes
- Check header expectations (Content-Type, cache headers, CORS)

#### 6j. Auto-Heal (if --auto-heal and failure detected)

When a test fails:
1. Dispatch `/healer:fix` with the specific failure details
2. Wait for fix to complete
3. Re-test the failed dimension
4. If still failing: retry fix (max 3 attempts total)
5. After 3 failed attempts: mark as **STUCK** and move on

<HARD-GATE>AUTO-HEAL MAX 3 ATTEMPTS PER FLOW. Do not loop indefinitely. After 3 fix attempts, mark the flow as STUCK with details of what was tried.</HARD-GATE>

#### 6k. Trace Capture (if --trace and Playwright used)

Enable Playwright trace recording for the flow test:
```typescript
test.use({ trace: 'on' }); // Captures DOM snapshots, network, console, screenshots
```
After each flow test, save the trace zip:
`tests/traces/{flow_id}.trace.zip`
Report: "View trace: `npx playwright show-trace tests/traces/{flow_id}.trace.zip`"

#### 6l. Flakiness Detection (if --flake-check)

After a flow test passes, re-run it 2 more times (3 total) to detect flakiness:
- If all 3 runs pass: mark as **Stable**
- If any run differs: mark as **Flaky**, note which dimension is inconsistent
- For flaky tests in generated files: add `test.describe.configure({ retries: 2 })` and a `// FLAKY:` comment
- Report flakiness rate per flow in the summary

#### 6m. Log Result

Record the complete result for this flow before moving to the next.

### Step 7: Generate Test Files

After testing all flows, write repeatable test files:

**E2E tests (UI flows):**
- Location: `tests/e2e/flows/{flow_id}.spec.{ext}`
- Format: Playwright test syntax (or detected E2E framework)
- Content: all 6 dimensions as describe/context blocks

**API tests:**
- Location: `tests/api/flows/{flow_id}.test.{ext}`
- Format: detected test framework (Jest/Vitest/pytest/etc.)
- Content: HTTP request tests for all 6 dimensions

**Unit tests (logic/state flows):**
- Location: `tests/unit/flows/{flow_id}.test.{ext}`
- Format: detected test framework
- Content: function-level tests for all 6 dimensions

Each test file is self-contained and runnable independently.

**Self-Healing Locators (always-on for generated tests):**
All generated test files MUST use resilient Playwright locator strategies in this priority order:
1. `page.getByRole()` — most resilient, semantic
2. `page.getByText()` — human-readable, survives restructuring
3. `page.getByTestId()` — stable if data-testid attributes exist
4. `page.getByLabel()` — for form elements
5. `page.locator('css')` — last resort, most brittle

NEVER generate tests with raw CSS selectors like `#submit-btn` or `.form-input` as the primary locator.
Include a comment at the top of each generated file:
```typescript
// Locator strategy: role-first, text-fallback, testid-last
// Generated by /healer:indulge — resilient to UI restructuring
```

**Network Mock Fixtures (if --fixtures or --full):**
For each E2E test file, also generate a companion fixture file:
- Location: `tests/e2e/flows/{flow_id}.fixtures.ts`
- Content: mock API response data for every network call the flow makes
- Usage: tests can import fixtures and use `page.route()` to intercept network calls
- Format:
```typescript
// tests/e2e/flows/blf-001-checkout.fixtures.ts
export const mockResponses = {
  'POST /api/orders': { status: 201, body: { id: 'mock-uuid', status: 'draft' } },
  'GET /api/products': { status: 200, body: [{ id: 1, name: 'Widget', price: 9.99 }] },
};
```
This makes E2E tests deterministic (no live API dependency) and fast (no network latency).

**Component Tests (if --component or --full):**
For each CP-NNN (component pattern) discovered by record, generate a component-level test:
- Location: `tests/components/{cp_id}.spec.{ext}`
- Format: Playwright experimental component testing (`@playwright/experimental-ct-react` or equivalent)
- Test each component in isolation: default render, variant renders, state changes, interaction handlers
- Skip if the project doesn't use React/Vue/Svelte (frameworks supported by Playwright CT)
- Note: Component tests mount ONLY the component, not the full app — faster and more isolated

**Test Maintenance Score (always-on in report):**
For each generated test file, calculate a maintenance burden score:
| Factor | Weight | Measurement |
|--------|--------|------------|
| Assertion count | 20% | More assertions = more breakage surface |
| State setup complexity | 25% | DB seeds, auth tokens, multi-step preconditions |
| External dependencies | 25% | API calls, file uploads, third-party services |
| Locator fragility | 15% | CSS selectors vs role-based locators |
| Flow length | 15% | More steps = more maintenance |

Score: LOW (0-30), MEDIUM (31-60), HIGH (61-100)
Include in the report: "Prioritize stabilizing HIGH-maintenance tests first."

### Step 8: Regression Analysis (if --regression)

Load previous indulge results:

```bash
# Find previous indulge report
ls -t .healer/indulge_results_*.json 2>/dev/null | head -1
```

Compare current results against previous:
- **Regressions**: flows that were PASS, now FAIL
- **Improvements**: flows that were FAIL, now PASS
- **Unchanged**: same result as before

For each regression, attempt to link to likely causing commit:

```bash
# Find commits since last indulge run
git log --oneline --since="{last_run_timestamp}" -- {flow_files}
```

### Step 9: Generate CI Workflow (if --ci)

Write a CI workflow file for automated flow testing on pull requests.

**For GitHub Actions** (default):
Write `.github/workflows/flow-tests.yml`:
- Trigger: on pull_request to main
- Steps: install dependencies, start dev server, run generated test files
- Artifacts: upload test results and screenshots on failure
- Matrix: test each flow type in parallel (e2e, api, unit)

**For other CI** (if detected):
- GitLab CI: `.gitlab-ci.yml` flow-tests section
- CircleCI: `.circleci/config.yml` flow-tests job

### Step 10: Generate Dashboard (if --dashboard)

Write a self-contained HTML file: `{AppName}_Indulge_Dashboard_{MMDDYYYY}.html`

Contents:
- Chart.js loaded from CDN
- Overall pass rate (donut chart)
- Per-dimension breakdown (radar chart)
- Per-flow details (expandable table)
- Screenshots (if --visual, embedded as base64)
- Performance timings (if --perf, bar chart)
- Security findings (if --security, severity-colored table)
- Accessibility scores (if --a11y, gauge charts)
- Regression diff (if --regression, before/after comparison)
- All data embedded in the HTML — no external dependencies, viewable in any browser

## Report Template

```
HEALER INDULGE REPORT
═══════════════════════════════════════════════════
Record file: {path}
Record date: {date}
Flows tested: {N}/{total}
Test scenarios executed: {N total across all flows and dimensions}
Testing tools: {Playwright MCP, curl, Jest, etc.}
10x features: {list of enabled features, or "base only"}

FLOW-BY-FLOW RESULTS
─────────────────────────────────────────────────
{For each flow:}

{ID}: {name} [{type}]
  [1] Happy path      — {PASS/FAIL/SKIP} — {details}
  [2] Negative input   — {PASS/FAIL/SKIP} — {N}/{M} invalid inputs rejected correctly
  [3] Boundary cases   — {PASS/FAIL/SKIP} — {N}/{M} boundary conditions handled
  [4] Permissions      — {PASS/FAIL/SKIP} — {details}
  [5] State violations — {PASS/FAIL/SKIP} — {details}
  [6] Data integrity   — {PASS/FAIL/SKIP} — {details}
  {If --visual}:   Visual:        {MATCH/DIFF {N}% pixel diff/NEW BASELINE}
  {If --a11y}:     Accessibility: {score}/100 ({N} violations: {N} critical, {N} serious, {N} moderate)
  {If --security}: Security:      {N} findings ({N} high, {N} medium, {N} low)
  {If --perf}:     Performance:   {total}ms (bottleneck: {step} at {N}ms)
  {If --contract}: Contract:      {MATCH/DRIFT — extra: {N} fields, missing: {N} fields, wrong type: {N} fields}

DIMENSION SUMMARY
─────────────────────────────────────────────────
  [1] Happy path:       {N}% passing ({passed}/{total})
  [2] Negative input:   {N}% ({passed}/{total})
  [3] Boundary cases:   {N}% ({passed}/{total})
  [4] Permissions:      {N}% ({passed}/{total})
  [5] State violations: {N}% ({passed}/{total})
  [6] Data integrity:   {N}% ({passed}/{total})
  ────────────────────
  Overall:              {N}% ({total_passed}/{total_tests})

{If --regression}:
REGRESSION ANALYSIS
─────────────────────────────────────────────────
  Previous run: {date}
  Regressions: {N} flows (were passing, now failing)
  Improvements: {N} flows (were failing, now passing)
  Unchanged:   {N} flows

  Regressions:
    - {flow_id}: {dim} — was PASS, now FAIL — likely commit: {sha} ({message})
    - ...

  Improvements:
    - {flow_id}: {dim} — was FAIL, now PASS
    - ...

{If --auto-heal}:
AUTO-HEAL RESULTS
─────────────────────────────────────────────────
  Auto-healed:          {N} flows (fix applied, re-test passed)
  Stuck (3x failed):    {N} flows (fix attempted 3 times, still failing)

  Healed:
    - {flow_id}: {dim} — fixed on attempt {N}
    - ...

  Stuck:
    - {flow_id}: {dim} — attempt 1: {what was tried} — attempt 2: {what was tried} — attempt 3: {what was tried}
    - ...

{If --security}:
SECURITY SUMMARY
─────────────────────────────────────────────────
  Total findings: {N}
  High: {N}    Medium: {N}    Low: {N}

  High findings:
    - {flow_id}: {finding type} — {description}
    - ...

{If --a11y}:
ACCESSIBILITY SUMMARY
─────────────────────────────────────────────────
  Average score: {N}/100
  WCAG A violations: {N}
  WCAG AA violations: {N}
  Auto-fixable: {N}

{If --traffic-aware}:
TRAFFIC-WEIGHTED PRIORITY
─────────────────────────────────────────────────
  Analytics detected: {Y/N — which platform}
  | Flow | Risk Score | Est. Usage | Combined Priority |
  |------|-----------|------------|-------------------|
  | {flow_id} | {N}/100 | {~N/day} | P0/P1/P2/P3 |

{If --flake-check}:
FLAKINESS REPORT
─────────────────────────────────────────────────
  Tests run: {N} × 3 repetitions = {N} executions
  Stable: {N} flows (3/3 consistent)
  Flaky:  {N} flows (inconsistent results)
    - {flow_id}: {dim} — passed {N}/3 runs (timing issue / race condition / etc.)
  Flaky tests have been marked with retry(2) in generated files.

TEST MAINTENANCE FORECAST
─────────────────────────────────────────────────
  | Test File | Assertions | Setup | Ext. Deps | Maint. Score |
  |-----------|------------|-------|-----------|--------------|
  | {file} | {N} | {Simple/Medium/Complex} | {N} | {LOW/MED/HIGH} |
  Recommendation: Stabilize HIGH-maintenance tests first.

GENERATED ARTIFACTS
─────────────────────────────────────────────────
  Test files: {N} files generated
    - tests/e2e/flows/{file1}
    - tests/api/flows/{file2}
    - tests/unit/flows/{file3}
    - ...
  {If --fixtures}:   Fixtures: tests/e2e/flows/{flow_id}.fixtures.ts ({N} files)
  {If --component}:  Component tests: tests/components/{cp_id}.spec.ts ({N} files)
  {If --trace}:      Traces: tests/traces/{flow_id}.trace.zip ({N} files)
  {If --ci}:         CI workflow: .github/workflows/flow-tests.yml
  {If --dashboard}:  Dashboard: {AppName}_Indulge_Dashboard_{MMDDYYYY}.html
  {If --visual}:     Baselines: tests/visual/baselines/ ({N} screenshots)
  {If --regression}: Results saved: .healer/indulge_results_{YYYYMMDD}.json

Next steps:
  - /healer:fix      — fix failing flows
  - /healer:test     — write additional tests beyond flow coverage
  - /healer:push     — commit generated test files
  - /healer:record --diff — see what changed after fixes
  - /healer:indulge --regression — track improvements over time
═══════════════════════════════════════════════════
```

**ENFORCEMENT: Every field in this report MUST be filled with actual data from test execution. No placeholders. No estimates. No "probably passes."**

## Error Catalog

| Error | Condition | Message | Recovery |
|-------|-----------|---------|----------|
| ERR_NO_RECORD | No record file found in project | "No record file found. Run `/healer:record` first." | Run `/healer:record` |
| ERR_RECORD_STALE | Record file older than 30 days | "Record is {N} days old. Re-run `/healer:record` for fresh flow discovery." | Run `/healer:record` |
| ERR_NO_PLAYWRIGHT | UI flows present but no Playwright MCP available | "Playwright MCP not available. UI flows tested via generated spec files only." | Install Playwright MCP, or use `--api-only`, or use `--generate-only` |
| ERR_NO_SERVER | API flows present but no running dev server | "No running dev server detected on ports 3000/5173/8080/4000/8000. Start the dev server or use `--generate-only`." | Start dev server, or use `--generate-only` |
| ERR_FLOW_NOT_FOUND | Requested flow ID not present in record file | "Flow {ID} not found in record file. Available flows: {list}" | Check flow ID against record |
| ERR_NO_PREVIOUS_RUN | `--regression` flag used but no previous indulge results found | "No previous indulge results found for regression comparison. This run will establish the baseline." | First run becomes baseline |
| ERR_AUTO_HEAL_STUCK | `--auto-heal` exhausted 3 attempts for a flow | "Auto-heal stuck on {flow_id} after 3 attempts. Manual intervention required." | Use `/healer:fix` manually with more context |

## State Update

After completion, write to `.healer/state.json`:

```json
{
  "last_command": "indulge",
  "status": "completed|partial|failed",
  "suggested_next": "fix|test|push|report",
  "timestamp": "ISO-8601",
  "record_file": "{path}",
  "flows_tested": 0,
  "flows_passed": 0,
  "flows_failed": 0,
  "overall_score": 0,
  "dimensions": {
    "happy_path": 0,
    "negative_input": 0,
    "boundary_cases": 0,
    "permission_auth": 0,
    "state_violations": 0,
    "data_integrity": 0
  },
  "auto_healed": 0,
  "stuck": 0,
  "flags_used": [],
  "artifacts_generated": []
}
```

Also save detailed results for regression tracking:

```bash
# Save results for future --regression comparisons
# Write to .healer/indulge_results_{YYYYMMDD}.json
```

## Safety

- **Indulge NEVER modifies source code** — only creates test files (in `tests/`) and report files (in project root)
- **Auto-heal dispatches `/healer:fix`** which MAY modify source code — but ONLY when `--auto-heal` is explicitly requested by the user
- **Generated test files go in `tests/` subdirectories only** — never in `src/` or application code directories
- **Dashboard HTML goes in project root** — self-contained, no external dependencies at runtime
- **No destructive operations** — indulge does not delete files, drop tables, or reset state
- **Test execution uses read-only assertions** — tests verify state but do not permanently alter production data

## Red Flags — STOP and Reassess

```
RED FLAGS:

  STOP if you're testing flows that aren't in the record file
  → Indulge is record-driven. Every flow comes from the record. If you found something
    new, note it for the next /healer:record run, but don't test it now.

  STOP if you're marking a dimension PASS without actually executing the test
  → "It should pass" is not evidence. Run the test. Read the output. Then classify.

  STOP if you're skipping dimensions because "they don't apply to this flow type"
  → All 6 dimensions apply to every flow. A business logic flow still has permission
    checks. An API flow still has boundary cases. Test them all.

  STOP if --auto-heal has looped more than 3 times on the same flow
  → Mark it STUCK. Move on. Report it. Do not keep trying.

  STOP if you're about to edit a source file (not a test file)
  → Indulge creates tests and reports. It does NOT fix source code.
    Only --auto-heal (via /healer:fix dispatch) modifies source.

  STOP if the test execution is crashing (not failing, CRASHING)
  → A crash means the test infrastructure is broken, not the flow.
    Fix the test setup before continuing.

  STOP if you're generating tests without understanding the flow's steps
  → Re-read the flow from the record. Understand the trigger, steps, and expected
    outcome. Only then write meaningful test scenarios.

  STOP if 80%+ of flows are SKIP due to tool unavailability
  → The test infrastructure is insufficient. Report the tool gaps prominently.
    Suggest --generate-only and manual execution.

  STOP if you're testing against production URLs or external services
  → Test against localhost/dev only. Never hit production. Never hit third-party
    services without mocks.
```

## Anti-Rationalization

| Rationalization | Reality | Correction |
|----------------|---------|------------|
| "This flow is simple, it'll pass all dimensions" | Simple flows fail on boundary cases and permissions more often than complex ones. | Test it. All 6 dimensions. Every flow. |
| "Negative input testing is overkill for this" | Negative input testing catches the bugs that reach production. It's never overkill. | Generate the negative inputs. Run them. Report results. |
| "The permission dimension doesn't apply — this is a public endpoint" | Public endpoints still need rate limiting, input validation, and abuse prevention checks. | Test with no auth, wrong auth, and rapid-fire. |
| "I'll just generate the test files and mark everything PASS" | Generated files without execution are --generate-only mode. Don't fake results. | Execute the tests or use --generate-only honestly. |
| "The record is probably accurate enough" | Records can be stale. But indulge doesn't re-discover — it tests what the record says. | Trust the record for flow definitions. Test for correctness. |
| "Boundary cases are the same for every field" | A name field, a price field, and a date field all have different boundaries. | Generate field-specific boundary values. Not generic ones. |
| "Auto-heal will fix everything" | Auto-heal has a 3-attempt limit for good reason. Some fixes need human judgment. | Report STUCK flows honestly. Don't hide them. |
| "The dashboard is just nice-to-have" | The dashboard is the artifact the user shows their team. Make it accurate and complete. | Fill every chart with real data. No placeholder values. |
| "State violation testing is only for state machines" | Every flow has implicit state. A checkout flow has cart→payment→confirmation. Test violations. | Identify the implicit state transitions in every flow. Test them. |
| "I'll skip data integrity — it's hard to verify" | Data integrity is where the most dangerous bugs hide. Silent data corruption. | Query the DB/state after the flow. Verify every expected record. |
| "This API response looks right" | "Looks right" is not contract compliance. Compare field-by-field against the schema. | Use --contract or manually compare every field, type, and status code. |
| "I don't need to save results for regression" | Without saved results, --regression is impossible next time. Future you will be frustrated. | Always save results to .healer/indulge_results_{date}.json. |

## Rules

1. **Record-driven, always** — every tested flow must come from a record file
2. **6 dimensions, no shortcuts** — every flow gets all 6 dimensions unless tool unavailability forces a SKIP
3. **Execute, don't estimate** — run every test; "probably passes" is not a result
4. **Generate repeatable files** — test files must be independently runnable after indulge completes
5. **Never modify source** — indulge creates tests and reports, not source code changes (except via --auto-heal dispatch)
6. **3-attempt auto-heal limit** — STUCK after 3 tries, no exceptions
7. **Save results for regression** — always write results JSON for future --regression comparisons
8. **Report honestly** — if a dimension is at 20%, report 20%. Do not inflate scores
9. **Field-specific scenarios** — boundary values and negative inputs must be tailored to each field's type and constraints
10. **Test localhost only** — never test against production URLs or third-party services without mocks
11. **Update state** — always write to `.healer/state.json` when done
12. **Respect --generate-only** — when set, write files but do NOT execute any tests
13. **Parallel when possible** — use parallel agents for testing independent flows
14. **Dashboard accuracy** — if --dashboard, every chart value must come from actual test results
15. **Dispatch, don't duplicate** — use /healer:fix for auto-heal, don't reinvent fix logic inside indulge
