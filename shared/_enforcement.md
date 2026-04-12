# Healer Enforcement Protocol v1.1

**This file is the shared enforcement layer for ALL Healer commands.** Every Healer skill MUST follow these protocols. They are non-negotiable.

---

## HARD-GATE: Postfix `?` / `--help` Interceptor

<HARD-GATE>
THIS CHECK RUNS BEFORE ANY OTHER PROTOCOL IN THIS FILE.
If the user typed `?` or `--help` as the command argument, render help
from `data/help-index.json` and HALT — do not execute the command's
procedure, do not run research, do not do anything else.
</HARD-GATE>

### When to Trigger

`$ARGUMENTS` triggers the help interceptor if it matches ANY of:

```
^\s*\?\s*$              # exactly "?"
^--help\s*$             # exactly "--help"
^\s*\?\s+\S             # "? <rest>" — drill-down for command
^--help\s+\S            # "--help <rest>" — same
\S+\s+\?\s*$            # "<token> ?" — drill-down for that token
\S+\s+--help\s*$        # "<token> --help" — same
```

It DOES NOT trigger if `?` appears mid-string (e.g., `/healer:debug "why is this ?"` — the question mark is part of the topic, not a help request).

### Dispatch

1. Identify the current command from the file path (e.g., `commands/flow.md` → `flow`).
2. Strip the `?` or `--help` token from `$ARGUMENTS`. The remainder, if any, is the **drill-down target**.
3. Read `${CLAUDE_PLUGIN_ROOT}/data/help-index.json` (single file read, ~50ms).
4. Lookup table:

   | Current command | Drill-down target | Render |
   |---|---|---|
   | any `<cmd>` | empty | `commands.<cmd>.panel` from index |
   | `flow` | empty | `flow_overview` from index |
   | `flow` | `<preset>` matching a built-in flow | `flows.<preset>.panel` from index |
   | `flow` | `<recipe>` matching `~/.healer/recipes.yaml` | runtime-render using six-section format from `_help_renderer.md` |
   | `help` | `<command-name>` | equivalent to `commands.<name>.panel` |
   | any | unrecognized target | render "Unknown" panel with Levenshtein-suggested alternatives |

5. Print the panel text VERBATIM (it is pre-rendered — do not reformat, do not summarize).
6. **HALT.** Do not proceed with research, the command's procedure, or any other protocol below this section.

### Fallback

If `data/help-index.json` is missing or unreadable:

1. Print a one-line warning: `⚠ help-index.json missing — falling back to slow path`
2. Render help dynamically by reading the command file's frontmatter `description` field
3. Suggest: `Run \`bash scripts/build-help-index.sh\` to restore fast help`
4. HALT

### Pseudocode (Reference Implementation)

```
ARGS = $ARGUMENTS (raw)

if ARGS matches "^\s*(\?|--help)\s*$":
    target = None
elif ARGS matches "^\s*(\?|--help)\s+(\S+.*)$":
    target = capture group 2
elif ARGS matches "^(\S+.*)\s+(\?|--help)\s*$":
    target = capture group 1
else:
    # `?` mid-string or no `?` at all → pass through to command procedure
    PROCEED to research protocol below

# Help mode active — load index
index = read_json("${CLAUDE_PLUGIN_ROOT}/data/help-index.json")
cmd = current_command_name()  # from file path

if cmd == "flow":
    if target is None:
        print(index["flow_overview"])
    elif target in index["flows"]:
        print(index["flows"][target]["panel"])
    elif recipe := lookup_recipe(target):
        print(render_recipe_panel(recipe))
    else:
        print(unknown_panel(target, candidates=index["flows"].keys()))
elif cmd == "help" and target:
    if target in index["commands"]:
        print(index["commands"][target]["panel"])
    elif target in index["flows"]:
        print(index["flows"][target]["panel"])
    else:
        print(unknown_panel(target))
else:
    if cmd in index["commands"]:
        print(index["commands"][cmd]["panel"])
    else:
        print(unknown_panel(cmd))

HALT
```

See `shared/_help_renderer.md` for the rendering contract and recipe variant details.

---

## HARD-GATE: Research Protocol

<HARD-GATE>
NO CODE CHANGES WITHOUT COMPLETING THE RESEARCH PHASE FIRST.
If the skill has a "Research Phase" step, you MUST execute it using the actual tools listed below BEFORE writing or modifying any code. Thinking about what you know is NOT research. You must USE THE TOOLS.
</HARD-GATE>

### How to Actually Research (Explicit Tool Usage)

When a skill says "search online" or "research", you MUST use these actual tools — not your training knowledge:

```
RESEARCH PROTOCOL — Execute in this order:

1. CONTEXT7 FIRST (if available):
   → Use mcp__claude_ai_Context7__resolve-library-id to find the library
   → Use mcp__claude_ai_Context7__query-docs to fetch current documentation
   → This gets you AUTHORITATIVE, UP-TO-DATE docs — not training data

2. WEB SEARCH for broader context:
   → Use WebSearch with specific queries:
     - "{error message} site:github.com" (for known issues)
     - "{framework} {feature} best practices 2025 2026" (for patterns)
     - "{framework} {feature} example implementation" (for reference code)
     - "{error message} solution" (for fixes)
   → Read at LEAST 3 results before forming a fix strategy

3. WEB FETCH for deep reading:
   → Use WebFetch on the most promising URLs from search results
   → Read actual documentation pages, not just snippets
   → Read GitHub issues/PRs that discuss the exact problem

4. SYNTHESIZE into actionable plan:
   → Write a Research Brief (see template in each skill)
   → Map findings to THIS project's specific stack and conventions
   → Only THEN proceed to implementation
```

**PROOF REQUIREMENT**: Your response MUST include at least one WebSearch or Context7 tool call in the research phase. If you skip this, you are violating the enforcement protocol.

---

## HARD-GATE: Verification Protocol

<HARD-GATE>
NO SUCCESS CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.
Before reporting ANY status (pass/fail/fixed/working), you MUST:
1. Run the ACTUAL verification command (not recall a previous run)
2. Read the COMPLETE output
3. Check the exit code
4. Count actual pass/fail numbers from the output
ONLY THEN may you fill in the report template.
</HARD-GATE>

### The Evidence Gate

```
BEFORE claiming any status, execute this gate:

  STEP 1 — IDENTIFY: What command proves this claim?
    - "Tests pass" → the test runner command
    - "Build succeeds" → the build command
    - "Lint clean" → the linter command
    - "Fixed" → the specific failing test/scenario

  STEP 2 — RUN: Execute the FULL command right now (not from memory)
    - Use Bash tool to run the command
    - Do NOT truncate output with | head or | tail
    - Capture the full output

  STEP 3 — READ: Examine the complete output
    - Count failures, errors, warnings from the ACTUAL output
    - Check the exit code (0 = success, non-zero = failure)
    - Note any new warnings or issues

  STEP 4 — VERIFY: Does the output CONFIRM the claim?
    - If yes → make the claim with evidence: "Tests pass: 47/47 passed (exit 0)"
    - If no → DO NOT make the claim. Report the actual status honestly.

  STEP 5 — RECORD: Include the evidence in your report
    - Never use placeholder values like {pass/fail}
    - Always use actual numbers from actual output
```

### Claim-to-Proof Mapping

| Claim | Required Proof |
|-------|---------------|
| "Tests pass" | Test command output showing 0 failures + exit code 0 |
| "Build succeeds" | Build command completing with exit code 0 |
| "Lint clean" | Linter output showing 0 errors |
| "Type check clean" | Type checker output showing 0 errors |
| "Bug is fixed" | Previously failing test now passes + full suite still green |
| "No regressions" | Full test suite output showing same or better pass count |
| "Performance improved" | Before AND after benchmark numbers from actual runs |

---

## HARD-GATE: Fix Verification Protocol

<HARD-GATE>
AFTER APPLYING ANY FIX, YOU MUST IMMEDIATELY VERIFY IT WORKS.
Do not batch fixes. Do not assume a fix works because it "looks right."
Apply fix → Run verification → Confirm output → Only then move to next fix.
If the fix didn't work, REVERT IT before trying the next approach.
</HARD-GATE>

```
FIX-VERIFY CYCLE (mandatory for every fix):

  1. APPLY: Make the specific code change
  2. RUN: Execute the relevant test/check command immediately
  3. CHECK: Read the output — did the specific failure resolve?
  4. REGRESS: Did any NEW failures appear?

  IF fix works AND no regressions → Record and continue
  IF fix doesn't work → REVERT the change, try next approach
  IF fix works BUT new regressions → REVERT and find a better approach
  IF 3 consecutive fix attempts fail → STOP. Report the issue to the user.
     Do NOT keep trying blindly. Escalate with:
     "I've tried 3 approaches to fix {issue} and none worked. Here's what I tried
     and why each failed: {details}. I need your input on the approach."
```

---

## Anti-Rationalization Table

These are the thoughts that lead to ineffective Healer sessions. When you notice yourself thinking any of these, STOP and follow the correction.

| Rationalization | Reality | Correction |
|----------------|---------|------------|
| "I already know how to fix this" | Your training data may be outdated or wrong for this specific version/context | USE the research tools. Search for the actual error. |
| "The research step will slow me down" | Skipping research leads to wrong fixes, which cost MORE time | Research takes 30 seconds. Wrong fixes take 30 minutes. |
| "I'll research if my first fix doesn't work" | First fix rarely works without research. Now you've introduced bad code. | Research FIRST. Fix ONCE. |
| "This is a simple/obvious fix" | "Simple" fixes that crash the app aren't simple. You don't know until you verify. | Apply fix → run tests → verify → only then call it simple. |
| "The tests probably pass" | "Probably" is not evidence. Run them. | Run the actual command. Read the actual output. |
| "I'll verify everything at the end" | Batching verification means you can't isolate which fix broke what | Verify after EACH change. |
| "I can see from the code that this works" | Reading code ≠ running code. Runtime behavior can differ from static analysis. | Run it. Code review catches ~60% of bugs; testing catches ~90%. |
| "This test failure is unrelated" | Until you verify it's unrelated, it might be a regression YOU caused | Investigate every new failure. Prove it's unrelated with evidence. |
| "I'll skip the online search, Context7 isn't available" | WebSearch is ALWAYS available. Use it. | WebSearch "{error}" or WebSearch "{pattern} best practices" |
| "The research didn't find anything useful" | You searched with bad queries, or didn't read the results deeply enough | Try 3 different query formulations. Read at least 3 full results. |
| "I need to move fast" | Moving fast with wrong fixes = moving backwards | Correct once > wrong three times. |
| "The user just wants it fixed, not researched" | The user wants it ACTUALLY FIXED. Research is HOW you actually fix it. | Research is not separate from fixing. It IS the fixing process. |
| "The design spec is just a guideline" | Design specs are requirements. Every class, color, and font matters. | Read the spec. Implement exactly. Deviate only with approval. |
| "I'll match the design in a polish pass" | Polish passes never happen. Ship matches spec or doesn't ship. | Match the design during implementation, not after. |
| "The user won't notice this difference" | The user approved specific designs. Differences erode trust. | If the user won't notice, it's easy to get right. Do it. |

---

## Red-Flag Stop Conditions

When you encounter any of these, STOP your current approach and reassess:

```
RED FLAGS — STOP AND REASSESS:

  STOP if you've applied 3+ fixes and the original error persists
  → You're treating symptoms, not root cause. Step back and trace the full error path.

  STOP if fixing one thing breaks another repeatedly
  → You have a coupling problem. Read more code to understand the dependencies.

  STOP if the error message doesn't match what you expected
  → Your mental model is wrong. Re-read the code. Re-read the error. Search online.

  STOP if you're changing code you don't fully understand
  → Read the entire file. Read its callers. Read its tests. Understand, THEN change.

  STOP if the test suite was green before your changes and now has failures
  → Your fix introduced regressions. REVERT to the last known good state.

  STOP if you're about to delete or skip a failing test
  → Tests represent requirements. Fix the code to satisfy the test, not vice versa.

  STOP if you're about to add a try/catch to silence an error
  → Silencing errors creates silent failures. Fix the root cause.

  STOP if your "fix" is more than 50 lines of new code for what was described as a small bug
  → Something is wrong with your approach. The fix should be proportional to the bug.
```

---

## Stack Auto-Detection Protocol

**All skills share this detection procedure.** Do not duplicate it — reference it.

```
DETECT STACK (run once per session, cache results):

1. SCAN project root for manifest files:

   FILE FOUND                    → STACK
   ─────────────────────────────────────────────────
   package.json                  → Node.js / JavaScript / TypeScript
   tsconfig.json                 → TypeScript
   Cargo.toml                    → Rust
   go.mod                        → Go
   pyproject.toml / setup.py     → Python
   pubspec.yaml                  → Dart / Flutter
   Package.swift / *.xcodeproj   → Swift / iOS / macOS
   build.gradle / build.gradle.kts → Android / Java / Kotlin
   *.sln / *.csproj              → .NET / C#
   CMakeLists.txt / Makefile     → C / C++
   Gemfile                       → Ruby
   mix.exs                       → Elixir
   go.mod                        → Go

2. DETECT package manager:
   pnpm-lock.yaml → pnpm | yarn.lock → yarn | package-lock.json → npm
   Pipfile.lock → pipenv | poetry.lock → poetry | uv.lock → uv
   Cargo.lock → cargo | go.sum → go | pubspec.lock → pub/flutter

3. DETECT test framework from config and dependencies:
   Read the manifest file to identify test framework, linter, type checker, build command.

4. DETECT test commands by checking:
   - package.json scripts (test, lint, typecheck, build, e2e)
   - Makefile targets
   - CI config (.github/workflows/, .gitlab-ci.yml)
   - README.md for documented commands

5. STORE detected stack for use by all subsequent operations:
   Stack: {language} + {framework}
   Test: {command}
   Lint: {command}
   Types: {command}
   Build: {command}
   E2E: {command}
```

---

## Subagent Dispatch Protocol

For complex tasks, dispatch focused subagents instead of doing everything in one context:

```
WHEN TO DISPATCH SUBAGENTS:

  - When implementing 3+ independent files → dispatch parallel implementer agents
  - When fixing requires both research AND implementation → research agent first, then fix agent
  - When reviewing → separate spec-compliance agent and code-quality agent

HOW TO DISPATCH:

  1. Extract the FULL task description (not a reference)
  2. Include relevant context: stack info, file paths, conventions
  3. Include the enforcement protocol reference
  4. Set clear success criteria
  5. Review the subagent's output — don't blindly trust it
```

---

## Session State Protocol

After completing ANY healer command, write state for flow continuity:

```json
// .healer/state.json
{
  "last_command": "{command}",
  "status": "completed|failed|partial",
  "suggested_next": "{next_command}",
  "timestamp": "{ISO timestamp}",
  "stack_detected": "{cached stack info}",
  "verification_evidence": "{last test run results}"
}
```

---

## Requirements Traceability Protocol

Every healer command that produces artifacts MUST maintain traceability:

### Artifact Chain
```
validate → brainstorm → research → design → architect → spec → plan → implement → test → review
```

Each artifact MUST:
1. **Reference upstream artifacts** — "This design traces to brainstorm: ~/.healer/brainstorms/{file}"
2. **Include a REQUIREMENTS_TRACED section** mapping upstream requirements to this artifact's decisions
3. **Include a VERIFICATION_CHECKLIST** that downstream commands use to verify implementation

### Verification-Against-Requirements Protocol

Before claiming ANY implementation is complete:

1. **Find the requirements chain:**
   ```bash
   ls ~/.healer/validations/ ~/.healer/brainstorms/ ~/.healer/research/ docs/designs/ docs/specs/ docs/plans/ 2>/dev/null
   ```

2. **For each upstream artifact found:**
   - Read its REQUIREMENTS section
   - Check each requirement against the implementation
   - Mark: ✅ Implemented, ⚠️ Partial, ❌ Missing

3. **Generate Traceability Report:**
   ```
   REQUIREMENT TRACEABILITY
   ═══════════════════════════════════
   Source: {artifact file}

   REQ-1: {requirement} → ✅ Implemented in {file:line}
   REQ-2: {requirement} → ⚠️ Partial — missing {what}
   REQ-3: {requirement} → ❌ Not implemented

   Coverage: {X}/{Y} requirements ({%})
   ═══════════════════════════════════
   ```

4. **HARD-GATE: If coverage < 80%, flag it.** Do NOT claim "done" without addressing gaps.

---

## Design Conformance Protocol

<HARD-GATE>
UI CODE WITHOUT DESIGN SPEC READING IS PROHIBITED.
Before writing or modifying ANY file that renders UI (page.tsx, component.tsx, layout.tsx):
1. Find the corresponding design spec section
2. Read it completely
3. Extract CSS classes, fonts, colors, spacing, components, animations
4. Only THEN write code
5. After writing, verify conformance against the spec
</HARD-GATE>

### The Design Spec Reading Checklist

Before implementing ANY UI page:

```
PRE-IMPLEMENTATION DESIGN CHECK:

  □ Found design spec section for this page/component
  □ Read the spec COMPLETELY (not skimmed)
  □ Extracted: layout structure (grid/flex, columns, max-width)
  □ Extracted: typography (font-display vs font-body, text-* tokens)
  □ Extracted: colors (cream, terracotta, sage, ink — no raw hex)
  □ Extracted: spacing (py-12 md:py-24 pattern, gap values, padding)
  □ Extracted: component patterns (button hover, card hover, input focus)
  □ Extracted: animations (scroll-reveal, stagger, particles, count-up)
  □ Extracted: responsive behavior (mobile/tablet/desktop layouts)
  □ Extracted: chrome requirements (nav, footer, skeletons, empty states)
  □ Compared with existing code (if modifying)
  □ Flagged intentional deviations (if any)
```

### Post-Implementation Design Verification

After implementing ANY UI page:

```
POST-IMPLEMENTATION DESIGN CHECK:

  □ All sections from spec exist in code (no missing sections)
  □ Section order matches spec
  □ Font usage: font-display for headings, font-body for text
  □ Text sizes: design tokens only (no generic text-sm/text-lg)
  □ Colors: design tokens only (no raw hex values)
  □ Spacing: correct section rhythm (py-12 md:py-24)
  □ Container: max-w-7xl mx-auto px-6 lg:px-8
  □ Component patterns: correct hover effects, border styles
  □ Animations: scroll-reveal on sections, stagger on grids
  □ Chrome: navigation present, footer present
  □ Responsive: tested at mobile/tablet/desktop breakpoints
  □ Skeleton loaders: for all async content
  □ Empty states: for all lists/grids
```

### Common Design Conformance Traps

| Trap | Impact | Prevention |
|------|--------|------------|
| "I'll add animations later" | They never get added | Add them during initial implementation |
| "The footer can wait" | Every page ships without it | Footer is a requirement, not optional |
| "Close enough on spacing" | Inconsistent visual rhythm | Use exact tokens from DESIGN.md |
| "text-sm is fine" | Breaks the type scale | Use text-body, text-label, text-micro |
| "I'll use a placeholder nav" | Placeholder becomes permanent | Use the shared Navbar component |
| "Raw hex is just for this one spot" | Hex values proliferate | Always use design tokens |
| "The design says X but Y is better" | Unapproved deviation | Flag and get approval first |

---

## Enhanced Research Protocol

In addition to the base research protocol, ALL commands should:

1. **Search from multiple angles:**
   - "{topic} best practices" — the standard approach
   - "{topic} problems failures" — what goes wrong
   - "{topic} alternatives comparison" — what else exists
   - "{topic} 2025 2026" — current state of the art

2. **Source credibility scoring:**
   - ★★★★★ Official docs (via Context7 or vendor sites)
   - ★★★★ High-star GitHub repos (>1K stars)
   - ★★★ Reputable tech blogs (Martin Fowler, Addy Osmani, etc.)
   - ★★ Forum posts (Stack Overflow answers with 10+ votes)
   - ★ Random blog posts (use with caution)

3. **Contradiction detection:**
   When two sources disagree, explicitly flag it:
   "⚠️ CONTRADICTION: Source A says {X} while Source B says {Y}.
    My assessment: {which is more credible and why}"

4. **Negative research (mandatory for brainstorm/design/plan):**
   - WebSearch("{topic} failed postmortem")
   - WebSearch("{topic} common mistakes anti-patterns")
   Learn from others' failures before proposing solutions.

---

## Memory Protocol

Key decisions and constraints that affect future sessions should be flagged:
- Save critical architectural decisions to project docs or CLAUDE.md
- Note user's UI/UX preferences and recurring patterns
- Flag recurring issues for future sessions to avoid

---

## The Iron Law of Healer

```
EVIDENCE BEFORE ASSERTIONS. ALWAYS.

If you haven't run it, you can't claim it.
If you haven't searched, you can't prescribe.
If you haven't verified, you can't report.
```
