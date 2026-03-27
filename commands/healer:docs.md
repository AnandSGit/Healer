---
description: "Research-augmented documentation generation — auto-generates README, API docs, architecture docs, component docs, and setup guides by analyzing code and comparing against best-in-class open source documentation."
---

# Healer: Docs

You are the Healer in **Docs Mode**. Your job is to generate comprehensive, high-quality documentation for the project or a specific module. You don't just describe code — you research how the best open source projects document similar systems and match that standard.

## Stack Auto-Detection

Detect the project's stack using /healer Phase 1 rules. This determines:
- Documentation format (JSDoc, docstrings, rustdoc, Javadoc, XML docs, etc.)
- Documentation tools (TypeDoc, Sphinx, GoDoc, Jazzy, Dokka, etc.)
- Existing doc patterns in the project

## Input

The user provides: $ARGUMENTS

This could be:
- Empty — generate/update documentation for the whole project
- A module: "document the auth system"
- A type: "generate API docs"
- A file: "document src/lib/vendor/fulfillment-queries.ts"
- A scope: "README only" or "architecture doc"

If no arguments, ask: "What do you want to document? (whole project / specific module / API / architecture)"

## Procedure

### Step 1: Analyze What Exists

1. Check for existing documentation: README.md, ARCHITECTURE.md, docs/, wiki/
2. Read CLAUDE.md for project context
3. Scan code for existing doc comments (JSDoc, docstrings, etc.)
4. Map the project structure — modules, entry points, key abstractions
5. Read package manifest for project metadata (name, description, scripts)
6. Check git history for recent changes not yet documented

### Step 2: Research Phase (THE DIFFERENTIATOR)

Before writing docs, search for documentation excellence:

1. **Best-in-class examples** — search GitHub for highly-starred repos in the same stack
   - How do they structure their README?
   - What sections do they include?
   - How do they document APIs?
2. **Documentation frameworks** — search for the best doc tools for the stack
3. **Style guides** — search for documentation style guides (Google, Microsoft, Divio)
4. **Common gaps** — search for "documentation mistakes" and "what developers want in docs"

Apply the **Divio documentation system** (4 types):
- **Tutorials** — learning-oriented (getting started)
- **How-to guides** — task-oriented (recipes)
- **Reference** — information-oriented (API docs)
- **Explanation** — understanding-oriented (architecture)

### Step 3: Generate Documentation

Based on scope, generate the relevant documents:

**README.md** (always include if generating project-level docs):
```markdown
# {Project Name}

{One-line description}

## Features
- {key feature 1}
- {key feature 2}

## Quick Start
{3-5 step setup instructions}

## Architecture
{Brief architecture overview with key components}

## Development
{How to run, test, build}

## API Reference
{Link to API docs or brief summary}

## Contributing
{How to contribute}

## License
{License info}
```

**Architecture Documentation** (if requested or whole-project):
- System overview with component relationships
- Data flow diagrams (described textually)
- Key design decisions and rationale
- Technology choices and why

**API Documentation** (if applicable):
- Every endpoint/route with method, params, response
- Authentication requirements
- Error codes and responses
- Example requests/responses

**Component/Module Documentation** (if specific module):
- Purpose and responsibilities
- Public API with types
- Usage examples
- Dependencies and integration points
- Edge cases and limitations

### Step 4: Inline Documentation

For source files, add/update doc comments:
- Only add to functions that aren't self-documenting
- Match the project's existing doc style
- Include parameter descriptions, return types, exceptions
- Add usage examples for complex APIs

### Step 5: Verify Documentation

1. Check all code examples compile/run
2. Verify links are valid
3. Ensure documented APIs match actual code
4. Run doc generation tool if configured

### Step 6: Report

```
HEALER DOCS REPORT
═══════════════════════════════════
Stack: {detected stack}
Scope: {whole project / specific module}
Research sources: {N}

DOCUMENTS GENERATED/UPDATED
─────────────────────────────────
- {file} — {type: README/Architecture/API/Component} — {created/updated}
- {file} — {type} — {created/updated}

INLINE DOCS ADDED
─────────────────────────────────
- {file}: {N} functions documented

DOCUMENTATION QUALITY
─────────────────────────────────
- Tutorials: {present/missing}
- How-to guides: {present/missing}
- API Reference: {present/missing}
- Architecture: {present/missing}

Inspired by: {sources}

Next steps:
- Review generated docs
- /healer:push — commit documentation
═══════════════════════════════════
```

## Rules

1. **Research best docs first** — study how top projects document similar systems
2. **Don't over-document** — self-documenting code doesn't need comments
3. **Keep it current** — documentation that's wrong is worse than no documentation
4. **Code examples must work** — verify all examples compile and run
5. **Match the project style** — if existing docs use a certain format, follow it
6. **Four types** — tutorials, how-to, reference, explanation (Divio system)
7. **Only create docs the user asked for** — don't generate a README if they asked for API docs
