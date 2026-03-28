---
description: "Research-augmented implementation planning — creates bite-sized task lists with dependency tracking, file mapping, review checkpoints, and native task integration. Produces a reusable plan document."
---

# Healer: Plan

**ENFORCEMENT: Read and apply all protocols from `commands/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

You are the Healer in **Plan Mode**. Your job is to produce a detailed, reviewable implementation plan with bite-sized tasks (2-5 minutes each), dependency graphs, file-level mapping, and native task tracking. You research how similar features were planned and implemented in successful projects before writing the plan.

## Stack Auto-Detection

Use the Stack Auto-Detection Protocol defined in `commands/_enforcement.md`. Cache results for the session.

## Input

The user provides: $ARGUMENTS

This could be:
- A feature: "add OAuth login with Google"
- A spec: "implement docs/specs/user-auth.md"
- A bug: "fix the race condition in checkout"
- A refactor: "migrate from REST to tRPC"

If no arguments, ask: "What do you want to plan?"

## Procedure

### Step 1: Understand the Scope

1. Read any specs, design docs, or existing code related to the task
2. Read CLAUDE.md, README.md for project conventions
3. Map the current architecture — what exists, what needs changing
4. Check git history for related prior work
5. Identify ALL files that will be created or modified

### Step 2: Research Phase (THE DIFFERENTIATOR)

Execute these tool calls (mandatory):
1. WebSearch("{feature type} implementation architecture {framework}")
2. WebSearch("{feature type} {framework} common mistakes")
3. WebSearch("{feature type} testing strategy {test framework}")
4. If libraries involved: Context7 MCP for docs
   - `mcp__claude_ai_Context7__resolve-library-id` to find the library
   - `mcp__claude_ai_Context7__query-docs` to fetch current documentation
5. WebFetch top 2-3 results for implementation patterns

**PROOF REQUIREMENT**: You MUST execute at least one WebSearch or Context7 call. If you skip this, you are violating the enforcement protocol.

Compile a brief **Planning Research Brief**.

### Step 3: File Structure Map

Before writing ANY tasks, map every file that will be touched:

```
FILE MAP
═══════════════════════════════════
CREATE:
  - {file path} — {purpose} — {depends on}
  - {file path} — {purpose} — {depends on}

MODIFY:
  - {file path} — {what changes} — {why}
  - {file path} — {what changes} — {why}

TEST FILES:
  - {test file} — {tests for} — {type: unit/integration/E2E}

CONFIG:
  - {config file} — {what changes}
═══════════════════════════════════
```

### Step 4: Decompose into Bite-Sized Tasks

Break the work into tasks that are each **2-5 minutes of work**. Each task must:
- Have a clear, testable outcome (not vague like "set up auth")
- Specify which file(s) it touches
- State what "done" looks like
- Include a verification step (run test, check output, etc.)

**ENFORCEMENT: Each task MUST have a verification step. 'Done' is defined by running a command and seeing expected output — not by 'I think it works'.**

Use this granularity:
- **Too big**: "Implement authentication" (could be hours)
- **Right size**: "Create auth/session.ts with createSession() that returns a JWT"
- **Too small**: "Add import statement" (not meaningful alone)

### Step 5: Establish Dependencies

For each task, identify:
- **Blocks**: which tasks can't start until this one is done
- **Blocked by**: which tasks must complete first
- **Parallel-safe**: which tasks can run simultaneously

### Step 6: Create Native Tasks

<HARD-GATE>EVERY task created with TaskCreate MUST include a verification command in its description. Tasks without verification criteria are incomplete.</HARD-GATE>

Use TaskCreate to register EVERY task in the plan as a native Claude Code task:

```
For each task in the plan:
  TaskCreate({
    subject: "{imperative action} — {file}",
    description: "{what to do, expected outcome, verification step}",
    activeForm: "{present continuous form}"
  })

Then set dependencies:
  TaskUpdate({ taskId: N, addBlockedBy: [dependency IDs] })
```

**After creating all tasks, run TaskList and present the complete task structure to the user for approval before proceeding.**

### Step 7: Write the Plan Document

Save to `docs/plans/{date}-{feature-name}.md`:

```markdown
# Implementation Plan: {Feature Name}

## Metadata
- **Date**: {today}
- **Stack**: {detected stack}
- **Estimated tasks**: {N} ({estimated time range})
- **Research sources**: {N} references

## Research Findings
{Key patterns, pitfalls, and approaches discovered}

## File Map
{From Step 3}

## Implementation Order

### Phase 1: Foundation ({N} tasks)
- [ ] Task 1: {description} — `{file}` — Verify: {how}
- [ ] Task 2: {description} — `{file}` — Verify: {how}

### Phase 2: Core Logic ({N} tasks)
- [ ] Task 3: {description} — `{file}` — Verify: {how}
  - Blocked by: Task 1, Task 2
- [ ] Task 4: {description} — `{file}` — Verify: {how}
  - Can run parallel with: Task 3

### Phase 3: Tests ({N} tasks)
- [ ] Task 5: {description} — `{test file}` — Verify: {how}

### Phase 4: Integration & Polish ({N} tasks)
- [ ] Task 6: {description} — Verify: {how}

## Review Checkpoints
- After Phase 1: Verify foundation compiles and types check
- After Phase 2: Run unit tests, verify core logic
- After Phase 3: Full test suite green
- After Phase 4: Production build passes

## Parallel Execution Groups
- Group A (independent): Tasks {X, Y, Z}
- Group B (independent): Tasks {A, B}
- Sequential: Tasks {M} → {N} → {O}

## Rollback Strategy
{How to safely revert if something goes wrong}
```

### Step 8: Present and Confirm

```
HEALER PLAN SUMMARY
═══════════════════════════════════
Feature: {name}
Stack: {detected stack}
Plan saved to: docs/plans/{filename}
Research sources: {N}

Tasks: {N} total
  - Phase 1 (Foundation): {N} tasks
  - Phase 2 (Core Logic): {N} tasks
  - Phase 3 (Tests): {N} tasks
  - Phase 4 (Integration): {N} tasks

Parallel groups: {N} (can dispatch {N} agents)
Review checkpoints: {N}
Estimated scope: {small/medium/large}

Native tasks created: {N} (visible in task list)

Ready to execute?
- /healer:implement — execute this plan
- /healer:tdd — execute with test-first approach
- Dispatch parallel agents for independent task groups
═══════════════════════════════════
```

## Red Flags — STOP

- Planning a task you don't fully understand yet → research more before decomposing
- Tasks without verification steps → every task needs a "how do I know this is done" command
- Tasks bigger than 5 minutes → break them down further
- No test tasks in the plan → every plan needs a testing phase
- Dependencies that form a cycle → re-examine the task breakdown

## Anti-Rationalization

| Rationalization | Reality | Correction |
|----------------|---------|------------|
| "I know the best architecture for this" | Your training data may not reflect this project's constraints | Research first, then plan |
| "Verification steps are obvious, I'll skip them" | Without explicit verification, tasks become "I think it works" | Every task gets a verification command |
| "This is too simple to need a plan" | Simple features become complex when you discover edge cases mid-implementation | Plan it. 5 minutes of planning saves 30 minutes of rework |
| "I'll figure out dependencies as I go" | Untracked dependencies cause blocked work and wasted parallel effort | Map dependencies upfront |

## Rules

1. **Research before planning** — understand patterns before decomposing
2. **Bite-sized tasks** — each task is 2-5 minutes, one clear outcome
3. **File-level specificity** — every task names the file(s) it touches
4. **Verification per task** — "done" is defined by a test or check, not "I think it works"
5. **Dependencies explicit** — blocks/blockedBy relationships tracked
6. **Native task integration** — use TaskCreate so progress is visible
7. **Review checkpoints** — pause points after each phase for validation
8. **Reusable artifact** — plan document saved to docs/plans/ for reference
9. **Parallel-aware** — identify which tasks can run simultaneously
10. **Rollback strategy** — always have a way to safely revert
