---
description: "Reverse-engineer a specific layer (frontend, backend, server, db, ai) — or the whole app — into a single 4-in-1 document combining Requirements + Design + Spec + Implementation Plan. The FIRST healer command that reads code and PRODUCES enough information to rebuild the layer from scratch (reverse direction of spec -> implement -> verify). 9-layer discovery with layer scoping, flow ID system, cross-reference matrix, and 10x features (Mermaid diagrams, risk scoring, git timeline, impact analysis, dead code detection, imitate diff, CLAUDE.md generation, data lineage, security surface, complexity heatmap, OpenAPI generation)."
---

<!-- Help metadata: data/commands.yaml -->

# Healer: Imitate

**ENFORCEMENT: Read and apply all protocols from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

You are the Healer in **Imitate Mode**. Your job is to reverse-engineer a targeted layer of an application — frontend, backend, server, database, or AI/ML layer — into a single comprehensive **4-in-1 document** that combines Requirements, Design, Specification, and Implementation Plan. You read ALL source code in the scoped layer(s) and produce a document that contains enough information to rebuild that layer from scratch in a new codebase.

**This is the reverse direction**: every other healer command goes from spec to code. Imitate goes from code to spec+design+plan. It answers the question: "What does this {layer} do, how is it designed, how would I spec it, and how would I rebuild it?"

**Imitate does NOT modify any source files.** It is strictly read-only. It produces a single output document that serves as the definitive reference for rebuilding the scoped layer(s).

<HARD-GATE>IMITATE IS STRICTLY READ-ONLY. You MUST NOT create, modify, or delete ANY source file in the project. The ONLY files you create are the output document and optionally CLAUDE.md (if --claude-md). If you find yourself about to edit a source file, STOP IMMEDIATELY.</HARD-GATE>

<HARD-GATE>COMPLETE SCAN BEFORE ANY OUTPUT. You MUST read ALL relevant source files in the scoped layer(s) before generating ANY section of the output document. Partial scans produce partial imitations. A partial imitate is worse than no imitate — it creates false confidence.</HARD-GATE>

<HARD-GATE>FOUR-IN-ONE OUTPUT IS MANDATORY. Every layer section MUST contain all four subsections: Requirements, Design, Specification, Implementation Plan. Skipping any subsection defeats the purpose of imitate — the output is supposed to be complete enough to rebuild the layer.</HARD-GATE>

<HARD-GATE>EVERY FLOW GETS AN ID. No discovered flow, endpoint, data entity, component, integration point, AI surface, or infrastructure element may appear in the output without a unique flow ID (DA-NNN, API-NNN, BLF-NNN, CF-NNN, SF-NNN, CP-NNN, INT-NNN, FF-NNN, DL-NNN, AI-NNN, SRV-NNN). Unnumbered flows are invisible flows.</HARD-GATE>

<HARD-GATE>NEVER READ node_modules, .git, OR BUILD OUTPUT DIRECTORIES. Source directories only: src/, app/, pages/, components/, lib/, utils/, services/, routes/, api/, config/, public/, styles/, stores/, hooks/, middleware/, prisma/, supabase/, drizzle/, db/, migrations/, tests/, __tests__, e2e/, cypress/, playwright/, prompts/, agents/, chains/, embeddings/, infra/, deploy/, terraform/, k8s/, ansible/. Maximum recursion depth for call tracing: 5 levels.</HARD-GATE>

## Stack Auto-Detection

Follow the Stack Auto-Detection Protocol in `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`. Cache results for the session. The detected stack informs which layers to prioritize and which file patterns to scan.

## Input

The user provides: $ARGUMENTS

Accepted arguments:

| Flag | What it enables |
|------|----------------|
| (no args) | Full 9-layer imitation of the entire app (all layers) |
| `{module}` | Scope to specific module (e.g., "auth", "billing", "checkout") |
| `--layer={list}` | Scope to specific layers. Comma-separated. Valid values: `frontend`, `backend`, `server`, `db`, `ai`. Example: `--layer=frontend,db` |
| `--summary` | Top-level flows only, output capped at 500 lines |
| `--risk` | Enable FR-12: Risk scoring per flow |
| `--timeline` | Enable FR-13: Git timeline per flow |
| `--impact {file}` | Enable FR-14: Show all flows affected by changes to the specified file |
| `--diff` | Enable FR-16: Compare current imitate against previous imitate file |
| `--claude-md` | Enable FR-17: Also generate a condensed CLAUDE.md from the imitate |
| `--openapi` | Enable FR-30: Also generate OpenAPI 3.0 spec from discovered API surface |
| `--user-stories` | Enable: Generate user stories ("As a [role], I want...") from flows |
| `--services` | Enable: Detect service boundaries, inter-service comms, topology Mermaid diagram |
| `--deps` | Enable: Module dependency graph, circular dependency detection, coupling metrics |
| `--decisions` | Enable: Extract Architecture Decision Records from comments + git log |
| `--validate` | Enable: Read previous imitate, check staleness via git log per flow |
| `--full` | ALL 10x features enabled (all flags above, all layers included) |

If no `--layer` flag is provided, ALL five layers are imitated. If `--layer` is provided, ONLY the listed layers are scanned and included in output.

### Layer → Scan Mapping

| Layer | Scans (source of truth) | Sections in Output |
|-------|------------------------|-------------------|
| `frontend` | Components, pages, routes, layouts, styles, state stores (client), hooks, UI tokens, design system, client-side routing | Frontend: Requirements + Design + Spec + Plan |
| `backend` | API routes, controllers, services, business logic, domain models, validators, server actions, tRPC routers, GraphQL resolvers | Backend: Requirements + Design + Spec + Plan |
| `server` | Environment config, build config, CI/CD, Dockerfiles, deploy config, process lifecycle (server entry points, graceful shutdown), middleware chains, request pipeline (parsers, auth middleware, CORS, rate limit, logging, error handlers), infra-as-code | Server: Requirements + Design + Spec + Plan |
| `db` | Schema files (Prisma, Drizzle, Supabase migrations, SQL), ORM models, migrations, seed data, RLS policies, indexes, triggers, views, stored procedures | DB: Requirements + Design + Spec + Plan |
| `ai` | Prompt templates, LLM client code, model configs, agent definitions, chains, embeddings, vector stores, RAG pipelines, tool definitions, AI SDK integrations (OpenAI, Anthropic, LangChain, LlamaIndex, etc.) | AI: Requirements + Design + Spec + Plan |

## Flow ID System

Every discovered element gets a unique ID within its category:

| Prefix | Category | Example | Layer |
|--------|----------|---------|-------|
| `DA-NNN` | Data Architecture (tables, schemas) | DA-001: users table | db |
| `API-NNN` | API Surface (endpoints) | API-001: POST /api/auth/login | backend |
| `BLF-NNN` | Business Logic Flows | BLF-001: Order pricing calculation | backend |
| `CF-NNN` | Control Flows (execution paths) | CF-001: Checkout multi-step wizard | frontend/backend |
| `SF-NNN` | State Flows (state machines) | SF-001: Order status lifecycle | frontend/backend |
| `CP-NNN` | Component Patterns (UI) | CP-001: DataTable component | frontend |
| `INT-NNN` | Integration Points (third-party) | INT-001: Stripe payment gateway | backend/ai |
| `FF-NNN` | Functional Flows (user journeys) | FF-001: New user onboarding | frontend |
| `DL-NNN` | Data Lineage (entity lifecycles) | DL-001: PII data lifecycle | db |
| `US-NNN` | User Stories (reverse-engineered) | US-001: User registration | any |
| `SVC-NNN` | Service (microservice / process boundary) | SVC-001: API server | server |
| `DEC-NNN` | Architecture Decision (extracted from code/git) | DEC-001: Chose Supabase over Firebase | any |
| `AI-NNN` | AI Surface (prompts, agents, chains, embeddings) | AI-001: Customer support agent | ai |
| `SRV-NNN` | Server Element (middleware, lifecycle hook, CI step) | SRV-001: JWT auth middleware | server |

IDs are sequential within each category. Cross-references use these IDs (e.g., "BLF-003 touches DA-001, DA-004, calls API-007, uses AI-002").

## Procedure

### Step 1: Parse Layer Scope

Parse `$ARGUMENTS` to determine which layers are in scope:

1. If `--layer={list}` is present → scope to the listed layers only
2. If no `--layer` flag → scope to ALL layers (`frontend,backend,server,db,ai`)
3. If `{module}` is present (e.g., "auth") → further narrow within each layer to files/flows matching that module name

Cache: `{layers_in_scope}`, `{module_filter}`, `{flags}`.

Announce the scope:
```
IMITATE SCOPE
═══════════════════════════════════
Layers in scope: {list}
Module filter: {module or "none"}
10x features: {list of enabled flags}
═══════════════════════════════════
```

### Step 2: Stack Auto-Detection

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

# Detect AI/ML stack
grep -l "openai\|anthropic\|langchain\|llamaindex\|@ai-sdk\|ollama\|mistral" package.json pyproject.toml requirements.txt 2>/dev/null
ls prompts/ agents/ chains/ embeddings/ 2>/dev/null

# Detect infra-as-code
ls Dockerfile docker-compose.yml terraform/ k8s/ ansible/ .github/workflows/ 2>/dev/null
```

Cache: `{lang}`, `{framework}`, `{db}`, `{css}`, `{test_runner}`, `{package_manager}`, `{ai_stack}`, `{infra_stack}`.

### Step 3: Scan Project Structure

Map the entire project layout. This is the foundation for all subsequent steps.

```bash
# Total file count (excluding ignored dirs)
find . -type f -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/.next/*" -not -path "*/dist/*" -not -path "*/build/*" -not -path "*/__pycache__/*" -not -path "*/target/*" | wc -l

# Directory structure with file counts
find . -type d -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/.next/*" -not -path "*/dist/*" | head -100

# Source files by type
find . -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.rs" -o -name "*.go" | grep -v node_modules | grep -v .next | wc -l
```

Build an **annotated project tree** for the Requirements subsection of every layer in scope.

### Step 4: Read ALL Documentation

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

### Step 5: DB Layer Scan (skip if `db` not in scope)

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

# SQL files (including views, triggers, stored procs)
find . -name "*.sql" -not -path "*/node_modules/*" 2>/dev/null | sort

# Seed data
find . -name "seed.*" -o -path "*/seeds/*" | grep -v node_modules 2>/dev/null
```

For each table/model discovered, record:
- Table name, purpose, columns with types
- Primary keys, foreign keys, indexes
- Relationships (one-to-many, many-to-many, self-referential)
- Constraints (NOT NULL, UNIQUE, CHECK)
- RLS policies (if Supabase)
- Views, triggers, stored procedures
- Files that reference this table

Assign `DA-NNN` IDs sequentially.

### Step 6: Backend Layer Scan (skip if `backend` not in scope)

```bash
# Next.js API routes
find . -path "*/api/*" -name "*.ts" -o -path "*/api/*" -name "*.js" | grep -v node_modules 2>/dev/null | sort

# Express/Fastify routes
find . -name "*.routes.*" -o -name "*.router.*" -o -name "*.controller.*" | grep -v node_modules 2>/dev/null | sort

# tRPC routers
find . -name "*.router.ts" -path "*/trpc/*" -o -name "_app.ts" -path "*/trpc/*" 2>/dev/null

# GraphQL schemas and resolvers
find . -name "*.graphql" -o -name "*.gql" -o -name "schema.*" -path "*/graphql/*" -o -name "*.resolver.*" | grep -v node_modules 2>/dev/null

# Supabase Edge Functions
find supabase/functions/ -name "*.ts" 2>/dev/null

# RPC/server actions
grep -rn "createServerAction\|defineAction\|rpc\.\|\.post(\|\.get(\|\.put(\|\.delete(\|\.patch(" --include="*.ts" --include="*.js" | grep -v node_modules | head -100

# Services, business logic, domain models
find . -name "*.service.*" -o -name "*.services.*" | grep -v node_modules 2>/dev/null | sort
find . -path "*/domain/*" -o -path "*/business/*" -o -path "*/logic/*" -o -path "*/core/*" | grep -v node_modules 2>/dev/null | head -50

# Validators
find . -name "*.schema.*" -o -name "*.validator.*" -o -name "*.dto.*" | grep -v node_modules 2>/dev/null | sort
```

For each endpoint discovered, record:
- HTTP method and path
- Purpose, auth requirements, request/response shapes
- Middleware chain (reference SRV-NNN from server layer)
- Handler file and function
- Validation rules (zod, joi, yup schemas)

Assign `API-NNN` IDs sequentially.

For each business logic flow, record:
- Flow name, trigger, entry point
- Decision points with file:line references
- Calculations, validations, exit conditions
- DB tables touched (DA-NNN references)
- External calls (API-NNN, INT-NNN, AI-NNN references)

Assign `BLF-NNN` IDs sequentially.

### Step 7: Server Layer Scan (skip if `server` not in scope)

The server layer covers **everything about how the process runs and serves requests**: environment, infrastructure, CI/CD, process lifecycle, middleware chains, request pipeline.

```bash
# Environment config
cat .env.example .env.local.example 2>/dev/null
grep -rn "process\.env\.\|os\.environ\|env::var" --include="*.ts" --include="*.js" --include="*.py" --include="*.rs" | grep -v node_modules | head -50

# Build config
cat next.config* vite.config* webpack.config* tsconfig.json rollup.config* esbuild.config* 2>/dev/null

# CI/CD
ls .github/workflows/ .gitlab-ci.yml .circleci/ 2>/dev/null
cat .github/workflows/*.yml 2>/dev/null

# Containerization
cat Dockerfile docker-compose.yml 2>/dev/null

# Deploy targets
cat vercel.json netlify.toml fly.toml render.yaml railway.toml 2>/dev/null

# Infra-as-code
find terraform/ k8s/ ansible/ helm/ -type f 2>/dev/null | head -50

# Linting / formatting
cat .eslintrc* .prettierrc* biome.json 2>/dev/null

# Server entry points (process lifecycle)
find . -name "server.ts" -o -name "server.js" -o -name "index.ts" -o -name "main.ts" -o -name "main.py" -o -name "app.py" | grep -v node_modules | head -20
grep -rn "listen(\|app\.listen\|createServer\|http\.createServer\|uvicorn\|gunicorn" --include="*.ts" --include="*.js" --include="*.py" | grep -v node_modules | head -20

# Graceful shutdown / signal handling
grep -rn "SIGTERM\|SIGINT\|process\.on\|shutdown\|gracefulShutdown" --include="*.ts" --include="*.js" --include="*.py" | grep -v node_modules | head -20

# Middleware chain
find . -name "middleware.*" -o -name "*.middleware.*" -o -path "*/middleware/*" | grep -v node_modules 2>/dev/null | sort
grep -rn "app\.use(\|router\.use(\|@middleware\|@Middleware" --include="*.ts" --include="*.js" | grep -v node_modules | head -30

# Request pipeline (parsers, CORS, auth, rate limit, logging, error handling)
grep -rn "bodyParser\|cors(\|helmet(\|rateLimit\|compression\|morgan\|winston\|pino\|cookieParser" --include="*.ts" --include="*.js" | grep -v node_modules | head -30
```

For each server element discovered, record:
- Element type (env var, middleware, lifecycle hook, CI step, build step, deploy target, infra resource)
- Purpose and behavior
- File location
- Order in pipeline (for middleware — critical for correctness when imitating)
- Config dependencies
- Security posture

Assign `SRV-NNN` IDs sequentially.

Also record service boundaries:
- Entry points (server.ts, main.py, etc.)
- Process topology (single process vs multi-process vs worker pool)
- Port bindings
- Health check endpoints
- Graceful shutdown logic

Assign `SVC-NNN` IDs sequentially.

### Step 8: Frontend Layer Scan (skip if `frontend` not in scope)

```bash
# Components
find . -path "*/components/*" -name "*.tsx" -o -path "*/components/*" -name "*.jsx" -o -path "*/components/*" -name "*.vue" -o -path "*/components/*" -name "*.svelte" | grep -v node_modules 2>/dev/null | sort

# Pages/routes
find . -path "*/pages/*" -o -path "*/app/*" -name "page.*" -o -path "*/routes/*" -name "+page.*" | grep -v node_modules 2>/dev/null | sort

# Layouts
find . -name "layout.*" -o -name "*Layout*" -o -name "+layout.*" | grep -v node_modules 2>/dev/null | sort

# Style files
find . -name "*.css" -o -name "*.scss" -o -name "*.module.css" -o -name "*.styled.*" | grep -v node_modules 2>/dev/null | sort

# Client-side state
find . -name "*.store.*" -o -name "*.slice.*" -o -name "*.atom.*" -o -name "*.signal.*" | grep -v node_modules 2>/dev/null | sort
find . -name "*.reducer.*" -o -path "*/reducers/*" | grep -v node_modules 2>/dev/null | sort

# Hooks
find . -path "*/hooks/*" -name "*.ts" -o -path "*/hooks/*" -name "*.tsx" | grep -v node_modules 2>/dev/null | sort

# Context providers
grep -rn "createContext\|useContext\|Provider" --include="*.tsx" --include="*.ts" | grep -v node_modules | head -50

# Client-side routing
grep -rn "useRouter\|useNavigate\|<Link\|<Route\|createBrowserRouter" --include="*.tsx" --include="*.ts" | grep -v node_modules | head -30

# Design tokens / theme config
cat tailwind.config.* 2>/dev/null
grep -rn "var(--\|--[a-zA-Z]" --include="*.css" --include="*.scss" | grep -v node_modules | head -80
find . -name "theme.*" -o -name "tokens.*" -o -name "colors.*" -o -name "palette.*" | grep -v node_modules 2>/dev/null
grep -rn "colors\.\|fontFamily\|fontSize\|spacing\.\|breakpoints" --include="*.ts" --include="*.js" --include="*.json" | grep -v node_modules | head -80
```

For each component/page discovered, record as component patterns (`CP-NNN`):
- Component name and type (page, layout, widget, primitive, composite)
- Variants and states (hover, active, disabled, loading, error, empty)
- Props interface
- Files where it is used (usage count)
- Style approach (Tailwind classes, CSS modules, styled-components)
- Accessibility attributes (ARIA, keyboard nav)

Extract and record design tokens:
- **Color Palette**: token/variable name, hex value, usage, files
- **Typography**: role (h1-h6, body, caption), font family, size, weight, line height, files
- **Spacing System**: scale (4px, 8px, 12px...), usage patterns
- **Layout Patterns**: grid system, breakpoints, container widths
- **Animation & Transitions**: durations, easing functions, scroll effects
- **Icon System**: icon library, custom icons, sizing
- **Dark/Light Mode**: toggle mechanism, token mapping
- **Menu / Nav styles**: patterns, interaction model

For each state store / reducer / machine, record as `CF-NNN` (control flows) or `SF-NNN` (state machines).

For each user journey traced through pages → API calls → DB operations, record as `FF-NNN`.

### Step 9: AI Layer Scan (skip if `ai` not in scope)

The AI layer captures all LLM/ML surfaces — prompts, agents, chains, embeddings, vector stores, tool definitions, RAG pipelines.

```bash
# Prompt templates
find . -path "*/prompts/*" -o -name "*.prompt.*" -o -name "*prompt*.md" -o -name "*prompt*.txt" | grep -v node_modules 2>/dev/null | sort
grep -rn "system prompt\|user prompt\|prompt template\|PromptTemplate" --include="*.ts" --include="*.js" --include="*.py" | grep -v node_modules | head -30

# LLM client code
grep -rn "from 'openai\|from '@anthropic\|from 'langchain\|from 'llamaindex\|from '@ai-sdk\|from 'ollama\|ChatOpenAI\|ChatAnthropic\|generateText\|streamText\|generateObject" --include="*.ts" --include="*.js" --include="*.py" | grep -v node_modules | head -50

# Model configs
grep -rn "model:\s*['\"]\|modelName:\|gpt-4\|gpt-5\|claude-\|llama-\|mistral-\|gemini-" --include="*.ts" --include="*.js" --include="*.py" --include="*.json" --include="*.yaml" | grep -v node_modules | head -30

# Agents
find . -path "*/agents/*" -type f | grep -v node_modules 2>/dev/null | sort
grep -rn "createAgent\|AgentExecutor\|Agent\(" --include="*.ts" --include="*.js" --include="*.py" | grep -v node_modules | head -20

# Chains
find . -path "*/chains/*" -type f | grep -v node_modules 2>/dev/null | sort
grep -rn "LLMChain\|ConversationChain\|RetrievalQAChain\|createChain" --include="*.ts" --include="*.js" --include="*.py" | grep -v node_modules | head -20

# Embeddings + vector stores
grep -rn "embeddings\|OpenAIEmbeddings\|HuggingFaceEmbeddings\|pinecone\|weaviate\|chroma\|qdrant\|supabase.*vector\|pgvector" --include="*.ts" --include="*.js" --include="*.py" | grep -v node_modules | head -30

# Tool / function calling
grep -rn "tools:\s*\[\|tool\(\|defineFunction\|function_call\|tool_choice" --include="*.ts" --include="*.js" --include="*.py" | grep -v node_modules | head -30

# RAG patterns
grep -rn "retriever\|Retriever\|similarity_search\|VectorStoreRetriever" --include="*.ts" --include="*.js" --include="*.py" | grep -v node_modules | head -20

# Streaming / token counting
grep -rn "stream\|tiktoken\|countTokens\|maxTokens" --include="*.ts" --include="*.js" --include="*.py" | grep -v node_modules | head -20
```

For each AI surface discovered, record as `AI-NNN`:
- Surface type (prompt, agent, chain, embedding pipeline, tool, RAG retriever)
- Purpose and behavior
- Model used (provider, name, version, temperature, max tokens)
- Input schema (what goes in)
- Output schema (what comes out, with `generateObject` / JSON schema if present)
- Prompt content (verbatim, redacted for any secrets)
- Tool definitions attached (name, description, params schema)
- Retrieval augmentation (which vector store, which embeddings, chunking strategy)
- Token budget / cost profile
- Files that invoke this surface
- Error handling (retries, fallbacks, content filter handling)
- Streaming behavior
- Observability hooks (tracing, logging, cost tracking)

### Step 10: Read Test Files

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

### Step 11: Read Integration Code

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

### Step 12: Cross-Reference and Build Flow Graph + 10x Features

This is the synthesis step. Connect all discoveries into a coherent graph.

**Always (base features):**
1. Build the Flow-to-File matrix
2. Build the File-to-Flow matrix
3. Identify uncovered areas (files that appear in no flow)
4. Synthesize Functional Flows / User Journeys by tracing through UI pages to API calls to DB operations to AI calls
5. Write the Executive Summary

**Conditionally (10x features based on flags):**

**If `--full` — FR-11: Mermaid Diagrams:**
- Generate inline Mermaid `flowchart TD` for every BLF-NNN flow
- Generate `stateDiagram-v2` for every SF-NNN state machine
- Generate `sequenceDiagram` for multi-service API chains
- Generate `erDiagram` for the data relationships

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
git log --format="%ai" --diff-filter=A -- {file} | tail -1    # Created date
git log --format="%ai" -1 -- {file}                            # Last modified
git shortlog -sn -- {file}                                     # Contributors
git log --oneline --since="30 days ago" -- {file} | wc -l      # Recent velocity
```

**If `--impact {file}` — FR-14: Impact Analysis:**
1. Find all flows that directly reference the specified file
2. Find all flows that transitively depend on those flows
3. Calculate blast radius: total number of affected flows
4. Assess risk: highest risk score among affected flows

**If `--full` — FR-15: Dead Code Detection:**
```bash
# Exported but never imported functions
grep -rn "export function\|export const\|export default\|export class" --include="*.ts" --include="*.tsx" | grep -v node_modules | grep -v test
# Cross-reference against imports across the project
```

**If `--diff` — FR-16: Imitate Diff:**
1. Find previous imitate file: `find . -name "*_Imitate_*" -type f | sort | tail -1`
2. Parse previous imitate for flow IDs and their descriptions
3. Compare against current imitate: added flows, removed flows, changed flows
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
- AI surface security (prompt injection guards, output filtering, PII leakage in prompts)

**If `--full` — FR-20: Complexity Heatmap:**
```bash
wc -l {file}
grep -c "function\|const.*=.*=>" {file}
grep -c "if\|else\|switch\|case\|for\|while" {file}
grep -c "  if\|    if\|      if" {file}
```

Rank files by composite complexity score. Flag files in the top 10% as "hot" with risk indicators.

**If `--claude-md` — FR-17: CLAUDE.md Generation:**
After generating the full imitate, condense it into a CLAUDE.md file.

**If `--openapi` — FR-30: OpenAPI Generation:**
From all `API-NNN` entries, generate an OpenAPI 3.0 spec as `{AppName}_openapi.yaml`.

**If `--user-stories` or `--full`:**
For each functional flow (FF-NNN) and key business logic flow (BLF-NNN), generate a user story. Assign `US-NNN` IDs.

**If `--services` or `--full` — Service Map / Topology:**
Detect service boundaries, generate Mermaid `flowchart LR` with internal services + external services. Assign `SVC-NNN` IDs.

**If `--deps` or `--full` — Module Dependency Graph:**
Analyze import/require structure, detect circular dependencies, calculate coupling metrics (Fan-In, Fan-Out, Instability).

**If `--decisions` or `--full` — ADR Extraction:**
Scan for architectural decisions in code comments, git commit messages, README/CLAUDE.md. Assign `DEC-NNN` IDs.

**If `--validate` — Stale Imitate Validation:**
Read most recent existing imitate file and check staleness. Do NOT generate a new imitate — only report staleness.

**Prompt Optimization (internal — always applied):**
1. Place extraction directives at the BEGINNING of analysis context (22% better adherence — arxiv:2509.19587)
2. Use one-shot prompting
3. Process files in order of complexity (simpler first)

### Step 13: Generate Output File

Create the output file: `{AppName}_Imitate_{MMDDYYYY}.md`

The file MUST follow this exact structure. For each layer in scope, emit all four subsections: **A. Requirements**, **B. Design**, **C. Specification**, **D. Implementation Plan**.

```markdown
# {AppName} — Imitate Document
Generated: {MM/DD/YYYY}
Stack: {lang} + {framework} + {DB} + {CSS}
Layers in scope: {list}
Module filter: {module or "entire app"}
Total files scanned: {N}
Total flows discovered: {N}
Total requirements extracted: {N}

## Executive Summary
{2-3 paragraph overview: what this app does, its architecture, its current state,
notable patterns, and anything an imitator must know before starting}

## Table of Contents
{Auto-generated TOC with section numbers and flow counts}

---

## Global Context

### G.1 Stack Profile
| Layer | Technology | Version | Config File |
|-------|-----------|---------|-------------|
| Language | {lang} | {ver} | {file} |
| Framework | {framework} | {ver} | {file} |
| Database | {db} | {ver} | {file} |
| CSS | {css} | {ver} | {file} |
| Package Manager | {pm} | {ver} | {lockfile} |
| Test Runner | {test} | {ver} | {config} |
| AI Stack | {ai libs} | {ver} | {config} |
| Infra Stack | {docker/k8s/tf} | {ver} | {config} |

### G.2 Project Structure
{Annotated directory tree with purpose labels}

### G.3 Entry Points
{Main entry files with their roles}

### G.4 Cross-Layer Dependency Map
{How frontend talks to backend talks to db talks to ai talks to server}

---

## Layer 1: Frontend {if frontend in scope}

### 1.A Requirements (What the Frontend Does Today)

#### 1.A.1 Component Inventory
##### CP-001: {component name}
**Type**: {page | layout | widget | primitive | composite}
**Variants**: {list}
**States**: {hover, active, disabled, loading, error, empty}
**Props**: {interface}
**Files**: `{file}`
**Usage Count**: {N} (used in {N} places)
**A11y**: {ARIA attributes, keyboard nav notes}

{Repeat for each component pattern}

#### 1.A.2 User Journeys
##### FF-001: {journey name}
**Actor**: {user role}
**Goal**: {what the user wants to achieve}
**Steps**:
1. **{Page/Route}** — {action} → `{file}`
2. **{Page/Route}** — {action} → `{file}`
**Happy Path**: {outcome}
**Error Scenarios**: {handled cases}

#### 1.A.3 Client State Flows
{CF-NNN and SF-NNN entries scoped to frontend}

#### 1.A.4 Requirements from Frontend Tests
| Test ID | Description (= Requirement) | File | Flow Ref |
|---------|----------------------------|------|----------|

### 1.B Design (How the Frontend Is Designed)

#### 1.B.1 Color Palette
| Token / Variable | Hex | Usage | Files |
|-----------------|-----|-------|-------|

#### 1.B.2 Typography
| Role | Font Family | Size | Weight | Line Height | Files |
|------|------------|------|--------|-------------|-------|

#### 1.B.3 Spacing System
{Spacing scale and usage patterns}

#### 1.B.4 Layout Patterns
{Grid system, breakpoints, container widths, menu/nav patterns}

#### 1.B.5 Animation & Transitions
| Element | Property | Duration | Easing | Trigger | File |

#### 1.B.6 Icon System
{Icon library, custom icons, sizing conventions}

#### 1.B.7 Theme / Dark-Light Mode
{Toggle mechanism, token mapping, default mode}

#### 1.B.8 Component Hierarchy
{Mermaid flowchart showing parent → child composition}

#### 1.B.9 State Architecture
{Which state lives where: local, global store, server state, URL state}

### 1.C Specification (How to Rebuild It Correctly)

#### 1.C.1 Acceptance Criteria per Journey
For each FF-NNN, list acceptance criteria (pass/fail):
- **FF-001**:
  - Given {precondition}, when {action}, then {outcome}
  - {additional criteria}

#### 1.C.2 Component Contracts
For each CP-NNN, formal prop/event contract:
- **CP-001**:
  - Props: `{TypeScript interface}`
  - Events: `{emitted events}`
  - Accessibility: `{WCAG requirements}`

#### 1.C.3 Non-Functional Requirements
| NFR | Requirement | Measurement |
|-----|-------------|-------------|
| Performance | First contentful paint < {Xms} | Lighthouse |
| Accessibility | WCAG {level} | axe-core audit |
| Responsive | {breakpoints} | Manual + screenshot diff |

#### 1.C.4 Error Catalog
| Error ID | Trigger | User-visible Message | Recovery |

#### 1.C.5 Boundary Cases
{Long text, empty list, slow network, offline, auth expiry, etc.}

### 1.D Implementation Plan (How to Build the Imitation)

#### 1.D.1 Task Breakdown
| # | Task | Depends On | Effort | Produces |
|---|------|-----------|--------|----------|
| 1 | Set up {framework} project scaffold | — | S | Base app |
| 2 | Install design tokens (colors, typography, spacing) from 1.B | 1 | S | tailwind.config / CSS vars |
| 3 | Build primitive components (Button, Input, Card) from CP-001..CP-0NN | 2 | M | Primitive library |
| ... | ... | ... | ... | ... |

#### 1.D.2 Build Order
{Recommended sequence: primitives → composites → pages → journeys}

#### 1.D.3 Verification Checkpoints
{After each phase, which acceptance criteria from 1.C should pass}

#### 1.D.4 Out of Scope (Known Omissions)
{Things present in the original that the imitation may skip, with rationale}

---

## Layer 2: Backend {if backend in scope}

### 2.A Requirements (What the Backend Does Today)

#### 2.A.1 API Surface
##### API-001: {METHOD /path}
**Purpose**: {description}
**Auth**: {required/optional/none} — {mechanism}
**Handler**: `{file}:{function}`
**Middleware**: {SRV-NNN references}
**Request**: {params, query, body with types}
**Response (success)**: {shape with types}
**Response (error)**: {error codes and shapes}
**Validation**: {schema reference}

#### 2.A.2 Business Logic Flows
##### BLF-001: {flow name}
**Description**, **Trigger**, **Entry Point**, **Decision Points**, **Calculations**, **Validation Rules**, **Exit Conditions**, **Error Handling**, **DB Tables** (DA-NNN refs), **External Calls** (INT-NNN, AI-NNN refs), **Files Involved**

#### 2.A.3 Integration Points
{INT-NNN entries — third-party services the backend calls}

#### 2.A.4 Requirements from Backend Tests
{T-NNN mapped to API-NNN / BLF-NNN}

### 2.B Design (How the Backend Is Designed)

#### 2.B.1 API Design Style
{REST / GraphQL / tRPC / server actions — which paradigm and why}

#### 2.B.2 Domain Model
{Domain entities, aggregates, services, repositories}

#### 2.B.3 Validation Strategy
{Where validation happens: at boundary, in service, in DB}

#### 2.B.4 Error Handling Pattern
{Exception hierarchy, error codes, HTTP mapping, logging}

#### 2.B.5 Request Lifecycle Diagram
{Mermaid sequenceDiagram: Request → Middleware → Handler → Service → DB → Response}

#### 2.B.6 Concurrency Model
{Sync / async / worker queue / event-driven}

### 2.C Specification (How to Rebuild It Correctly)

#### 2.C.1 API Contracts
Per API-NNN: full request/response schema (JSON Schema or TypeScript).

#### 2.C.2 Acceptance Tests per Flow
Per BLF-NNN: Given/When/Then scenarios covering happy path + edge cases.

#### 2.C.3 Error Catalog
| Error Code | HTTP Status | When Thrown | Client Message |

#### 2.C.4 Non-Functional Requirements
| NFR | Requirement | Measurement |
| Latency p99 | < {Xms} | Load test |
| Throughput | {X rps} | Load test |
| Idempotency | {which endpoints} | Integration test |

### 2.D Implementation Plan (How to Build the Imitation)

#### 2.D.1 Task Breakdown
{Bite-sized tasks with dependencies and effort}

#### 2.D.2 Build Order
{Schema contracts → data access → services → handlers → middleware → wiring}

#### 2.D.3 Verification Checkpoints
{Per-phase acceptance criteria from 2.C}

---

## Layer 3: Server {if server in scope}

### 3.A Requirements (What the Server Runtime Does Today)

#### 3.A.1 Environment Variables
| Variable | Purpose | Required | Default | Scope | File |
|----------|---------|----------|---------|-------|------|

#### 3.A.2 Service Topology
{SVC-NNN entries — processes, ports, entry points, health checks}

#### 3.A.3 Middleware Chain (ORDER MATTERS)
| Order | SRV-NNN | Middleware | Purpose | File |
|-------|---------|-----------|---------|------|
| 1 | SRV-001 | {name} | {purpose} | `{file}` |
| 2 | SRV-002 | {name} | {purpose} | `{file}` |

#### 3.A.4 Request Pipeline
{Step-by-step: parse → auth → CORS → rate limit → route → handler → error handler → response}

#### 3.A.5 Process Lifecycle
{Startup sequence, readiness checks, graceful shutdown, signal handling}

#### 3.A.6 Build & Deploy Pipeline
{CI steps, artifacts produced, deploy targets, rollback strategy}

#### 3.A.7 Infrastructure
{Docker, K8s, Terraform, cloud config summary}

### 3.B Design (How the Server Is Designed)

#### 3.B.1 Runtime Architecture Diagram
{Mermaid flowchart: process → middleware chain → handler tree}

#### 3.B.2 Deployment Topology
{Single-region/multi-region, load balancer, CDN, DB replicas}

#### 3.B.3 Observability Design
{Logging, metrics, tracing, alerting — which tools, where configured}

#### 3.B.4 Security Posture
{HTTPS termination, secrets management, auth boundaries, network isolation}

#### 3.B.5 Scalability Model
{Vertical / horizontal, stateless vs stateful, session affinity}

### 3.C Specification (How to Rebuild It Correctly)

#### 3.C.1 Environment Contract
{Full list of required env vars, types, validation rules, source of value in prod}

#### 3.C.2 Middleware Order Spec
{Explicit order dependency graph — changing order breaks semantics}

#### 3.C.3 Health Check Contract
{Endpoint shape, response contract, timeout, retry policy}

#### 3.C.4 Deploy Acceptance Criteria
{What must be true for a deploy to be considered successful}

#### 3.C.5 Non-Functional Requirements
| NFR | Requirement | Measurement |
| Uptime SLO | {99.9%} | Synthetic monitoring |
| Deploy Time | < {X min} | CI timing |
| Startup Time | < {X s} | `time` on server boot |

### 3.D Implementation Plan (How to Build the Imitation)

#### 3.D.1 Task Breakdown
{Scaffold → env contract → base middleware → infra → CI → deploy config → health checks → observability}

#### 3.D.2 Build Order
{Local Docker → staging deploy → production deploy}

#### 3.D.3 Verification Checkpoints
{Health checks pass, deploy pipeline green, synthetic traffic succeeds}

---

## Layer 4: Database {if db in scope}

### 4.A Requirements (What the DB Holds Today)

#### 4.A.1 Tables / Models
##### DA-001: {table_name}
**Purpose**, Columns with types, PK/FK/Indexes, Relationships, Constraints, RLS Policies, Referenced in (files)

#### 4.A.2 Views, Triggers, Stored Procedures
{Listed with purpose and source}

#### 4.A.3 Seed Data
{Required seeds for the app to function}

#### 4.A.4 Data Lineage (if --full)
{DL-NNN entries}

### 4.B Design (How the Data Is Designed)

#### 4.B.1 ER Diagram
```mermaid
erDiagram
    {entities + relationships}
```

#### 4.B.2 Normalization Level
{3NF / denormalized / hybrid — with justifications from code}

#### 4.B.3 Indexing Strategy
{Which indexes exist, what queries they serve, gaps}

#### 4.B.4 RLS / Access Pattern
{Row-level security policies summarized}

#### 4.B.5 Migration Strategy
{Up/down migrations, zero-downtime patterns observed}

### 4.C Specification (How to Rebuild It Correctly)

#### 4.C.1 Schema DDL
{Complete CREATE TABLE / CREATE INDEX / CREATE POLICY statements — source of truth}

#### 4.C.2 Migration Ordering
{Correct order to run migrations for a fresh build}

#### 4.C.3 Data Invariants
{Invariants that MUST hold — enforced by constraints or application logic}

#### 4.C.4 Non-Functional Requirements
| NFR | Requirement | Measurement |
| Query p99 | < {Xms} on {table} | Query log |
| Write throughput | {X wps} | Load test |
| Backup RPO | {X min} | Backup config |

### 4.D Implementation Plan (How to Build the Imitation)

#### 4.D.1 Task Breakdown
{Provision DB → apply DDL in order → seed → verify constraints → attach RLS → test queries}

#### 4.D.2 Build Order
{Bottom-up: referenced tables first, referencing tables next}

#### 4.D.3 Verification Checkpoints
{Schema matches 4.C.1, seeds succeed, constraint tests pass}

---

## Layer 5: AI {if ai in scope}

### 5.A Requirements (What the AI Layer Does Today)

#### 5.A.1 AI Surfaces
##### AI-001: {surface name}
**Type**: {prompt | agent | chain | embedding | tool | RAG retriever}
**Purpose**: {what this surface achieves for the user}
**Model**: {provider/name/version/temperature/max tokens}
**Invoked by**: {files and flow IDs that call it}
**Input Schema**: {what goes in}
**Output Schema**: {what comes out}
**Prompt** (verbatim, secrets redacted):
```
{system + user prompt template}
```
**Tools Attached**: {tool names, param schemas}
**RAG**: {vector store, embeddings, chunk size, top-K}
**Error Handling**: {retries, fallbacks, content-filter handling}
**Observability**: {tracing/logging/cost tracking}

{Repeat for each AI surface}

#### 5.A.2 Token Budget / Cost Profile
{Per surface: avg input tokens, avg output tokens, est cost per call, call volume if observable}

#### 5.A.3 Requirements from AI Tests
{T-NNN for AI (evals, golden tests)}

### 5.B Design (How the AI Layer Is Designed)

#### 5.B.1 AI Architecture Diagram
{Mermaid flowchart: User → App → Prompt Assembly → Model → Parser → Output}

#### 5.B.2 Prompt Style Guide
{Patterns observed: persona, structure, formatting, one-shot/few-shot, chain-of-thought}

#### 5.B.3 Tool Design Pattern
{How tools are defined, how the model decides to call them, how results are fed back}

#### 5.B.4 RAG Pipeline Design
{Ingestion → chunking → embedding → indexing → retrieval → reranking → prompt injection}

#### 5.B.5 Evaluation Strategy
{Golden tests, eval datasets, A/B harness — if detected}

#### 5.B.6 Safety & Guardrails
{Prompt-injection defenses, output filtering, PII scrubbing, jailbreak mitigations}

### 5.C Specification (How to Rebuild It Correctly)

#### 5.C.1 Per-Surface Contract
Per AI-NNN: Input JSON Schema, Output JSON Schema, Model requirements, Prompt template, Tool schemas.

#### 5.C.2 Eval Acceptance Criteria
Per AI-NNN: minimum pass rate on golden eval set, latency budget, cost budget.

#### 5.C.3 Non-Functional Requirements
| NFR | Requirement | Measurement |
| Latency p99 | < {Xs} | Client-observed |
| Cost per call | < ${X} | Provider billing |
| Eval pass rate | > {X%} | Golden test suite |
| Hallucination rate | < {X%} | Manual/LLM-judge eval |

#### 5.C.4 Failure Mode Catalog
{Content filter triggers, rate limits, model deprecations, malformed output, tool call loops}

### 5.D Implementation Plan (How to Build the Imitation)

#### 5.D.1 Task Breakdown
{Provision API keys → define schemas → port prompts → wire tools → set up RAG → add evals → observability}

#### 5.D.2 Build Order
{Simpler surfaces first (single prompt), then chains, then agents, then RAG}

#### 5.D.3 Verification Checkpoints
{Each surface passes its eval acceptance criteria from 5.C.2}

---

## Global Cross-Reference Matrix

### X.1 Flow → File Matrix
| Flow ID | Flow Name | Files |
|---------|-----------|-------|

### X.2 File → Flow Matrix
| File | Flows |
|------|-------|

### X.3 Uncovered Areas
{Files that appear in no flow — potential dead code or undiscovered functionality}

### X.4 Cross-Layer Call Graph
{Which frontend flows call which backend APIs call which DB tables call which AI surfaces}

---

## Appendix A: Existing Test Coverage

### A.1 Test Summary
| Category | Test Files | Test Cases | Framework |

### A.2 Coverage Gaps
{Files/flows with no corresponding test}

---

## Appendix B: 10x Feature Outputs (conditional on flags)

{Include sections only if corresponding flag was passed}

### B.1 Dead Code & Orphans (if --full)
### B.2 Security Surface Map (if --full)
### B.3 Complexity Heatmap (if --full)
### B.4 User Stories (if --user-stories or --full)
### B.5 Service Map (if --services or --full)
### B.6 Module Dependency Graph (if --deps or --full)
### B.7 Architecture Decisions (if --decisions or --full)
### B.8 Secret & Config Inventory
### B.9 Staleness Report (if --validate)
### B.10 Impact Analysis (if --impact)
### B.11 Diff against Previous Imitate (if --diff)
```

**ENFORCEMENT: Every field in this output MUST be filled with actual data from the scan. No placeholders. No estimates. No "TODO" markers. If a section has no entries, state "None discovered" — do not omit the section.**

**ENFORCEMENT: Skipped layers (not in `--layer` scope) are OMITTED entirely from the output — do not emit empty shells. The layer header appears only when the layer is in scope.**

### Step 14: Update State

Write to `.healer/state.json`:

```json
{
  "last_command": "imitate",
  "status": "completed",
  "suggested_next": "indulge",
  "timestamp": "ISO-8601",
  "imitate_file": "{output file path}",
  "layers_in_scope": ["frontend", "backend", "server", "db", "ai"],
  "flows_discovered": N,
  "requirements_extracted": N,
  "flags_used": ["--full", "--risk", "etc."]
}
```

## Red Flags — STOP and Reassess

```
RED FLAGS:

  STOP if you're about to modify a source file
  → Imitate is READ-ONLY. You produce a document, not code changes.
  → The ONLY files you create are the output document and optionally CLAUDE.md.

  STOP if you're generating output before finishing the full scan of every layer in scope
  → Complete Steps 1-12 before starting Step 13. Partial scans = partial imitations.

  STOP if you're emitting Requirements without the matching Design, Spec, and Plan subsections
  → 4-in-1 is mandatory per layer. A-only is not imitate; it's record.

  STOP if you're assigning flow IDs non-sequentially or reusing IDs
  → Each category has its own counter. DA-001, DA-002, DA-003. No gaps, no duplicates.

  STOP if you're reading node_modules, .git, or build output
  → Source directories only.

  STOP if you're recording actual secret values from .env files
  → Record variable NAMES and purposes. NEVER record actual API keys, passwords, or tokens.
  → Same rule for AI layer: record prompt STRUCTURE; redact API keys embedded in prompts.

  STOP if you're emitting a layer that wasn't requested in --layer
  → If --layer=frontend,db then server/backend/ai layers are omitted entirely.

  STOP if a section has placeholder text like "{TODO}" or "TBD"
  → Every field gets actual data or "None discovered." No placeholders.

  STOP if you're tracing call chains deeper than 5 levels
  → 5 levels of recursion is the maximum. Beyond that, summarize.

  STOP if you're estimating numbers instead of counting them
  → Run wc -l, grep -c, find | wc -l. Get the actual number. Always.

  STOP if you're writing the Executive Summary before finishing the scan
  → The Executive Summary goes in the output first but is WRITTEN last.

  STOP if Implementation Plan tasks reference flows that don't exist in Requirements
  → Every task in section .D must trace to at least one flow ID from section .A or .B.
```

## Anti-Rationalization

| Rationalization | Reality | Correction |
|----------------|---------|------------|
| "I can summarize the app from the README" | READMEs are often outdated. The CODE is the truth. | Read the actual source files. |
| "This directory probably doesn't have anything important" | "Probably" is not a scan. | Scan every source directory. |
| "I already know what this framework does" | You know the framework. You don't know what THIS app does with it. | Read the actual implementation. |
| "The DB schema is straightforward, I can skim it" | Skimming misses constraints, indexes, RLS policies. | Read every migration, every model, every schema file completely. |
| "There are too many components to list them all" | The imitate is comprehensive BY DESIGN. | List them all. Scope with `--layer` or module filter if needed. |
| "This test file is just boilerplate" | Test descriptions ARE requirements. | Extract every test description. Map it to a flow. |
| "The design tokens are obvious from looking at the UI" | "Obvious" means you guessed. | Read tailwind.config, CSS variables, theme files. |
| "I don't need to trace the full call chain" | Partial traces miss dead code, broken wiring, unexpected detours. | Trace to 5 levels. |
| "The implementation plan is just a reformat of requirements" | Plan is bite-sized TASKS with order and dependencies, not a list of flows. | Write discrete tasks with effort and dependencies. |
| "I'll skip the AI layer — this app doesn't really use AI" | If the ai layer is in scope and any LLM call exists, it must be recorded. | Scan. If nothing found, write "None discovered." Do NOT skip the layer. |
| "Middleware order doesn't matter for this rebuild" | Middleware order is semantic. Reordering breaks auth, CORS, rate limiting. | Preserve order explicitly in 3.A.3. |
| "I can skip the risk scoring since it's a 10x feature" | If the user passed --risk or --full, they asked for it. | Deliver it. |

## Rules

1. **Read-only** — never modify source files. Output document and optional CLAUDE.md only
2. **Layer scope respected** — if `--layer=X,Y` is specified, only X and Y layers are scanned and emitted
3. **4-in-1 per layer** — every layer in scope gets Requirements + Design + Spec + Plan subsections
4. **Complete scan first** — all layers in scope read before any output generation
5. **Every flow gets an ID** — DA-NNN, API-NNN, BLF-NNN, CF-NNN, SF-NNN, CP-NNN, INT-NNN, FF-NNN, DL-NNN, AI-NNN, SRV-NNN
6. **No placeholders** — every field is actual data or "None discovered"
7. **Source directories only** — never read node_modules, .git, dist, build, .next, __pycache__, target
8. **Max 5-level trace depth** — summarize beyond 5 levels of call chain recursion
9. **Never record secrets** — variable names and purposes only, never actual values (includes redaction in AI prompts)
10. **Executive Summary is written last** — it requires the full picture from all layers in scope
11. **Cross-reference matrix is mandatory** — Flow-to-File, File-to-Flow, Cross-Layer Call Graph
12. **Single file output** — `{AppName}_Imitate_{MMDDYYYY}.md`
13. **Flags control 10x features** — base features always on, 10x features only when flagged
14. **Evidence-based counts** — run wc -l, grep -c, find | wc -l for actual numbers, never estimate
15. **Update state** — always write to .healer/state.json when done
16. **Middleware order is preserved** — in server layer, pipeline order is part of the spec
17. **Previous imitate required for --diff** — if no previous imitate exists, warn and skip
18. **CLAUDE.md is condensed** — `--claude-md` output is a summary, not a full copy
19. **OpenAPI spec is standards-compliant** — `--openapi` output must be valid OpenAPI 3.0 YAML
20. **Implementation Plan tasks trace to flows** — every task references at least one flow ID from the layer's Requirements or Design subsection
