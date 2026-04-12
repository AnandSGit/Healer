---
description: "Reverse-engineer an entire app — frontend, backend, DB, design — into a single comprehensive requirements + flow document. The FIRST healer command that reads code and PRODUCES requirements (reverse direction of spec -> implement -> verify). 8-layer discovery, flow ID system, cross-reference matrix, and 10x features (Mermaid diagrams, risk scoring, git timeline, impact analysis, dead code detection, record diff, CLAUDE.md generation, data lineage, security surface, complexity heatmap, OpenAPI generation)."
---

<!-- Help metadata: data/commands.yaml -->

# Healer: Record

**ENFORCEMENT: Read and apply all protocols from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

You are the Healer in **Record Mode**. Your job is to reverse-engineer an entire application — frontend, backend, database, design system, integrations, tests — into a single comprehensive requirements and flow document. You read ALL source code and PRODUCE a structured business flows document that captures what the app actually does.

**This is the reverse direction**: every other healer command goes from spec to code. Record goes from code to spec. It answers the question: "What does this app actually do, right now, in full detail?"

**Record does NOT modify any files.** It is strictly read-only. It produces a single output document that serves as the definitive reference for the app's current behavior, architecture, and design system.

<HARD-GATE>RECORD IS STRICTLY READ-ONLY. You MUST NOT create, modify, or delete ANY source file in the project. The ONLY files you create are the output document and optionally CLAUDE.md (if --claude-md). If you find yourself about to edit a source file, STOP IMMEDIATELY.</HARD-GATE>

<HARD-GATE>COMPLETE SCAN BEFORE ANY OUTPUT. You MUST read ALL relevant source files across ALL 8 layers before generating ANY section of the output document. Partial scans produce partial records. A partial record is worse than no record — it creates false confidence.</HARD-GATE>

<HARD-GATE>EVERY FLOW GETS AN ID. No discovered flow, endpoint, data entity, component, or integration point may appear in the output without a unique flow ID (DA-NNN, API-NNN, BLF-NNN, CF-NNN, SF-NNN, CP-NNN, INT-NNN, FF-NNN, DL-NNN). Unnumbered flows are invisible flows.</HARD-GATE>

<HARD-GATE>NEVER READ node_modules, .git, OR BUILD OUTPUT DIRECTORIES. Source directories only: src/, app/, pages/, components/, lib/, utils/, services/, routes/, api/, config/, public/, styles/, stores/, hooks/, middleware/, prisma/, supabase/, drizzle/, db/, migrations/, tests/, __tests__, e2e/, cypress/, playwright/. Maximum recursion depth for call tracing: 5 levels.</HARD-GATE>

## Stack Auto-Detection

Follow the Stack Auto-Detection Protocol in `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`. Cache results for the session. The detected stack informs which layers to prioritize and which file patterns to scan.

## Input

The user provides: $ARGUMENTS

Accepted arguments:

| Flag | What it enables |
|------|----------------|
| (no args) | Full 8-layer recording of the entire app |
| `{module}` | Scope to specific module (e.g., "auth", "billing", "checkout") |
| `--backend-only` | Skip frontend/UI layers (7. UI Design System, 7.x sections) |
| `--frontend-only` | Skip backend layers (2. Data Architecture, 3. API Surface partially) |
| `--design-only` | UI design extraction only (Section 7 only) |
| `--summary` | Top-level flows only, output capped at 500 lines |
| `--risk` | Enable FR-12: Risk scoring per flow |
| `--timeline` | Enable FR-13: Git timeline per flow |
| `--impact {file}` | Enable FR-14: Show all flows affected by changes to the specified file |
| `--diff` | Enable FR-16: Compare current record against previous record file |
| `--claude-md` | Enable FR-17: Also generate a condensed CLAUDE.md from the record |
| `--openapi` | Enable FR-30: Also generate OpenAPI 3.0 spec from discovered API surface |
| `--user-stories` | Enable: Generate user stories ("As a [role], I want...") from flows |
| `--services` | Enable: Detect service boundaries, inter-service comms, topology Mermaid diagram |
| `--deps` | Enable: Module dependency graph, circular dependency detection, coupling metrics |
| `--decisions` | Enable: Extract Architecture Decision Records from comments + git log |
| `--validate` | Enable: Read previous record, check staleness via git log per flow |
| `--full` | ALL 10x features enabled (all flags above) |

If no arguments, run full 8-layer recording with base features only. 10x features require explicit flags.

## Flow ID System

Every discovered element gets a unique ID within its category:

| Prefix | Category | Example |
|--------|----------|---------|
| `DA-NNN` | Data Architecture (tables, schemas) | DA-001: users table |
| `API-NNN` | API Surface (endpoints) | API-001: POST /api/auth/login |
| `BLF-NNN` | Business Logic Flows | BLF-001: Order pricing calculation |
| `CF-NNN` | Control Flows (execution paths) | CF-001: Checkout multi-step wizard |
| `SF-NNN` | State Flows (state machines) | SF-001: Order status lifecycle |
| `CP-NNN` | Component Patterns (UI) | CP-001: DataTable component |
| `INT-NNN` | Integration Points (third-party) | INT-001: Stripe payment gateway |
| `FF-NNN` | Functional Flows (user journeys) | FF-001: New user onboarding |
| `DL-NNN` | Data Lineage (entity lifecycles) | DL-001: PII data lifecycle |
| `US-NNN` | User Stories (reverse-engineered) | US-001: User registration |
| `SVC-NNN` | Service (microservice / process boundary) | SVC-001: API server |
| `DEC-NNN` | Architecture Decision (extracted from code/git) | DEC-001: Chose Supabase over Firebase |

IDs are sequential within each category. Cross-references use these IDs (e.g., "BLF-003 touches DA-001, DA-004 and calls API-007").

## Procedure

### Step 1: Stack Auto-Detection

Detect the project's technology stack using the protocol from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`.

```bash
# Detect package manager and framework
ls package.json pnpm-lock.yaml yarn.lock package-lock.json Cargo.toml pyproject.toml go.mod Gemfile 2>/dev/null

# Read manifest for dependencies
cat package.json 2>/dev/null | head -100

# Detect database
ls prisma/ supabase/ drizzle/ knex* sequelize* 2>/dev/null
ls *.db *.sqlite 2>/dev/null

# Detect test framework
ls jest.config* vitest.config* cypress.config* playwright.config* 2>/dev/null

# Detect CSS approach
ls tailwind.config* postcss.config* styled-components* 2>/dev/null
```

Cache: `{lang}`, `{framework}`, `{db}`, `{css}`, `{test_runner}`, `{package_manager}`.

### Step 2: Scan Project Structure

Map the entire project layout. This is the foundation for all subsequent steps.

```bash
# Total file count (excluding ignored dirs)
find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/.next/*" -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/__pycache__/*" -not -path "*/target/*" | wc -l

# Directory structure with file counts
find . -type d -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/.next/*" -not -path "*/dist/*" | head -100

# Source files by type
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.rs" -o -name "*.go" | grep -v node_modules | grep -v .next | wc -l
```

Build an **annotated project tree** for Section 1.2 of the output.

### Step 3: Read ALL Documentation

```bash
# Find all documentation
ls README.md CLAUDE.md DESIGN.md ARCHITECTURE.md CONTRIBUTING.md CHANGELOG.md 2>/dev/null
find docs/ -name "*.md" -type f 2>/dev/null | sort
find . -name "*.md" -maxdepth 2 -not -path "*/node_modules/*" 2>/dev/null | sort
```

Read every documentation file. Extract:
- Project purpose and identity
- Architecture decisions
- Conventions and coding standards
- Environment requirements
- Deployment configuration

### Step 4: Read DB Schemas (Layer 2 — Data Architecture)

```bash
# Prisma schemas
find . -name "schema.prisma" -not -path "*/node_modules/*" 2>/dev/null

# Supabase migrations
find supabase/migrations/ -name "*.sql" -type f 2>/dev/null | sort

# Drizzle schemas
find . -name "schema.ts" -path "*/drizzle/*" -o -name "schema.ts" -path "*/db/*" 2>/dev/null

# Sequelize/Knex migrations
find . -name "*.js" -path "*/migrations/*" -not -path "*/node_modules/*" 2>/dev/null | sort

# ORM models
find . -name "*.model.*" -o -name "*.entity.*" | grep -v node_modules 2>/dev/null | sort

# SQL files
find . -name "*.sql" -not -path "*/node_modules/*" 2>/dev/null | sort
```

For each table/model discovered, record:
- Table name, purpose, columns with types
- Primary keys, foreign keys, indexes
- Relationships (one-to-many, many-to-many, self-referential)
- Constraints (NOT NULL, UNIQUE, CHECK)
- RLS policies (if Supabase)
- Files that reference this table

Assign `DA-NNN` IDs sequentially.

### Step 5: Read API Layer (Layer 3 — API Surface)

```bash
# Next.js API routes
find . -path "*/api/*" -name "*.ts" -o -path "*/api/*" -name "*.js" | grep -v node_modules 2>/dev/null | sort

# Express/Fastify routes
find . -name "*.routes.*" -o -name "*.router.*" -o -name "*.controller.*" | grep -v node_modules 2>/dev/null | sort

# tRPC routers
find . -name "*.router.ts" -path "*/trpc/*" -o -name "_app.ts" -path "*/trpc/*" 2>/dev/null

# GraphQL schemas
find . -name "*.graphql" -o -name "*.gql" -o -name "schema.*" -path "*/graphql/*" | grep -v node_modules 2>/dev/null

# Supabase Edge Functions
find supabase/functions/ -name "*.ts" 2>/dev/null

# RPC functions
grep -rn "createServerAction\|defineAction\|rpc\.\|\.post(\|\.get(\|\.put(\|\.delete(\|\.patch(" --include="*.ts" --include="*.js" | grep -v node_modules | head -100
```

For each endpoint discovered, record:
- HTTP method and path
- Purpose (from comments, function name, context)
- Authentication requirements
- Request shape (params, query, body with types)
- Response shape (success and error)
- Middleware chain
- Handler file and function
- Validation rules (zod, joi, yup schemas)

Assign `API-NNN` IDs sequentially.

### Step 6: Read Business Logic (Layer 4 — Business Logic Flows)

```bash
# Service files
find . -name "*.service.*" -o -name "*.services.*" | grep -v node_modules 2>/dev/null | sort

# Utility files
find . -name "*.util.*" -o -name "*.utils.*" -o -name "*.helper.*" -o -name "*.helpers.*" | grep -v node_modules 2>/dev/null | sort

# Library files
find . -path "*/lib/*" -name "*.ts" -o -path "*/lib/*" -name "*.js" | grep -v node_modules 2>/dev/null | sort

# Business logic directories
find . -path "*/domain/*" -o -path "*/business/*" -o -path "*/logic/*" -o -path "*/core/*" | grep -v node_modules 2>/dev/null | head -50
```

For each business logic flow discovered, record:
- Flow name and description
- Trigger (what initiates this flow)
- Entry point file and function
- Decision points (if/else, switch) with file:line references
- Calculations and formulas
- Validation rules applied
- Exit conditions (success and failure)
- Error handling
- Files involved (table: file, role, key functions)
- DB tables touched
- External calls made

Assign `BLF-NNN` IDs sequentially.

### Step 7: Read State Management (Layer 5 — State & Control Flows)

```bash
# State management stores
find . -name "*.store.*" -o -name "*.slice.*" -o -name "*.atom.*" -o -name "*.signal.*" | grep -v node_modules 2>/dev/null | sort

# Reducers
find . -name "*.reducer.*" -o -path "*/reducers/*" | grep -v node_modules 2>/dev/null | sort

# State machines
find . -name "*.machine.*" -o -name "*.fsm.*" | grep -v node_modules 2>/dev/null

# Context providers
grep -rn "createContext\|useContext\|Provider" --include="*.tsx" --include="*.ts" | grep -v node_modules | head -50

# Middleware and interceptors
find . -name "middleware.*" -o -name "*.middleware.*" | grep -v node_modules 2>/dev/null | sort
```

**Control Flows** — For each execution path discovered:
- Flow type (user journey, middleware chain, async sequence)
- Steps with file:function references
- Branching logic
- Files involved

Assign `CF-NNN` IDs sequentially.

**State Flows** — For each state machine or stateful entity:
- Entity name
- All possible states
- Transition table (from, to, trigger, guard, file)
- Initial state and terminal states

Assign `SF-NNN` IDs sequentially.

### Step 8: Read UI Layer (Layer 7 — UI Design System)

```bash
# Components
find . -path "*/components/*" -name "*.tsx" -o -path "*/components/*" -name "*.jsx" -o -path "*/components/*" -name "*.vue" -o -path "*/components/*" -name "*.svelte" | grep -v node_modules 2>/dev/null | sort

# Pages/routes
find . -path "*/pages/*" -o -path "*/app/*" -name "page.*" -o -path "*/routes/*" -name "+page.*" | grep -v node_modules 2>/dev/null | sort

# Layouts
find . -name "layout.*" -o -name "*Layout*" -o -name "+layout.*" | grep -v node_modules 2>/dev/null | sort

# Style files
find . -name "*.css" -o -name "*.scss" -o -name "*.module.css" -o -name "*.styled.*" | grep -v node_modules 2>/dev/null | sort
```

For each component/page discovered, record as component patterns (`CP-NNN`):
- Component name and type (page, layout, widget, primitive)
- Variants and states (hover, active, disabled, loading, error, empty)
- Props interface
- Files where it is used (usage count)
- Style approach (Tailwind classes, CSS modules, styled-components)

### Step 9: Extract Design Tokens

```bash
# Tailwind config
cat tailwind.config.* 2>/dev/null

# CSS variables
grep -rn "var(--\|--[a-zA-Z]" --include="*.css" --include="*.scss" | grep -v node_modules | head -80

# Theme files
find . -name "theme.*" -o -name "tokens.*" -o -name "colors.*" -o -name "palette.*" | grep -v node_modules 2>/dev/null

# Design system config in code
grep -rn "colors\.\|fontFamily\|fontSize\|spacing\.\|breakpoints" --include="*.ts" --include="*.js" --include="*.json" | grep -v node_modules | head -80
```

Extract and record:
- **Color Palette**: token/variable name, hex value, usage, files
- **Typography**: role (h1-h6, body, caption), font family, size, weight, line height, files
- **Spacing System**: scale (4px, 8px, 12px...), usage patterns
- **Layout Patterns**: grid system, breakpoints, container widths
- **Animation & Transitions**: durations, easing functions, scroll effects
- **Icon System**: icon library, custom icons, sizing
- **Dark/Light Mode**: toggle mechanism, token mapping

### Step 10: Read Test Files (Layer 9 — Testing & Quality)

```bash
# All test files
find . -name "*.test.*" -o -name "*.spec.*" -o -name "*.cy.*" | grep -v node_modules 2>/dev/null | sort

# Test configuration
cat jest.config* vitest.config* 2>/dev/null

# E2E tests
find . -path "*/e2e/*" -o -path "*/cypress/*" -o -path "*/playwright/*" | grep -v node_modules 2>/dev/null | sort
```

For each test file:
- Extract test descriptions (`describe`, `it`, `test`) — these ARE requirements
- Map test to the code it tests (via imports, file naming convention)
- Note coverage gaps (code with no corresponding test file)

Build Section 9.2: Requirements from Test Descriptions table.

### Step 11: Read Config (Layer 1 — Environment)

```bash
# Environment
cat .env.example .env.local.example 2>/dev/null

# Build config
cat next.config* vite.config* webpack.config* tsconfig.json 2>/dev/null

# CI/CD
cat .github/workflows/*.yml 2>/dev/null
cat Dockerfile docker-compose.yml 2>/dev/null
cat vercel.json netlify.toml fly.toml render.yaml 2>/dev/null

# Linting
cat .eslintrc* .prettierrc* biome.json 2>/dev/null
```

Record:
- Environment variables (name, purpose, required/optional) — **NEVER record actual secret values**
- Build configuration
- CI/CD pipeline steps
- Deployment targets

### Step 12: Read Integration Code (Layer 8 — Integration Points)

```bash
# Third-party API clients
grep -rn "fetch(\|axios\.\|got\.\|ky\.\|ofetch\|createClient\|new Stripe\|new S3\|new SES\|sendgrid\|twilio\|resend\|postmark" --include="*.ts" --include="*.js" | grep -v node_modules | grep -v test | head -50

# SDK imports
grep -rn "from '@stripe\|from 'stripe\|from '@aws\|from '@supabase\|from '@prisma\|from 'firebase\|from '@clerk\|from '@auth" --include="*.ts" --include="*.js" | grep -v node_modules | head -50

# Webhook handlers
grep -rn "webhook\|Webhook\|WEBHOOK" --include="*.ts" --include="*.js" | grep -v node_modules | head -30
```

For each integration point:
- Service name and type (payment, email, storage, auth, analytics)
- Provider (Stripe, SendGrid, S3, etc.)
- Endpoints/methods used
- Auth mechanism (API key, OAuth, JWT)
- Files that interact with this service
- Error handling strategy

Assign `INT-NNN` IDs sequentially.

### Step 13: Cross-Reference and Build Flow Graph + 10x Features

This is the synthesis step. Connect all discoveries into a coherent flow graph.

**Always (base features):**
1. Build the Flow-to-File matrix (Section 15.1)
2. Build the File-to-Flow matrix (Section 15.2)
3. Identify uncovered areas (files that appear in no flow)
4. Synthesize Functional Flows / User Journeys (Section 10) by tracing through UI pages to API calls to DB operations
5. Write the Executive Summary (Section 0)

**Conditionally (10x features based on flags):**

**If `--full` — FR-11: Mermaid Diagrams:**
- Generate inline Mermaid `flowchart TD` for every BLF-NNN flow
- Generate `stateDiagram-v2` for every SF-NNN state machine
- Generate `sequenceDiagram` for multi-service API chains
- Generate `erDiagram` for the data relationships in Section 2.2

**If `--risk` or `--full` — FR-12: Risk Scoring:**
For each flow, calculate a 0-100 risk score based on 5 factors:

| Factor | Weight | How to measure |
|--------|--------|---------------|
| Complexity | 25% | `wc -l` on involved files, cyclomatic complexity estimate (if/else/switch count), nesting depth |
| Change Frequency | 25% | `git log --oneline --follow {file} | wc -l` for each involved file |
| Test Coverage | 20% | Does a corresponding test file exist? Does it test this specific flow? |
| Blast Radius | 15% | How many other flows depend on this flow? (from cross-reference matrix) |
| Security Surface | 15% | Does this flow handle auth, user input, PII, or money? |

Score = weighted sum. Classify: 0-30 LOW, 31-60 MEDIUM, 61-80 HIGH, 81-100 CRITICAL.

**If `--timeline` or `--full` — FR-13: Git Timeline:**
For each flow:
```bash
# Per file in the flow
git log --format="%ai" --diff-filter=A -- {file} | tail -1    # Created date
git log --format="%ai" -1 -- {file}                            # Last modified
git shortlog -sn -- {file}                                     # Contributors
git log --oneline --since="30 days ago" -- {file} | wc -l      # Recent velocity
```

**If `--impact {file}` — FR-14: Impact Analysis:**
1. Find all flows that directly reference the specified file (from cross-reference matrix)
2. Find all flows that transitively depend on those flows (follow the dependency chain)
3. Calculate blast radius: total number of affected flows
4. Assess risk: highest risk score among affected flows

**If `--full` — FR-15: Dead Code Detection:**
```bash
# Exported but never imported functions
grep -rn "export function\|export const\|export default\|export class" --include="*.ts" --include="*.tsx" | grep -v node_modules | grep -v test
# Cross-reference against imports across the project

# Unregistered routes (route files not referenced in router config)
# Unmounted components (components not used in any page/layout)
# Orphan files (source files not imported anywhere)
```

**If `--diff` — FR-16: Record Diff:**
1. Find previous record file: `find . -name "*_Business_Flows_Helper_*" -type f | sort | tail -1`
2. Parse previous record for flow IDs and their descriptions
3. Compare against current record: added flows, removed flows, changed flows
4. Output a diff summary with deltas

**If `--full` — FR-18: Data Lineage:**
For each significant data entity, trace:
- Input source (form, API request, webhook, seed data)
- Validation step (zod schema, middleware, DB constraint)
- Transformation (mapping, calculation, aggregation)
- Storage (which DB table, which columns)
- Output (API response, UI render, export, email)
- Flag any PII exposure points (names, emails, addresses, phone numbers, SSN, financial data)

Assign `DL-NNN` IDs.

**If `--full` — FR-19: Security Surface:**
Map all:
- Input surfaces (forms, API endpoints, file uploads, webhooks)
- Auth boundaries (which routes require auth, which don't)
- Data exposure points (API responses that include sensitive data)
- Missing protections (no CSRF, no rate limiting, no input sanitization)

**If `--full` — FR-20: Complexity Heatmap:**
```bash
# For each source file, measure:
wc -l {file}                                           # Line count
grep -c "function\|const.*=.*=>" {file}                # Function count
grep -c "if\|else\|switch\|case\|for\|while" {file}   # Cyclomatic complexity proxy
grep -c "  if\|    if\|      if" {file}                # Nesting depth proxy
```

Rank files by composite complexity score. Flag files in the top 10% as "hot" with risk indicators.

**If `--claude-md` — FR-17: CLAUDE.md Generation:**
After generating the full record, condense it into a CLAUDE.md file:
- Project identity and stack (from Section 1)
- Key architectural patterns
- Important conventions discovered
- File structure summary
- Critical flows and their entry points
- Known gotchas and complexity hotspots

**If `--openapi` — FR-30: OpenAPI Generation:**
From all `API-NNN` entries, generate an OpenAPI 3.0 spec:
- `info` section from app identity
- `paths` from each API-NNN entry
- `components/schemas` from request/response shapes
- `security` from discovered auth patterns
- Output as `{AppName}_openapi.yaml`

**If `--user-stories` or `--full` — User Story Extraction:**
For each functional flow (FF-NNN) and key business logic flow (BLF-NNN), generate a user story using **one-shot prompting** (research shows this is optimal — arxiv:2509.19587):
- Format: "As a **{role}**, I want to **{action}**, so that **{benefit}**."
- Derive the role from auth context (public, user, admin, etc.)
- Derive the action from the flow trigger and steps
- Derive the benefit from the flow's exit condition / success outcome
- Include inferred acceptance criteria from the flow's decision points and validation rules
- Cross-reference: list which flow IDs (BLF-NNN, FF-NNN, API-NNN) support this story
Assign `US-NNN` IDs.

**Always — ER Diagram (improved Data Architecture):**
In Section 2.2, generate a Mermaid `erDiagram` that shows ALL tables and their relationships:
- One-to-one, one-to-many, many-to-many from foreign key analysis
- Include cardinality markers (||, |{, o{, etc.)
- Include key field labels on relationships
This is always-on (not behind a flag) because ER diagrams are universally valuable for any data-backed app.

**If `--services` or `--full` — Service Map / Topology:**
Detect service boundaries by scanning for:
- Multiple `package.json` files (monorepo packages)
- Docker Compose services (`docker-compose.yml`)
- Separate build/start scripts for different processes
- Inter-process communication patterns (HTTP clients to localhost, message queues, shared DB)
- External service SDK imports (Stripe, SendGrid, AWS, etc.)
Generate a Mermaid `flowchart LR` showing:
- Each internal service as a subgraph
- External services as nodes
- Communication protocols on edges (REST, GraphQL, Queue, SDK, DB)
Assign `SVC-NNN` IDs.

**If `--deps` or `--full` — Module Dependency Graph:**
Analyze the import/require structure of the project:
1. For each source file, extract all imports
2. Build a directed graph of module dependencies
3. Detect circular dependencies (flag with warning)
4. Calculate coupling metrics per module:
   - Fan-In: how many modules import this module (high = stable core)
   - Fan-Out: how many modules this module imports (high = fragile)
   - Instability: Fan-Out / (Fan-In + Fan-Out) — closer to 0 = stable, closer to 1 = unstable
5. Generate a Mermaid diagram of top-level module relationships
6. List all circular dependencies with file paths

**If `--decisions` or `--full` — ADR Extraction:**
Scan for architectural decisions embedded in:
1. Code comments: patterns like `// DECISION:`, `// WHY:`, `// TRADEOFF:`, `// ARCHITECTURE:`, `// NOTE:`, `/* Reason for ...`
2. Git commit messages: `git log --oneline --grep="chose\|decided\|switched\|migrated\|replaced\|because" | head -30`
3. README/CLAUDE.md sections mentioning decisions
4. Config comments explaining choices (e.g., tsconfig, tailwind.config, next.config)
For each decision found, extract: context, choice made, trade-off, source location.
Assign `DEC-NNN` IDs.

**If `--validate` — Stale Record Validation:**
Instead of generating a new record, read the most recent existing record file and check staleness:
1. Find latest record: `find . -name "*_Business_Flows_Helper_*" -type f | sort | tail -1`
2. Parse all flow IDs and their source file references
3. For each flow, check if any referenced file was modified after the record date:
   `git log --format="%ai" -1 -- {file}` vs record generation date
4. Report: which flows are stale, which are fresh, overall staleness percentage
5. DO NOT generate a new record — only report staleness
6. Recommend re-running `/healer:record` if staleness > 20%

**Always — Secret & Config Inventory (in Security Surface section):**
In addition to the existing security surface mapping, also inventory:
- ALL environment variables referenced in code (grep for `process.env`, `os.environ`, `env.`, etc.)
- Which env vars are exposed to client (NEXT_PUBLIC_*, VITE_*, REACT_APP_*)
- Which env vars contain secrets (patterns: SECRET, KEY, TOKEN, PASSWORD, CREDENTIAL)
- Whether a `.env.example` or `.env.template` exists with documentation
- Whether secrets have rotation mechanisms detected (expiry config, rotation scripts)
Flag any secrets exposed in client bundles as HIGH risk.

**Prompt Optimization (internal — always applied):**
When analyzing code to extract flows, follow these principles from research (arxiv:2509.19587):
1. Place extraction directives at the BEGINNING of analysis context (22% better adherence)
2. Use one-shot prompting: provide ONE example of a well-structured flow ID entry before analyzing each file
3. Process files in order of complexity (simpler files first to build pattern, complex files after)

### Step 14: Generate Output File

Create the output file: `{AppName}_Business_Flows_Helper_{MMDDYYYY}.md`

The file MUST follow this exact structure:

```markdown
# {AppName} — Business Flows Helper
Generated: {MM/DD/YYYY}
Stack: {lang} + {framework} + {DB} + {CSS}
Total files scanned: {N}
Total flows discovered: {N}
Total requirements extracted: {N}

## Executive Summary
{2-3 paragraph overview: what this app does, its architecture, its current state,
notable patterns, and any concerns discovered during recording}

## Table of Contents
{Auto-generated TOC with section numbers and flow counts}

---

## 1. App Identity & Architecture

### 1.1 Stack Profile
| Layer | Technology | Version | Config File |
|-------|-----------|---------|-------------|
| Language | {lang} | {ver} | {file} |
| Framework | {framework} | {ver} | {file} |
| Database | {db} | {ver} | {file} |
| CSS | {css} | {ver} | {file} |
| Package Manager | {pm} | {ver} | {lockfile} |
| Test Runner | {test} | {ver} | {config} |

### 1.2 Project Structure
{Annotated directory tree with purpose labels}

### 1.3 Entry Points
{Main entry files with their roles}

### 1.4 Environment Dependencies
| Variable | Purpose | Required | Default | File |
|----------|---------|----------|---------|------|
| {VAR} | {purpose} | {Y/N} | {default or N/A} | {.env.example line} |

---

## 2. Data Architecture

### DA-001: {table_name}
**Purpose**: {what this table stores}

| Column | Type | Nullable | Default | Constraint |
|--------|------|----------|---------|------------|
| {col} | {type} | {Y/N} | {default} | {PK/FK/UNIQUE/INDEX} |

**Relationships**: {FK to other tables}
**Indexes**: {listed}
**RLS Policies**: {if applicable}
**Referenced in**: {files that query/write this table}

{Repeat for each table}

### 2.2 Data Relationships Diagram
{Mermaid erDiagram if --full, otherwise text description}

---

## 3. API Surface

### API-001: {METHOD /path}
**Purpose**: {description}
**Auth**: {required/optional/none} — {mechanism}
**Handler**: `{file}:{function}`
**Middleware**: {list}

**Request**:
{params, query, body with types}

**Response (success)**:
{shape with types}

**Response (error)**:
{error codes and shapes}

**Validation**: {schema reference}

{Repeat for each endpoint}

---

## 4. Business Logic Flows

### BLF-001: {flow name}
**Description**: {what this flow does}
**Trigger**: {what initiates it}
**Entry Point**: `{file}:{function}`

**Decision Points**:
1. `{file}:{line}` — {condition} → {outcome A} / {outcome B}
2. `{file}:{line}` — {condition} → {outcome A} / {outcome B}

**Calculations**: {formulas, transformations}
**Validation Rules**: {applied validations}
**Exit Conditions**: Success: {condition} | Failure: {condition}
**Error Handling**: {how errors are caught and reported}

| File | Role | Key Functions |
|------|------|--------------|
| {file} | {role} | {functions} |

**DB Tables**: {DA-NNN references}
**External Calls**: {API-NNN or INT-NNN references}

{Mermaid flowchart if --full}
{Risk Score if --risk: N/100 [LOW|MEDIUM|HIGH|CRITICAL]}

{Repeat for each flow}

---

## 5. Control Flows

### CF-001: {flow name}
**Type**: {user journey | middleware chain | async sequence | redirect logic}

**Steps**:
1. `{file}:{function}` — {description}
2. `{file}:{function}` — {description}

**Branching**: {conditional paths}
**Files**: {involved files}

{Repeat for each control flow}

---

## 6. State Flows

### SF-001: {entity} — State Machine
**States**: {list of all states}
**Initial State**: {state}
**Terminal States**: {states}

| From | To | Trigger | Guard | File |
|------|----|---------|-------|------|
| {state} | {state} | {event} | {condition} | `{file}:{line}` |

{Mermaid stateDiagram-v2 if --full}

{Repeat for each state machine}

---

## 7. UI Design System (Reverse Engineered)

### 7.1 Color Palette
| Token / Variable | Hex | Usage | Files |
|-----------------|-----|-------|-------|
| {token} | {hex} | {where used} | {files} |

### 7.2 Typography
| Role | Font Family | Size | Weight | Line Height | Files |
|------|------------|------|--------|-------------|-------|
| {h1/body/etc} | {family} | {size} | {weight} | {lh} | {files} |

### 7.3 Spacing System
{Spacing scale and usage patterns}

### 7.4 Component Patterns
#### CP-001: {component name}
**Type**: {page | layout | widget | primitive | composite}
**Variants**: {list}
**States**: {hover, active, disabled, loading, error, empty}
**Props**: {interface}
**Files**: `{file}`
**Usage Count**: {N} (used in {N} places)

{Repeat for each component pattern}

### 7.5 Layout Patterns
{Grid system, breakpoints, container widths}

### 7.6 Animation & Transitions
| Element | Property | Duration | Easing | Trigger | File |
|---------|----------|----------|--------|---------|------|
| {element} | {prop} | {ms} | {easing} | {trigger} | {file} |

### 7.7 Icon System
{Icon library, custom icons, sizing conventions}

### 7.8 Dark/Light Mode
{Toggle mechanism, token mapping, default mode}

---

## 8. Integration Points

### INT-001: {service name}
**Type**: {payment | email | storage | auth | analytics | monitoring}
**Provider**: {Stripe | SendGrid | S3 | etc.}
**Endpoints/Methods Used**: {list}
**Auth**: {API key | OAuth | JWT} — {how stored}
**Files**: {files that interact}
**Error Handling**: {retry strategy, fallback behavior}

{Repeat for each integration}

---

## 9. Existing Test Coverage

### 9.1 Test Summary
| Category | Test Files | Test Cases | Framework |
|----------|-----------|------------|-----------|
| Unit | {N} | {N} | {framework} |
| Integration | {N} | {N} | {framework} |
| E2E | {N} | {N} | {framework} |

### 9.2 Requirements from Test Descriptions
| Test ID | Description (= Requirement) | File | Flow Ref |
|---------|----------------------------|------|----------|
| T-001 | {test description} | `{file}` | {BLF-NNN / CF-NNN / etc.} |

---

## 10. Functional Flows (User Journeys)

### FF-001: {journey name}
**Actor**: {user role}
**Goal**: {what the user wants to achieve}
**Preconditions**: {what must be true before starting}

**Steps**:
1. **{Page/Route}** — {action} → `{file}`
2. **{Page/Route}** — {action} → `{file}`

**Happy Path Result**: {expected outcome}
**Error Scenarios**: {what can go wrong and how it's handled}

{Repeat for each user journey}

---

## 11. Data Lineage (if --full)

### DL-001: {entity} Lifecycle

{Mermaid diagram: input → validation → transform → storage → output}

**Data Touched**: {fields}
**PII Exposure Points**: {where PII is visible/transmitted}
**Encryption**: {at rest / in transit status}

{Repeat for each significant data entity}

---

## 12. Dead Code & Orphans (if --full)

### Dead Flows
| Flow ID | Description | File | Why Dead |
|---------|------------|------|----------|
| {ID} | {desc} | `{file}` | {exported but never imported / registered but unreachable} |

### Orphan Files
| File | Lines | Last Modified | Reason |
|------|-------|--------------|--------|
| `{file}` | {N} | {date} | {not imported anywhere} |

### Unreachable Routes
| Route | File | Reason |
|-------|------|--------|
| {route} | `{file}` | {no link/navigation points here} |

---

## 13. Security Surface Map (if --full)

### Input Surfaces
| Surface | Type | Validation | Sanitization | File |
|---------|------|-----------|--------------|------|
| {endpoint/form} | {API/form/upload/webhook} | {Y/N — schema} | {Y/N} | `{file}` |

### Auth Boundaries
| Route Pattern | Auth Required | Mechanism | File |
|--------------|--------------|-----------|------|
| {pattern} | {Y/N} | {JWT/session/API key} | `{file}` |

### Data Exposure Points
| Endpoint | Sensitive Fields Returned | Mitigation |
|----------|--------------------------|------------|
| {endpoint} | {fields} | {masked/omitted/none} |

### Missing Protections
{List of identified gaps: no CSRF, no rate limiting, no helmet, etc.}

---

## 14. Complexity Heatmap (if --full)

| Risk | File | Lines | Functions | Avg Complexity | Max Nesting | Flows |
|------|------|-------|-----------|---------------|-------------|-------|
| {indicator} | `{file}` | {N} | {N} | {N} | {N} | {flow IDs} |

{Sorted by composite complexity, top 10% flagged}

---

## 15. User Stories (if --user-stories or --full)

### US-001: {Story Title}
As a **{role}**, I want to **{action}**, so that **{benefit}**.
- Derived from: {FF-NNN, BLF-NNN, API-NNN}
- Acceptance criteria (inferred):
  - {criterion from flow decision points}
  - {criterion from validation rules}
  - {criterion from error handling}
- Priority: {HIGH/MEDIUM/LOW based on risk scores of underlying flows}

---

## 16. Service Map (if --services or --full)

```mermaid
flowchart LR
    subgraph Internal
        SVC-001["{service name} :{port}"]
        SVC-002["{service name}"]
    end
    subgraph External
        EXT-001["{provider}"]
    end
    SVC-001 -->|{protocol}| SVC-002
    SVC-001 -->|{protocol}| EXT-001
```

| SVC ID | Service | Type | Port | Entry Point | Communicates With |
|--------|---------|------|------|-------------|-------------------|
| SVC-001 | {name} | {web/api/worker/scheduler} | {port} | `{file}` | SVC-002, EXT-001 |

---

## 17. Module Dependency Graph (if --deps or --full)

### Circular Dependencies
| Cycle | Files | Severity |
|-------|-------|----------|
| {cycle desc} | `{file A}` <-> `{file B}` | {WARNING/CRITICAL} |

### Coupling Metrics
| Module | Fan-In | Fan-Out | Instability | Assessment |
|--------|--------|---------|-------------|------------|
| {module/} | {N} | {N} | {0.0-1.0} | {stable/unstable} |

### Dependency Diagram
```mermaid
flowchart TD
    {module hierarchy showing imports}
```

---

## 18. Architecture Decisions (if --decisions or --full)

### DEC-001: {Decision Title}
- **Context**: {why this decision was needed}
- **Decision**: {what was chosen}
- **Trade-off**: {what was given up}
- **Source**: `{file:line}` or `{commit hash}` or `{README section}`
- **Date**: {extracted from git log}

---

## 19. Secret & Config Inventory

| Variable | Source File | Scope | Risk Level | Notes |
|----------|-----------|-------|------------|-------|
| {VAR_NAME} | `{file}` | {server-only/client-exposed} | {LOW/MEDIUM/HIGH} | {e.g., "no rotation detected"} |

Secrets in client bundle: {N} (should be 0)
Secrets without rotation: {N}
Missing from .env.example: {N}

---

## 20. Staleness Report (if --validate)

| Flow ID | Source Files | Last Code Change | Record Date | Status |
|---------|-------------|-----------------|-------------|--------|
| {ID} | `{file}` | {date} | {record date} | {Fresh/Stale} |

Staleness: {N}% ({stale}/{total} flows)
Recommendation: {Re-run /healer:record | Record is current}

---

## 21. Cross-Reference Matrix

### 21.1 Flow → File Matrix
| Flow ID | Flow Name | Files |
|---------|-----------|-------|
| {ID} | {name} | `{file1}`, `{file2}`, ... |

### 21.2 File → Flow Matrix
| File | Flows |
|------|-------|
| `{file}` | {ID1}, {ID2}, ... |

### 21.3 Uncovered Areas
{Files that appear in no flow — potential dead code or undiscovered functionality}
```

**ENFORCEMENT: Every field in this output MUST be filled with actual data from the scan. No placeholders. No estimates. No "TODO" markers. If a section has no entries, state "None discovered" — do not omit the section.**

### Step 15: Update State

Write to `.healer/state.json`:

```json
{
  "last_command": "record",
  "status": "completed",
  "suggested_next": "indulge",
  "timestamp": "ISO-8601",
  "record_file": "{output file path}",
  "flows_discovered": N,
  "requirements_extracted": N,
  "layers_scanned": 8,
  "flags_used": ["--full", "--risk", "etc."]
}
```

## Red Flags — STOP and Reassess

```
RED FLAGS:

  STOP if you're about to modify a source file
  → Record is READ-ONLY. You produce a document, not code changes.
  → The ONLY files you create are the output document and optionally CLAUDE.md.

  STOP if you're generating output before finishing the full 8-layer scan
  → Complete Steps 1-12 before starting Step 14. Partial scans = partial records.

  STOP if you're assigning flow IDs non-sequentially or reusing IDs
  → Each category has its own counter. DA-001, DA-002, DA-003. No gaps, no duplicates.

  STOP if you're reading node_modules, .git, or build output
  → Source directories only. These directories contain generated/third-party code.

  STOP if you're recording actual secret values from .env files
  → Record variable NAMES and purposes. NEVER record actual API keys, passwords, or tokens.

  STOP if a section has placeholder text like "{TODO}" or "TBD"
  → Every field gets actual data or "None discovered." No placeholders.

  STOP if you're tracing call chains deeper than 5 levels
  → 5 levels of recursion is the maximum. Beyond that, summarize.

  STOP if you're estimating numbers instead of counting them
  → Run wc -l, grep -c, find | wc -l. Get the actual number. Always.

  STOP if you're about to omit a section because "the app doesn't have that"
  → Include every section. If the app has no state machines, write
     "## 6. State Flows\nNone discovered." Do NOT remove the section.

  STOP if you're writing the Executive Summary before finishing the scan
  → The Executive Summary goes in the output first but is WRITTEN last.
     You need the full picture before you can summarize it.
```

## Anti-Rationalization

| Rationalization | Reality | Correction |
|----------------|---------|------------|
| "I can summarize the app from the README" | READMEs are often outdated, incomplete, or aspirational. The CODE is the truth. | Read the actual source files. The record documents what IS, not what should be. |
| "This directory probably doesn't have anything important" | "Probably" is not a scan. Open it. List the files. Read the significant ones. | Scan every source directory. Let the evidence decide importance. |
| "I already know what this framework does" | You know the framework. You don't know what THIS app does with it. | Read the actual implementation. Every app is different. |
| "The DB schema is straightforward, I can skim it" | Skimming misses constraints, indexes, RLS policies, and edge-case columns. | Read every migration, every model, every schema file completely. |
| "There are too many components to list them all" | The record is comprehensive BY DESIGN. List them all. That's the point. | If the app has 200 components, the record has 200 CP-NNN entries. Scope with flags if needed. |
| "This test file is just boilerplate" | Test descriptions ARE requirements. Every `it('should...')` is a behavior the app claims to have. | Extract every test description. Map it to a flow. |
| "The design tokens are obvious from looking at the UI" | "Obvious" means you guessed. Extract them from config files and stylesheets. | Read tailwind.config, CSS variables, theme files. Document what's defined, not what you infer. |
| "I don't need to trace the full call chain" | Partial traces miss dead code, broken wiring, and unexpected detours. | Trace to 5 levels. That's the rule. |
| "This integration is self-explanatory" | Every integration has auth, error handling, retry logic, and config. Document all of it. | Record the provider, auth mechanism, error handling, and every file that touches it. |
| "I'll add the cross-reference matrix later" | The matrix IS the value. It connects everything. Without it, you have a list, not a record. | Build the matrix as you discover flows. It's not optional. |
| "The output file is getting too long" | Long is correct. The record is comprehensive. Use --summary if the user wants brevity. | Keep writing. The full record has no length limit. Use scoping flags if needed. |
| "I can skip the risk scoring since it's a 10x feature" | If the user passed --risk or --full, they asked for it. Deliver it. | Check the flags. If enabled, calculate every score. |

## Rules

1. **Read-only** — never modify source files. Output document and optional CLAUDE.md only
2. **Complete scan first** — all 8 layers read before any output generation
3. **Every flow gets an ID** — DA-NNN, API-NNN, BLF-NNN, CF-NNN, SF-NNN, CP-NNN, INT-NNN, FF-NNN, DL-NNN
4. **No placeholders** — every field is actual data or "None discovered"
5. **Source directories only** — never read node_modules, .git, dist, build, .next, __pycache__, target
6. **Max 5-level trace depth** — summarize beyond 5 levels of call chain recursion
7. **Never record secrets** — variable names and purposes only, never actual values
8. **Executive Summary is written last** — it requires the full picture from all layers
9. **Cross-reference matrix is mandatory** — Flow-to-File and File-to-Flow, always
10. **All sections present** — even empty sections appear with "None discovered"
11. **Single file output** — `{AppName}_Business_Flows_Helper_{MMDDYYYY}.md`
12. **Flags control 10x features** — base features always on, 10x features only when flagged
13. **Evidence-based counts** — run wc -l, grep -c, find | wc -l for actual numbers, never estimate
14. **Update state** — always write to .healer/state.json when done
15. **Scoping respects boundaries** — --backend-only, --frontend-only, --design-only, and module scoping reduce scan surface
16. **Previous record required for --diff** — if no previous record exists, warn and skip the diff
17. **CLAUDE.md is condensed** — the --claude-md output is a summary, not a copy of the full record
18. **OpenAPI spec is standards-compliant** — the --openapi output must be valid OpenAPI 3.0 YAML
