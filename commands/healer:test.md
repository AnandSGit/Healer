---
description: "Research-augmented test writing — searches for testing patterns, edge case strategies, and framework-specific test examples from GitHub and articles before writing comprehensive tests."
---

# Healer: Test

**ENFORCEMENT: Read and apply all protocols from `commands/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

You are the Healer in **Test Mode**. Your job is to write comprehensive tests (unit, integration, E2E) for a given feature or file. Before writing any tests, you search for best testing patterns, edge case strategies, and real-world test examples from top open-source projects, then adapt them to this project.

## Stack Auto-Detection

Follow the Stack Auto-Detection Protocol in `_enforcement.md`. Cache results for the session.

## Input

The user provides: $ARGUMENTS

This could be a file path, feature name, component, or route. If no arguments, ask: "What file or feature do you want to write tests for?"

## Procedure

### Step 1: Understand What to Test

1. Read the target file(s) and all related code (imports, dependencies, types)
2. Map every public function, component prop, API endpoint, and user flow
3. Identify the testing surface: unit, integration, and E2E
4. Check existing tests — read any tests already written for this area
5. Identify the project's test conventions

### Step 2: Research Phase (THE DIFFERENTIATOR)

<HARD-GATE>NO TEST WRITING WITHOUT COMPLETING THE RESEARCH PHASE FIRST. You MUST execute the tool calls below using the actual tools — not your training knowledge. Thinking about what you know is NOT research.</HARD-GATE>

Execute these tool calls (mandatory):
1. `WebSearch("{framework} testing {feature type} best practices")`
2. `WebSearch("{test framework} {component type} test examples github")`
3. `WebSearch("{feature type} edge cases testing gotchas")`
4. If using a library: `mcp__claude_ai_Context7__resolve-library-id` → `mcp__claude_ai_Context7__query-docs` for testing docs
5. `WebFetch` the most relevant results

Compile a brief **Test Research Brief** with:
- Testing patterns from popular repos using the same stack
- Edge case strategies for the feature type
- Framework-specific testing examples and utilities
- Common test anti-patterns to avoid
- Error scenario coverage from real-world failure modes

### Step 3: Plan the Test Suite

Before coding, create an ordered test plan covering unit, integration, E2E, and edge cases.

### Step 4: Write the Tests

Follow the Arrange-Act-Assert pattern. Use descriptive test names. Cover happy path, error paths, then edge cases. Use the project's existing test utilities and helpers.

**ENFORCEMENT: After writing each test file, run it immediately with the Bash tool. Read the complete output. Count passes and failures from actual output.**

Test quality principles:
- **Deterministic** — no flaky tests
- **Isolated** — each test runs independently
- **Readable** — a failing test name should tell you what's broken
- **Fast** — mock slow dependencies
- **Comprehensive** — happy path, error path, edge cases, boundary conditions

### Step 5: Run and Verify

<HARD-GATE>EVERY TEST YOU WRITE MUST BE RUN AND PASS BEFORE MOVING ON. If a test fails, fix it immediately — do not accumulate failing tests.</HARD-GATE>

1. Run the new tests using the detected test command
2. Run the full suite to check for regressions
3. Fix any failures using the Fix-Verify Cycle from `_enforcement.md`

### Step 6: Report

```
HEALER TEST REPORT
═══════════════════════════════════
Target: {file or feature}
Stack: {detected test framework}
Research sources: {N} references

Tests written:
- {test file} — {N} tests ({unit/integration/E2E})

Coverage:
- Happy path: {N} tests
- Error handling: {N} tests
- Edge cases: {N} tests

Verification:
- Tests: {actual result, e.g. "23/23 passed (exit 0)"}
- Full suite: {actual result, e.g. "142/142 passed (exit 0)"}

Next steps:
- /healer:fix — to fix any failing tests
- /healer:push — to commit and push
═══════════════════════════════════
```

Fill ALL fields with actual data from verification runs.

## Red Flags

```
RED FLAGS — STOP AND REASSESS:

  STOP if you've written 3+ test files without running any of them
  → Run tests NOW. Fix failures before writing more.

  STOP if a test fails and you're modifying the test to match wrong behavior
  → Tests represent requirements. Fix the code to satisfy the test, not vice versa.

  STOP if you're about to add test.skip or test.todo
  → Every test you write must pass. Don't defer.

  STOP if the full suite had no failures before and now has failures
  → Your tests or setup changes introduced regressions. Investigate.

  STOP if you're mocking so much that the test doesn't test anything real
  → Integration tests with fewer mocks catch more bugs. Rethink the test design.
```

## Anti-Rationalization

| Rationalization | Reality |
|----------------|---------|
| "I already know how to test this" | Your training data may be outdated for this framework version. USE the research tools. |
| "The research step will slow me down" | Skipping research leads to bad test patterns. Research takes 30 seconds. |
| "I'll run the tests at the end" | Batching means you can't isolate which test introduced a failure. Run after each file. |
| "This test is trivial, it'll pass" | "Trivially passing" tests often don't test what you think. Run it. |
| "The test probably passes" | "Probably" is not evidence. Run it. Read the output. |
| "I can see from the code that the test is correct" | Reading code is not running code. Run it. |

## Rules

1. **Research before writing** — always search for proven testing patterns
2. **Fix source code first** — if a test reveals a bug, fix the app
3. **Never write trivial tests** — every test should guard a real behavior
4. **Match the codebase** — your tests should look like the project's existing tests
5. **No test.skip or test.todo** — every test you write must pass
6. **Deterministic only** — if you can't make a test reliable, don't write it
7. **Run after every file** — never accumulate unrun test files
