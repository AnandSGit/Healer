# Technical Specification: /healer:record + /healer:indulge

## Metadata
- **Author**: Healer (ideate flow)
- **Date**: 2026-04-11
- **Status**: Draft
- **Stack**: Healer Plugin (Claude Code Markdown Commands)
- **Version**: v2.0 (10x expansion)

### Artifact Lineage
| Phase | Artifact | Key Decisions Carried Forward |
|-------|----------|-------------------------------|
| Validate | GO — 2026-04-11 | Strong demand signal, fills reverse-engineering gap |
| Brainstorm | 2026-04-11 | 8 discovery layers, 6 test dimensions, single-file output |
| Research | 2026-04-11 | Multi-source extraction, Playwright MCP, structured IDs |
| Design | 2026-04-11 | Full-app scope including UI design reverse engineering |
| Strategy | 2026-04-11 | 8.4/10 GO, build record first, Playwright optional |

---

## 1. Overview

Two new healer commands that create a bidirectional requirements traceability chain:

- **`/healer:record`** — Reverse-engineers the entire app (frontend, backend, DB, design) into a single comprehensive requirements + flow document.
- **`/healer:indulge`** — Reads the record file and systematically tests every discovered flow using Playwright, API testing, or appropriate tooling.

Together: **Code → Requirements → Proof** (the reverse direction of the existing spec → implement → verify chain).

## 2. Background

### Problem
Claude Code loses context between sessions. Users must re-explain their app's requirements every time. Existing healer commands (`verify`, `catchup`, `conform`) require pre-existing spec/design artifacts. Many projects have no such artifacts.

### Solution
`record` creates the missing artifact BY READING THE CODE ITSELF. `indulge` proves the artifact is accurate by testing every flow it documents.

## 3. Goals and Non-Goals

### Goals
- G1: Extract all discoverable requirements from code, docs, DB, tests, and config
- G2: Map all business logic, control, state, data, and functional flows
- G3: Reverse-engineer UI design patterns (colors, fonts, spacing, components)
- G4: Produce a single, structured, ID-tagged markdown file per recording
- G5: Enable systematic flow-by-flow testing from the record
- G6: Support whole-app AND scoped recording/testing
- G7: Generate repeatable test files (not just live execution)
- G8: Work for ANY stack (not just web apps)

- G9: (10x) Generate Mermaid flow diagrams for every discovered flow
- G10: (10x) Risk-score every flow by complexity, change frequency, test coverage, blast radius, security surface
- G11: (10x) Git timeline per flow — creation date, last modified, contributors, change velocity
- G12: (10x) Impact analysis — "if I change file X, which flows break?"
- G13: (10x) Dead code and orphan file detection
- G14: (10x) Record diff — compare current record against previous run
- G15: (10x) Auto-generate CLAUDE.md from record for future session context
- G16: (10x) Data lineage tracking per entity (input → transform → storage → output)
- G17: (10x) Security surface mapping (input surfaces, auth boundaries, data exposure)
- G18: (10x) Complexity heatmap (files ranked by risk)
- G19: (10x) Visual regression testing with Playwright screenshots
- G20: (10x) Accessibility testing (axe-core) per UI flow
- G21: (10x) Security testing (OWASP-based) per flow
- G22: (10x) Performance profiling per flow (timing, memory, bottleneck detection)
- G23: (10x) Regression mode — compare indulge results across runs
- G24: (10x) CI workflow generation for automated flow testing
- G25: (10x) Auto-heal — dispatch /healer:fix on failing flows, then re-test
- G26: (10x) HTML dashboard with interactive charts and flow-by-flow results
- G27: (10x) API contract validation per API flow
- G28: (10x) OpenAPI spec generation from discovered API surface

### Non-Goals
- NG1: Real-time / watch-mode updating of the record (needs file watcher hook)
- NG2: Running Playwright in headless/CI mode (Playwright MCP limitation — but --ci generates workflow files that CAN run headless)
- NG3: Mutation testing (too complex for v1, may add as future flag)
- NG4: Chaos engineering / dependency failure injection (needs infrastructure control)
- NG5: Modifying any source code (record is read-only; indulge only creates test files + dashboard)

---

## 4. Functional Requirements

### FR-1: Stack Auto-Detection
Record and indulge must detect the project's stack using the standard Stack Auto-Detection Protocol from `_enforcement.md`.

**Acceptance Criteria:**
```gherkin
Scenario: Detect Node.js + Next.js project
  Given a project with package.json containing "next" dependency
  When /healer:record is invoked
  Then the stack is detected as "TypeScript + Next.js"
  And the output file includes the correct stack profile

Scenario: Detect Python + Django project
  Given a project with pyproject.toml containing "django" dependency
  When /healer:record is invoked
  Then the stack is detected as "Python + Django"
```

### FR-2: 8-Layer Discovery (Record)
Record must extract information across all 8 discovery layers: App Identity, Data Architecture, API Surface, Business Logic, State & Control Flow, UI Design System, Integration Points, Testing & Quality.

**Acceptance Criteria:**
```gherkin
Scenario: All 8 layers populated
  Given a full-stack web application
  When /healer:record is invoked with no arguments
  Then the output file contains sections for all 8 layers
  And each section contains at least one discovered item
  And each item has a unique ID (DA-001, API-001, BLF-001, etc.)

Scenario: Backend-only scoping
  Given a full-stack web application
  When /healer:record --backend-only is invoked
  Then layers 2 (Data), 3 (API), 4 (Business Logic), 5 (State), 7 (Integration) are populated
  And layers 6 (UI Design) and frontend portions are skipped
```

### FR-3: UI Design Reverse Engineering (Record)
Record must extract the visual design language: colors, typography, spacing, component patterns, layouts, animations, responsive breakpoints, and icon systems.

**Acceptance Criteria:**
```gherkin
Scenario: Color extraction from Tailwind
  Given a Next.js project using Tailwind CSS with custom colors in tailwind.config
  When /healer:record is invoked
  Then section 7.1 lists all custom color tokens with hex values
  And maps each token to the files where it's used

Scenario: Component pattern discovery
  Given a React project with reusable components
  When /healer:record is invoked
  Then section 7.4 lists each unique component pattern
  And includes variant states (default, hover, active, disabled)
  And includes file locations and usage counts

Scenario: Typography extraction
  Given a project with font-family declarations
  When /healer:record is invoked
  Then section 7.2 lists all font families, sizes, weights
  And maps each to its role (heading, body, label, etc.)
```

### FR-4: Flow ID System
Every discovered flow must have a unique, stable ID following a prefix convention.

**ID Conventions:**
| Prefix | Type | Example |
|--------|------|---------|
| DA-NNN | Data Architecture | DA-001, DA-002 |
| API-NNN | API Endpoint | API-001, API-002 |
| BLF-NNN | Business Logic Flow | BLF-001, BLF-002 |
| CF-NNN | Control Flow | CF-001, CF-002 |
| SF-NNN | State Flow | SF-001, SF-002 |
| CP-NNN | Component Pattern | CP-001, CP-002 |
| INT-NNN | Integration Point | INT-001, INT-002 |
| FF-NNN | Functional Flow (User Journey) | FF-001, FF-002 |

**Acceptance Criteria:**
```gherkin
Scenario: IDs are unique and sequential
  Given a project with 5 business logic flows
  When /healer:record is invoked
  Then IDs BLF-001 through BLF-005 are assigned
  And no duplicates exist across all ID prefixes
```

### FR-5: Single File Output (Record)
Output must be a single markdown file named `{AppName}_Business_Flows_Helper_{MMDDYYYY}.md`.

**Acceptance Criteria:**
```gherkin
Scenario: Correct filename format
  Given a project named "HearthHut" 
  When /healer:record is invoked on 2026-04-11
  Then the output file is named "HearthHut_Business_Flows_Helper_04112026.md"

Scenario: App name detection
  Given a project with name "my-app" in package.json
  When /healer:record is invoked
  Then the output file uses "my-app" as the AppName portion
```

### FR-6: Cross-Reference Matrix (Record)
The output must include a flow → file matrix and a file → flow matrix.

**Acceptance Criteria:**
```gherkin
Scenario: Every flow has file references
  Given a completed record file
  When the cross-reference matrix is examined
  Then every flow ID maps to at least one file
  And every source file appears in at least one flow (or in the "uncovered" list)
```

### FR-7: Record File Parsing (Indulge)
Indulge must parse the record file and extract all flow IDs with their details.

**Acceptance Criteria:**
```gherkin
Scenario: Parse all flow types
  Given a record file with BLF, CF, SF, and FF flows
  When /healer:indulge is invoked
  Then all flow IDs are extracted and listed
  And each flow's details (trigger, steps, files) are available for test generation
```

### FR-8: 6-Dimension Testing (Indulge)
Each flow must be tested across 6 dimensions: happy path, negative input, boundary cases, permission/auth, state violations, data integrity.

**Acceptance Criteria:**
```gherkin
Scenario: API flow tested across all 6 dimensions
  Given an API flow (API-001: POST /api/orders)
  When /healer:indulge tests this flow
  Then happy path: valid order creation succeeds
  And negative: missing required fields return 400
  And boundary: empty/max-length values are handled
  And permission: unauthenticated request returns 401
  And state: duplicate creation is handled
  And data integrity: order exists in DB after creation

Scenario: UI flow tested with Playwright
  Given a UI functional flow (FF-001: User Registration)
  And Playwright MCP is available
  When /healer:indulge tests this flow
  Then happy path: registration succeeds with valid data
  And negative: form rejects invalid email format
  And boundary: handles very long names
  And permission: already-logged-in users are redirected
```

### FR-9: Testing Tool Detection (Indulge)
Indulge must auto-detect available testing tools and choose appropriately.

**Acceptance Criteria:**
```gherkin
Scenario: Playwright MCP available
  Given Playwright MCP server is configured
  When /healer:indulge encounters a UI flow
  Then it uses Playwright MCP tools for live browser testing
  And generates Playwright test files with --codegen

Scenario: No Playwright, API flows exist
  Given no Playwright MCP server
  And API flows exist in the record
  When /healer:indulge is invoked
  Then it uses Bash (curl/fetch) for API testing
  And generates API test files for the detected test framework

Scenario: No testing tools available
  Given no Playwright MCP and no test framework
  When /healer:indulge is invoked
  Then it generates test files in a standard framework
  And reports "test files generated — run them manually"
```

### FR-10: Test File Generation (Indulge)
Indulge must generate repeatable test files, not just live execution results.

**Acceptance Criteria:**
```gherkin
Scenario: E2E test files generated
  Given Playwright is the detected E2E framework
  When /healer:indulge completes testing
  Then test files are created in tests/e2e/ directory
  And each file is named after the flow ID (e.g., blf-001-checkout.spec.ts)
  And files are valid Playwright test syntax
  And files can be run independently

Scenario: API test files generated
  Given Jest is the detected test framework
  When /healer:indulge completes API flow testing
  Then test files are created in tests/api/ directory
  And files use the project's existing test utilities
```

### FR-11: (10x) Mermaid Flow Diagrams (Record)
Every discovered flow must include an inline Mermaid diagram: flowchart for business/control/data flows, stateDiagram for state machines, sequence diagram for API chains.

**Acceptance Criteria:**
```gherkin
Scenario: Business logic flow has Mermaid diagram
  Given a checkout flow with 4 decision points
  When /healer:record is invoked
  Then BLF-001 includes a Mermaid flowchart TD diagram
  And every decision point appears as a diamond node
  And both success and failure paths are shown

Scenario: State machine has state diagram
  Given an order entity with 5 states and 6 transitions
  When /healer:record is invoked
  Then SF-001 includes a Mermaid stateDiagram-v2
  And all states, transitions, guards, and initial/terminal states are shown
```

### FR-12: (10x) Risk Scoring (Record --risk or --full)
Every flow gets a 0-100 risk score based on 5 weighted factors: complexity (25%), change frequency (25%), test coverage (20%), blast radius (15%), security surface (15%).

**Acceptance Criteria:**
```gherkin
Scenario: Risk scores calculated from actual metrics
  Given a project with git history and test files
  When /healer:record --risk is invoked
  Then every flow has a risk score 0-100
  And the score breakdown shows all 5 factors with actual values
  And scores are derived from git log, wc -l, grep, and test file analysis

Scenario: High-risk flows flagged prominently
  Given flows with risk scores above 70
  When the record file is generated
  Then high-risk flows are marked with a warning indicator
  And the executive summary lists the top 5 highest-risk flows
```

### FR-13: (10x) Git Timeline (Record --timeline or --full)
Every flow includes git history: creation date, last modified, contributors, change velocity, test lag.

**Acceptance Criteria:**
```gherkin
Scenario: Timeline from git history
  Given a flow involving 3 files with git history
  When /healer:record --timeline is invoked
  Then the flow shows earliest commit date (created)
  And latest commit date (last modified)
  And contributor list with commit counts from git shortlog
  And change velocity (commits per week, last 30 days)
  And test lag (days since last test file change vs code change)
```

### FR-14: (10x) Impact Analysis (Record --impact <file>)
Given a file path, show all flows that would be affected by changes to that file, both directly and transitively.

**Acceptance Criteria:**
```gherkin
Scenario: Direct and transitive impact
  Given a file src/services/payment.ts used in 3 flows
  And those 3 flows are dependencies of 2 user journeys
  When /healer:record --impact src/services/payment.ts is invoked
  Then the output lists 3 directly affected flows
  And 2 transitively affected flows
  And all files in the blast radius
  And a risk assessment for making changes
```

### FR-15: (10x) Dead Code Detection (Record)
Identify code that exists but is unreachable: unexported functions, unregistered routes, unmounted components, abandoned features.

**Acceptance Criteria:**
```gherkin
Scenario: Dead code identified
  Given a function exported but never imported elsewhere
  When /healer:record is invoked
  Then the dead code section lists the function with file:line
  And categorizes it as "exported but never imported"
  And recommends deletion or review
```

### FR-16: (10x) Record Diff (Record --diff)
Compare current record against the most recent previous record file and show what changed.

**Acceptance Criteria:**
```gherkin
Scenario: Diff shows added, removed, and changed flows
  Given a previous record file exists in the project
  When /healer:record --diff is invoked
  Then the output shows flows ADDED since last record
  And flows REMOVED since last record
  And flows CHANGED (with specific deltas)
  And a summary with counts and net complexity change
```

### FR-17: (10x) CLAUDE.md Generation (Record --claude-md)
Generate a CLAUDE.md file from the record that provides future Claude sessions with full app context.

**Acceptance Criteria:**
```gherkin
Scenario: CLAUDE.md generated with app context
  Given a completed record
  When /healer:record --claude-md is invoked
  Then a CLAUDE.md file is created in the project root
  And it includes: stack profile, architecture summary, top-risk flows,
    data model summary, API surface, design system summary, test commands
  And it is under 500 lines (condensed from the full record)
```

### FR-18: (10x) Data Lineage (Record)
Track data entities from input through validation, transformation, storage, and output.

**Acceptance Criteria:**
```gherkin
Scenario: Full data lineage for user entity
  Given a registration flow that creates a user
  When /healer:record is invoked
  Then a data lineage section shows: form input fields → validation rules →
    transforms (password hashing, UUID generation) → storage (tables, columns) →
    output (JWT, email notification)
  And PII exposure points are flagged
```

### FR-19: (10x) Security Surface Mapping (Record)
Map all input surfaces, auth boundaries, data exposure points, and missing protections.

### FR-20: (10x) Complexity Heatmap (Record)
Rank all files by complexity metrics (cyclomatic complexity, nesting depth, function count, line count) with color-coded risk indicators.

### FR-21: (10x) Visual Regression Testing (Indulge --visual)
For UI flows, capture screenshots at key states using Playwright and compare against baselines.

**Acceptance Criteria:**
```gherkin
Scenario: Visual regression detected
  Given a UI flow with existing baseline screenshots
  When /healer:indulge --visual is invoked
  Then screenshots are captured at each key flow state
  And compared against baselines using pixel diff
  And differences beyond threshold are flagged with diff images
```

### FR-22: (10x) Accessibility Testing (Indulge --a11y)
For UI flows, run axe-core accessibility audit and report violations per WCAG level.

### FR-23: (10x) Security Testing (Indulge --security)
Per-flow security testing based on OWASP Top 10: injection, XSS, auth bypass, mass assignment, IDOR, rate limiting.

### FR-24: (10x) Performance Profiling (Indulge --perf)
Time every step in every flow, flag bottlenecks, measure memory delta, identify N+1 queries.

### FR-25: (10x) Regression Mode (Indulge --regression)
Compare current indulge results against a previous run to detect regressions and improvements.

### FR-26: (10x) CI Workflow Generation (Indulge --ci)
Generate a GitHub Actions (or detected CI system) workflow file for automated flow testing on PRs.

### FR-27: (10x) Auto-Heal (Indulge --auto-heal)
When a flow test fails, automatically dispatch /healer:fix for the failing code, then re-test. Max 3 attempts per flow before marking STUCK.

### FR-28: (10x) HTML Dashboard (Indulge --dashboard)
Generate a self-contained HTML file with Chart.js charts showing: overall pass rate, per-dimension breakdown, per-flow-type breakdown, flow details with screenshots, performance timings, security findings, and accessibility scores.

### FR-29: (10x) API Contract Testing (Indulge --contract)
Validate API responses against schemas discovered during record. Flag extra fields, missing fields, wrong types, and undocumented responses.

### FR-30: (10x) OpenAPI Generation (Record --openapi)
Auto-generate an OpenAPI 3.0 spec file from discovered API endpoints, including request/response schemas, auth requirements, and error responses.

---

## 5. Non-Functional Requirements

### NFR-1: Performance
- Record should complete in under 5 minutes for projects with <500 files
- Indulge should test each flow in under 30 seconds (per flow)
- Large projects (>1000 files) should show progress indicators

### NFR-2: Output Size
- Record summary section must be under 200 lines (readable as context)
- Full record may exceed 1000 lines for large apps
- `--summary` flag produces top-level flows only (<500 lines)

### NFR-3: Safety
- Record is READ-ONLY — never modifies source files
- Indulge only CREATES test files — never modifies source files
- Neither command runs destructive operations (no DB mutations, no git changes)

---

## 6. Error Catalog

| Error | Condition | User Message | Recovery |
|-------|-----------|-------------|----------|
| ERR_NO_PROJECT | No detectable project in cwd | "No project found. Run from a project root with package.json, Cargo.toml, etc." | cd to project root |
| ERR_EMPTY_PROJECT | Project detected but no source files | "Project detected but no source files found in standard directories." | Check project structure |
| ERR_NO_RECORD | Indulge called but no record file exists | "No record file found. Run /healer:record first." | Run record first |
| ERR_RECORD_STALE | Record file is older than 30 days | "Record file is {N} days old. Consider re-running /healer:record." | Re-run record |
| ERR_NO_PLAYWRIGHT | UI flows need testing but Playwright not available | "Playwright MCP not available. UI flows will be tested via generated test files only." | Install Playwright MCP or use --api-only |
| ERR_NO_SERVER | API flows need testing but no running server detected | "No running server detected on expected ports. Start the dev server first, or use --generate-only." | Start dev server |
| ERR_RECORD_TOO_LARGE | Record exceeds 5000 lines | "Record file is very large ({N} lines). Consider scoping with --backend-only or module name." | Use scope args |

---

## 7. Integration Points

### 7.1 Flow Presets to Add (Base + 10x)
```yaml
# Base presets
record-test:
  description: "Record all flows then test them"
  steps:
    - command: record
      gate: auto
    - command: indulge
      gate: must-pass

record-verify:
  description: "Record, test, then verify requirements"
  steps:
    - command: record
      gate: auto
    - command: indulge
      gate: auto
    - command: verify
      gate: must-pass
    - command: push
      gate: interactive

full-qa:
  description: "Complete QA: record, indulge, coverage, report"
  steps:
    - command: record
      gate: auto
    - command: indulge
      gate: must-pass
    - command: coverage
      gate: auto
    - command: report
      gate: auto

onboard:
  description: "Onboarding: understand the app (read-only)"
  steps:
    - command: record
      gate: auto
    - command: report
      gate: auto

# 10x presets
record-full:
  description: "Full 10x recording + testing with all features"
  steps:
    - command: record --full
      gate: auto
    - command: indulge --full
      gate: must-pass
    - command: push
      gate: interactive

record-secure:
  description: "Security-focused recording and testing"
  steps:
    - command: record --risk
      gate: auto
    - command: indulge --security --contract
      gate: must-pass
    - command: audit
      gate: auto
    - command: report
      gate: auto

record-visual:
  description: "Visual design audit from code"
  steps:
    - command: record --design-only
      gate: auto
    - command: indulge --visual --a11y
      gate: auto
    - command: design-review
      gate: interactive
    - command: report
      gate: auto

record-onboard:
  description: "Full onboarding with CLAUDE.md generation"
  steps:
    - command: record --full --claude-md
      gate: auto
    - command: report
      gate: auto

record-regression:
  description: "Regression detection between runs"
  steps:
    - command: record --diff
      gate: auto
    - command: indulge --regression
      gate: auto
    - command: report
      gate: auto
```

### 7.2 Suggested Next Graph Additions
```
record   → indulge, verify, test, report, analyze
indulge  → fix, test, push, report, coverage
```

### 7.3 Complete Flag Reference

**Record flags:**
| Flag | Category | What it enables |
|------|----------|----------------|
| (no args) | Base | Full 8-layer recording |
| {module} | Base | Scope to specific module |
| --backend-only | Base | Skip frontend/UI layers |
| --frontend-only | Base | Skip backend layers |
| --design-only | Base | UI design extraction only |
| --summary | Base | Top-level flows only (<500 lines) |
| --risk | 10x | Risk scoring per flow (5 factors) |
| --timeline | 10x | Git history per flow |
| --impact {file} | 10x | Show all flows affected by file |
| --diff | 10x | Compare against previous record |
| --claude-md | 10x | Auto-generate CLAUDE.md |
| --openapi | 10x | Auto-generate OpenAPI spec |
| --full | 10x | All 10x features enabled |

**Indulge flags:**
| Flag | Category | What it enables |
|------|----------|----------------|
| (no args) | Base | Test all flows, 6 dimensions |
| {flow IDs} | Base | Test specific flows |
| --record {path} | Base | Use specific record file |
| --generate-only | Base | Generate test files, don't execute |
| --api-only | Base | API flows only |
| --ui-only | Base | UI flows only (browser) |
| --negative-only | Base | Only negative/edge case tests |
| --visual | 10x | Visual regression screenshots |
| --a11y | 10x | Accessibility testing (axe-core) |
| --security | 10x | OWASP-based security testing |
| --perf | 10x | Performance timing per flow |
| --regression | 10x | Compare against previous run |
| --ci | 10x | Generate CI workflow file |
| --auto-heal | 10x | Auto-fix failures via /healer:fix |
| --dashboard | 10x | Generate HTML visual dashboard |
| --contract | 10x | API contract validation |
| --full | 10x | All 10x features enabled |

### 7.3 Files to Create/Modify
| File | Action | Purpose |
|------|--------|---------|
| commands/record.md | CREATE | The record command definition |
| commands/indulge.md | CREATE | The indulge command definition |
| config/recipes.yaml | MODIFY | Add new flow presets |
| commands/flow.md | MODIFY | Add presets + suggested-next graph entries |
| commands/help.md | MODIFY | Add record + indulge to help listing |
| install.sh | MODIFY | Update command count (39→41) + mention new commands |
| plugin.json | MODIFY | Update version + description |
| .claude-plugin/plugin.json | MODIFY | Update version |
| .claude-plugin/marketplace.json | MODIFY | Add new command descriptions |

---

## 8. Requirements Traceability Matrix

| Req ID | Requirement | Category | Command | Key Flag |
|--------|------------|----------|---------|----------|
| FR-1 | Stack detection | Base | record + indulge | (always) |
| FR-2 | 8-layer discovery | Base | record | (default) |
| FR-3 | UI design extraction | Base | record | (default) |
| FR-4 | Flow ID system | Base | record | (always) |
| FR-5 | Single file output | Base | record | (always) |
| FR-6 | Cross-reference matrix | Base | record | (always) |
| FR-7 | Record parsing | Base | indulge | (always) |
| FR-8 | 6-dim testing | Base | indulge | (default) |
| FR-9 | Tool detection | Base | indulge | (always) |
| FR-10 | Test file generation | Base | indulge | (default) |
| FR-11 | Mermaid diagrams | 10x | record | --full |
| FR-12 | Risk scoring | 10x | record | --risk / --full |
| FR-13 | Git timeline | 10x | record | --timeline / --full |
| FR-14 | Impact analysis | 10x | record | --impact {file} |
| FR-15 | Dead code detection | 10x | record | --full |
| FR-16 | Record diff | 10x | record | --diff |
| FR-17 | CLAUDE.md generation | 10x | record | --claude-md |
| FR-18 | Data lineage | 10x | record | --full |
| FR-19 | Security surface map | 10x | record | --full |
| FR-20 | Complexity heatmap | 10x | record | --full |
| FR-21 | Visual regression | 10x | indulge | --visual |
| FR-22 | Accessibility testing | 10x | indulge | --a11y |
| FR-23 | Security testing | 10x | indulge | --security |
| FR-24 | Performance profiling | 10x | indulge | --perf |
| FR-25 | Regression mode | 10x | indulge | --regression |
| FR-26 | CI workflow generation | 10x | indulge | --ci |
| FR-27 | Auto-heal | 10x | indulge | --auto-heal |
| FR-28 | HTML dashboard | 10x | indulge | --dashboard |
| FR-29 | Contract testing | 10x | indulge | --contract |
| FR-30 | OpenAPI generation | 10x | record | --openapi |

**Summary: 30 functional requirements (10 base + 20 10x)**

---

## 9. Open Questions

1. **Should record detect app name from package.json `name` field, or from the directory name?** — Recommendation: package.json first, directory name as fallback.
2. **Should indulge test against a live server or generate-only by default?** — Recommendation: detect if server is running; if yes, test live; if no, generate-only.
3. **Should record include third-party library internals (node_modules)?** — Recommendation: No. Only project source code.
4. **Maximum recursion depth for call graph tracing?** — Recommendation: 5 levels deep, with a flag to go deeper.
5. **(10x) Should --full be the default or must it be explicitly requested?** — Recommendation: Explicit. Base mode is faster and produces smaller output. --full is opt-in.
6. **(10x) Where should visual regression baselines be stored?** — Recommendation: tests/visual/baselines/ directory, committed to git.
7. **(10x) Should the HTML dashboard be a single file or include external assets?** — Recommendation: Single self-contained HTML (inline CSS, JS, Chart.js CDN).
8. **(10x) Should --ci detect the CI system or default to GitHub Actions?** — Recommendation: Detect from existing workflow files; default to GitHub Actions if none found.
