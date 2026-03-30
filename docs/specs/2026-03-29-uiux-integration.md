# Technical Specification: UI-UX-Pro-Max Integration into Healer

## Metadata
- **Author**: Healer
- **Date**: 2026-03-29
- **Status**: Draft
- **Stack**: Claude Code Plugin (Markdown commands + Python 3 + CSV data)
- **References**:
  - Claude Code Plugins Reference — https://code.claude.com/docs/en/plugins-reference
  - Claude Code Hooks Guide — https://code.claude.com/docs/en/hooks-guide
  - ADR format — https://github.com/joelparkerhenderson/architecture-decision-record
  - POSIX atomic rename — https://rcrowley.org/2010/01/06/things-unix-can-do-atomically.html
  - Given/When/Then format — https://agilealliance.org/glossary/given-when-then/

### Artifact Lineage
| Phase | Artifact | Path | Key Decisions Carried Forward |
|-------|----------|------|-------------------------------|
| Validation | GO 7/10 | ~/.healer/validations/2026-03-29-healer-uiux-integration.md | Real usage (100+/wk), flow breakage confirmed, internal toolchain |
| Brainstorm | Approach C | ~/.healer/brainstorms/2026-03-29-healer-uiux-integration.md | Direct copy + hook sync, CSVs as runtime data, Healer-native format |
| Research | RES-20260329-CSVP | ~/.healer/research/2026-03-29-csv-plugin-integration.md | ${CLAUDE_PLUGIN_ROOT} paths, atomic rename, core.py as schema |
| Design | 7/7 PASS | docs/designs/2026-03-29-uiux-integration.md | Directory layout, command template, data flow, flow presets |
| Strategy | CONDITIONAL GO 7.4/10 | ~/.healer/strategies/2026-03-29-uiux-integration.md | Add metrics, version-pin sync, implement in waves |

---

## 1. Overview

Integrate all UI-UX-Pro-Max design intelligence capabilities into the Healer plugin as a purely additive enhancement. This adds 6 new commands, enhances 5 existing commands, introduces a data infrastructure layer (76 CSVs, 57 reference docs, 4 Python scripts), and creates a SessionStart sync hook for upstream data freshness.

## 2. Background

Healer and UI-UX-Pro-Max are both installed globally as Claude Code plugins. The user invokes both 100+ times per week. The two-plugin split causes flow pipeline breakage and context confusion. This integration eliminates context switching by making design intelligence data natively available within Healer commands.

## 3. Goals and Non-Goals

**Goals:**
- Eliminate flow breakage between Healer and UI-UX-Pro-Max
- Make 161 color palettes, 57 font pairings, 99 UX guidelines, and 50+ styles queryable from within Healer commands
- Maintain upstream data freshness via automated sync
- Follow Healer's enforcement protocol for all new/enhanced commands

**Non-Goals (explicitly out of scope for v1):**
- Override/customization layer on CSVs
- MCP server for design data (commands read files directly)
- Canvas font directories (83 dirs)
- Social photos generation pipeline
- CLI tool (uipro-cli)
- GitHub-based sync (local install only for v1)

---

## 4. Functional Requirements

### FR-1: Infrastructure — Data Directory
Copy all UI-UX-Pro-Max CSV data files into `${CLAUDE_PLUGIN_ROOT}/data/`.
Traces to: REQ-F01, Design D1

**Acceptance Criteria:**
```gherkin
Scenario: Data directory contains all required CSVs
  Given Healer plugin is installed
  When I list files in ${CLAUDE_PLUGIN_ROOT}/data/
  Then I find at least 14 CSV files including styles.csv, colors.csv,
    typography.csv, ux-guidelines.csv, products.csv, ui-reasoning.csv,
    charts.csv, icons.csv, landing.csv, app-interface.csv,
    react-performance.csv, google-fonts.csv, design.csv
  And I find a stacks/ subdirectory with at least 14 stack CSVs

Scenario: CSV files are valid and parseable
  Given the data directory is populated
  When I run python3 -c "import csv; csv.reader(open('data/styles.csv'))"
  Then it exits with code 0
  And the first row contains "Style Category" as a column header
```

### FR-2: Infrastructure — Reference Documents
Copy all UI-UX-Pro-Max reference docs into `${CLAUDE_PLUGIN_ROOT}/references/`.
Traces to: REQ-F02, Design layout

**Acceptance Criteria:**
```gherkin
Scenario: Reference directories exist with docs
  Given Healer plugin is installed
  When I list ${CLAUDE_PLUGIN_ROOT}/references/
  Then I find 5 subdirectories: brand/, design/, design-system/,
    ui-styling/, slides/
  And brand/ contains at least 10 .md files
  And design/ contains at least 10 .md files
  And slides/ contains at least 6 .md files
```

### FR-3: Infrastructure — Python Scripts
Copy UI-UX-Pro-Max search engine scripts into `${CLAUDE_PLUGIN_ROOT}/scripts/`.
Traces to: REQ-F03, Design D2

**Acceptance Criteria:**
```gherkin
Scenario: Search engine works from Healer's directory
  Given scripts/search.py, scripts/core.py, scripts/design_system.py exist
  And data/ directory is populated with CSVs
  When I run: python3 scripts/search.py "modern dark dashboard" --domain style
  Then it exits with code 0
  And stdout contains "## UI Pro Max Search Results"
  And stdout contains at least 1 result with "Style Category"

Scenario: Design system generation works
  Given scripts are in place and data/ is populated
  When I run: python3 scripts/search.py "saas analytics" --design-system
  Then it exits with code 0
  And stdout contains color palette recommendations
  And stdout contains typography recommendations

Scenario: core.py DATA_DIR resolves correctly
  Given scripts/ and data/ are sibling directories under plugin root
  When core.py computes DATA_DIR as Path(__file__).parent.parent / "data"
  Then DATA_DIR points to ${CLAUDE_PLUGIN_ROOT}/data/
```

### FR-4: Infrastructure — SessionStart Sync Hook
Create a SessionStart hook that checks for upstream updates on configurable frequency.
Traces to: REQ-F04, REQ-F05, Design D4/D5/D6/D7, Strategy recommendation #2

**Acceptance Criteria:**
```gherkin
Scenario: Sync skips when last sync is recent
  Given ${CLAUDE_PLUGIN_DATA}/sync-state.json exists
  And last_sync is less than 7 days ago
  When SessionStart hook fires
  Then sync-upstream.sh exits with code 0
  And stdout is empty (no context injection)
  And the process completes in under 500ms

Scenario: Sync executes when data is stale
  Given ${CLAUDE_PLUGIN_DATA}/sync-state.json exists
  And last_sync is more than 7 days ago
  And UI-UX-Pro-Max is installed at ~/.claude/plugins/marketplaces/ui-ux-pro-max-skill/
  When SessionStart hook fires
  Then sync-upstream.sh copies upstream data to data.new/
  And validates headers of styles.csv, colors.csv, typography.csv, ux-guidelines.csv
  And performs atomic directory swap (mv data/ data.backup/ && mv data.new/ data/)
  And removes data.backup/
  And updates sync-state.json with current timestamp and upstream version
  And stdout reports "Healer data synced from UI-UX-Pro-Max vX.Y.Z (N files)"

Scenario: Sync rolls back on validation failure
  Given upstream data has changed CSV headers (schema drift)
  When sync-upstream.sh validates headers
  Then validation fails on header mismatch
  And data.new/ is removed
  And existing data/ is untouched
  And stdout reports "Healer sync skipped: CSV schema mismatch in {file}"

Scenario: Sync skips gracefully when upstream not installed
  Given UI-UX-Pro-Max is NOT installed
  When SessionStart hook fires
  Then sync-upstream.sh exits with code 0
  And stdout is empty
  And no error is raised

Scenario: Sync skips when Python is not available
  Given Python 3 is not in PATH
  When SessionStart hook fires
  Then sync-upstream.sh exits with code 0
  And stdout reports "Healer sync: Python 3 required for data sync"

Scenario: Version-pin check (Strategy rec #2)
  Given sync-state.json records upstream_version "2.5.0"
  And upstream UI-UX-Pro-Max version is "3.0.0" (major bump)
  When sync-upstream.sh detects major version change
  Then stdout reports "Healer sync: upstream major version bump (2.x → 3.x). Manual review recommended."
  And sync proceeds but flags the warning
```

### FR-5: Infrastructure — Plugin Manifest
Create `.claude-plugin/plugin.json` for formal plugin registration.
Traces to: Open question #1 (resolved: yes)

**Acceptance Criteria:**
```gherkin
Scenario: Plugin manifest is valid
  Given .claude-plugin/plugin.json exists
  When Claude Code loads the plugin
  Then it discovers all commands in commands/
  And it registers hooks from hooks/hooks.json
  And the plugin name is "healer"

Scenario: Plugin manifest declares correct paths
  Given plugin.json contains commands, hooks entries
  When paths are resolved
  Then commands points to "./commands/"
  And hooks points to "./hooks/hooks.json"
```

### FR-6: New Command — healer:brand
Brand voice framework, visual identity, messaging architecture.
Traces to: REQ-F06, Design 6.1

**Acceptance Criteria:**
```gherkin
Scenario: Brand command queries CSV data before web research
  Given healer:brand is invoked with "fintech mobile app"
  When Claude executes the command
  Then it runs python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "fintech mobile" --design-system
  And it reads ${CLAUDE_PLUGIN_ROOT}/references/brand/voice-framework.md
  And it reads ${CLAUDE_PLUGIN_ROOT}/references/brand/visual-identity.md
  And it performs web research (HARD-GATE enforced)
  And output includes brand voice, tone, visual identity, messaging framework

Scenario: Brand command follows enforcement protocol
  Given healer:brand.md is loaded
  Then it contains "ENFORCEMENT: Read and apply all protocols from commands/_enforcement.md"
  And it contains at least one HARD-GATE
  And it contains an Anti-Rationalization table
```

### FR-7: New Command — healer:logo
Logo design guidance with styles, color psychology, industry conventions.
Traces to: REQ-F07, Design 6.2

**Acceptance Criteria:**
```gherkin
Scenario: Logo command reads reference docs
  Given healer:logo is invoked
  When Claude executes the command
  Then it reads ${CLAUDE_PLUGIN_ROOT}/references/design/logo-design.md
  And it reads ${CLAUDE_PLUGIN_ROOT}/references/design/logo-style-guide.md
  And it reads ${CLAUDE_PLUGIN_ROOT}/references/design/logo-color-psychology.md
  And it performs web research
  And output includes logo brief with style recommendations
```

### FR-8: New Command — healer:cip
Corporate Identity Program with 50+ deliverables.
Traces to: REQ-F08, Design 6.3

**Acceptance Criteria:**
```gherkin
Scenario: CIP command reads reference docs
  Given healer:cip is invoked
  When Claude executes the command
  Then it reads ${CLAUDE_PLUGIN_ROOT}/references/design/cip-design.md
  And it reads ${CLAUDE_PLUGIN_ROOT}/references/design/cip-deliverable-guide.md
  And output includes CIP checklist with deliverable specifications
```

### FR-9: New Command — healer:banner
Banner design for 22 styles across 9+ social platforms.
Traces to: REQ-F09, Design 6.4

**Acceptance Criteria:**
```gherkin
Scenario: Banner command reads size/style reference
  Given healer:banner is invoked
  When Claude executes the command
  Then it reads ${CLAUDE_PLUGIN_ROOT}/references/slides/banner-sizes-and-styles.md
  And it performs web research for current platform dimensions
  And output includes platform-specific banner specifications
```

### FR-10: New Command — healer:icon
Icon design with 15 styles, SVG generation guidance.
Traces to: REQ-F10, Design 6.5

**Acceptance Criteria:**
```gherkin
Scenario: Icon command queries CSV and reference doc
  Given healer:icon is invoked with "dashboard navigation"
  When Claude executes the command
  Then it runs python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "dashboard navigation" --domain icons
  And it reads ${CLAUDE_PLUGIN_ROOT}/references/design/icon-design.md
  And output includes icon system specification with library and code examples
```

### FR-11: New Command — healer:slides
HTML presentation design with Chart.js and copywriting.
Traces to: REQ-F11, Design 6.6

**Acceptance Criteria:**
```gherkin
Scenario: Slides command reads references and queries charts
  Given healer:slides is invoked with "quarterly metrics"
  When Claude executes the command
  Then it reads ${CLAUDE_PLUGIN_ROOT}/references/slides/slides-create.md
  And it reads ${CLAUDE_PLUGIN_ROOT}/references/slides/slides-html-template.md
  And it reads ${CLAUDE_PLUGIN_ROOT}/references/slides/slides-copywriting-formulas.md
  And it runs python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "metrics" --domain chart
  And output includes slide deck specification or HTML preview
```

### FR-12: Enhanced Command — healer:design
Add Step 0.5 querying styles/products/reasoning CSVs before web research.
Traces to: REQ-F12, Design 6.7

**Acceptance Criteria:**
```gherkin
Scenario: Design command runs CSV lookup before web research
  Given healer:design is invoked with "user onboarding flow for SaaS"
  When Claude executes the command
  Then it runs python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "saas onboarding" --design-system
  BEFORE executing any WebSearch calls
  And the CSV results inform the design decisions
  And web research still occurs (HARD-GATE enforced)

Scenario: Existing design command behavior is preserved
  Given healer:design is invoked
  When Claude executes the command
  Then all existing steps (0 through 7) still execute
  And Step 0.5 is inserted between Step 0 and Step 1
  And no existing behavior is removed or altered
```

### FR-13: Enhanced Command — healer:design-system
Add Step 0.5 querying colors, typography, and stack-specific CSVs.
Traces to: REQ-F13, Design 6.8

**Acceptance Criteria:**
```gherkin
Scenario: Design-system queries palettes and font pairings
  Given healer:design-system is invoked with "modern SaaS dashboard"
  When Claude executes the command
  Then it runs python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "saas dashboard modern" --design-system
  And it runs python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "modern" --domain typography
  And the 161 color palettes and 57 font pairings are available as starting points
  And web research STILL occurs per enforcement protocol
```

### FR-14: Enhanced Command — healer:design-review
Embed UX guidelines from CSV into 7-dimension checklist.
Traces to: REQ-F14, Design 6.9

**Acceptance Criteria:**
```gherkin
Scenario: Design review includes UX guideline checks
  Given healer:design-review is invoked
  When Claude evaluates the 7 dimensions
  Then it runs python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "accessibility touch animation navigation" --domain ux
  And each dimension cross-references relevant UX guidelines from the CSV
  And the report cites specific guideline IDs (e.g., "color-contrast", "touch-target-size")
```

### FR-15: Enhanced Command — healer:implement
Add stack-specific guidelines lookup for UI implementation.
Traces to: REQ-F15, Design 6.10

**Acceptance Criteria:**
```gherkin
Scenario: Implement queries stack guidelines for detected stack
  Given healer:implement is invoked for a UI feature
  And the detected stack is "nextjs"
  When Claude executes the command
  Then it runs python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<feature>" --stack nextjs
  And stack-specific guidelines inform the implementation
```

### FR-16: Enhanced Command — healer:audit
Add UX audit dimensions for animation, navigation, forms, touch.
Traces to: REQ-F16, Design 6.11

**Acceptance Criteria:**
```gherkin
Scenario: Audit includes UX-specific checks
  Given healer:audit is invoked
  When Claude performs the audit
  Then it runs python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "accessibility touch animation forms navigation" --domain ux
  And the audit report includes UX dimensions beyond security
```

### FR-17: Flow Presets — New
Add `identity` and `brand-to-production` built-in presets.
Traces to: REQ-F17, Design Section 5

**Acceptance Criteria:**
```gherkin
Scenario: Identity flow executes correct sequence
  Given user runs /healer:flow identity
  Then the flow executes: brand ?→ logo ?→ cip ?→ design-system ?→
  And each step is an interactive gate

Scenario: Brand-to-production flow executes correct sequence
  Given user runs /healer:flow brand-to-production
  Then the flow executes: brand ?→ design-system ?→ design ?→ implement → test !→ review ?→ ship !→
```

### FR-18: Flow Presets — Enhanced
Enhance `visual` preset to include brand step.
Traces to: REQ-F17 (visual), Design Section 5

**Acceptance Criteria:**
```gherkin
Scenario: Visual flow includes brand step
  Given user runs /healer:flow visual
  Then the flow executes: brand ?→ design-system ?→ design ?→ design-review →
```

### FR-19: Flow Recipes — New
Add 4 custom recipes to config/recipes.yaml.
Traces to: REQ-F17, Design Section 5

**Acceptance Criteria:**
```gherkin
Scenario: Brand-identity recipe is available
  Given config/recipes.yaml contains brand-identity flow
  When user runs /healer:flow brand-identity
  Then the flow executes: brainstorm ?→ brand ?→ logo ?→ icon ?→ cip ?→ design-system ?→ design-review →

Scenario: Marketing-kit recipe is available
  Given config/recipes.yaml contains marketing-kit flow
  When user runs /healer:flow marketing-kit
  Then the flow executes: brand ?→ logo ?→ banner ?→ slides ?→
```

### FR-20: Help System Update
Document all new commands, presets, recipes in healer:help.
Traces to: REQ-F19

**Acceptance Criteria:**
```gherkin
Scenario: Help lists new commands
  Given user runs /healer:help
  Then output includes healer:brand, healer:logo, healer:cip,
    healer:banner, healer:icon, healer:slides
  And includes new flow presets: identity, brand-to-production
  And includes new recipes: brand-identity, visual-full, marketing-kit, design-polish
```

### FR-21: Main Command Update
Update healer.md sub-command listing.
Traces to: REQ-F20

**Acceptance Criteria:**
```gherkin
Scenario: healer.md lists all 32 sub-commands
  Given healer.md is loaded
  Then the sub-commands section lists all 6 new commands
  And the total count is 32 (26 existing + 6 new)
```

### FR-22: Suggested-Next Graph Update
Add new commands to the flow suggestion graph.
Traces to: Design Section 5

**Acceptance Criteria:**
```gherkin
Scenario: Brand suggests correct next steps
  Given user completes /healer:brand
  When .healer/state.json is updated
  Then suggested_next includes "logo" or "design-system" or "cip"
```

---

## 5. Non-Functional Requirements

### NFR-1: Performance
- **Sync hook latency (no-op)**: < 500ms (read JSON timestamp, exit)
- **Sync hook latency (sync)**: < 10 seconds (copy files, validate, swap)
- **search.py query time**: < 2 seconds for any domain query
- **Measurement**: Time the hook via `time sync-upstream.sh`; time search.py via `time python3 scripts/search.py "test" --domain style`

### NFR-2: Reliability
- **Sync atomicity**: Data directory is NEVER in a partial state. Atomic rename guarantees either old OR new data, never mixed.
- **Rollback guarantee**: If validation fails, existing data is untouched.
- **Graceful degradation**: If Python unavailable, commands fall back to web-research-only mode.

### NFR-3: Maintainability
- **Single maintainer capacity**: All 32 commands maintainable by one person.
- **Upstream freshness**: Sync hook keeps CSVs within 7 days of upstream.
- **Schema validation**: Header checks catch column renames/removals.

### NFR-4: Compatibility
- **Python 3.6+**: Minimum Python version (f-strings, pathlib).
- **macOS primary**: Target platform. POSIX-compatible shell commands.
- **Claude Code**: Requires ${CLAUDE_PLUGIN_ROOT} variable support.

---

## 6. Detailed Design

### 6.1 Data Model — sync-state.json

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "type": "object",
  "required": ["last_sync", "upstream_source", "files_synced"],
  "properties": {
    "last_sync": {
      "type": "string",
      "format": "date-time",
      "description": "ISO 8601 timestamp of last successful sync"
    },
    "upstream_source": {
      "type": "string",
      "enum": ["local", "github"],
      "description": "Where data was synced from"
    },
    "upstream_path": {
      "type": "string",
      "description": "Filesystem path to upstream plugin"
    },
    "upstream_version": {
      "type": "string",
      "pattern": "^[0-9]+\\.[0-9]+\\.[0-9]+$",
      "description": "Semantic version of upstream at last sync"
    },
    "files_synced": {
      "type": "integer",
      "minimum": 0,
      "description": "Number of files copied in last sync"
    },
    "sync_frequency_days": {
      "type": "integer",
      "default": 7,
      "description": "Minimum days between syncs"
    }
  }
}
```

### 6.2 Data Model — plugin.json

```json
{
  "name": "healer",
  "version": "6.0.0",
  "description": "Universal Autonomous Codebase Health & Development Engine with Design Intelligence",
  "author": {
    "name": "WeaverBird LLC"
  },
  "license": "MIT",
  "keywords": ["healer", "development", "testing", "design", "brand", "UI", "UX"],
  "commands": ["./commands/"],
  "hooks": "./hooks/hooks.json"
}
```

### 6.3 Sync Script — sync-upstream.sh (pseudocode)

```bash
#!/usr/bin/env bash
set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(dirname "$0")/..}"
PLUGIN_DATA="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/healer}"
STATE_FILE="$PLUGIN_DATA/sync-state.json"
UPSTREAM_BASE="$HOME/.claude/plugins/marketplaces/ui-ux-pro-max-skill"
UPSTREAM_DATA="$UPSTREAM_BASE/src/ui-ux-pro-max/data"
HEALER_DATA="$PLUGIN_ROOT/data"

# Step 0: Check Python availability
if ! command -v python3 &>/dev/null; then
  echo "Healer sync: Python 3 required for data sync"
  exit 0
fi

# Step 1: Ensure data directory exists
mkdir -p "$PLUGIN_DATA"

# Step 2: Check staleness
if [ -f "$STATE_FILE" ]; then
  LAST_SYNC=$(python3 -c "
import json, sys
from datetime import datetime, timezone
state = json.load(open('$STATE_FILE'))
last = datetime.fromisoformat(state['last_sync'])
days = (datetime.now(timezone.utc) - last).days
print(days)
")
  FREQ=$(python3 -c "
import json; state = json.load(open('$STATE_FILE'))
print(state.get('sync_frequency_days', 7))
")
  if [ "$LAST_SYNC" -lt "$FREQ" ]; then
    exit 0  # Silent — no sync needed
  fi
fi

# Step 3: Check upstream exists
if [ ! -d "$UPSTREAM_DATA" ]; then
  exit 0  # Silent — upstream not installed
fi

# Step 4: Version check
UPSTREAM_VERSION="unknown"
if [ -f "$UPSTREAM_BASE/skill.json" ]; then
  UPSTREAM_VERSION=$(python3 -c "
import json; print(json.load(open('$UPSTREAM_BASE/skill.json')).get('version','unknown'))
")
fi
if [ -f "$STATE_FILE" ]; then
  OLD_VERSION=$(python3 -c "
import json; print(json.load(open('$STATE_FILE')).get('upstream_version','unknown'))
")
  OLD_MAJOR="${OLD_VERSION%%.*}"
  NEW_MAJOR="${UPSTREAM_VERSION%%.*}"
  if [ "$OLD_MAJOR" != "$NEW_MAJOR" ] && [ "$OLD_MAJOR" != "unknown" ]; then
    echo "Healer sync: upstream major version bump ($OLD_VERSION → $UPSTREAM_VERSION). Manual review recommended."
  fi
fi

# Step 5: Copy to staging
cp -r "$UPSTREAM_DATA" "${HEALER_DATA}.new"

# Step 6: Validate headers
VALID=true
for CHECK in \
  "styles.csv:Style Category" \
  "colors.csv:Product Type" \
  "typography.csv:Font Pairing Name" \
  "ux-guidelines.csv:Category"
do
  FILE="${CHECK%%:*}"
  HEADER="${CHECK##*:}"
  if [ -f "${HEALER_DATA}.new/$FILE" ]; then
    if ! head -1 "${HEALER_DATA}.new/$FILE" | grep -q "$HEADER"; then
      echo "Healer sync skipped: CSV schema mismatch in $FILE"
      rm -rf "${HEALER_DATA}.new"
      VALID=false
      break
    fi
  fi
done
[ "$VALID" = false ] && exit 0

# Step 7: Atomic swap
if [ -d "$HEALER_DATA" ]; then
  mv "$HEALER_DATA" "${HEALER_DATA}.backup"
fi
mv "${HEALER_DATA}.new" "$HEALER_DATA"
rm -rf "${HEALER_DATA}.backup"

# Step 8: Count files and update state
FILE_COUNT=$(find "$HEALER_DATA" -name "*.csv" | wc -l | tr -d ' ')
python3 -c "
import json
from datetime import datetime, timezone
state = {
  'last_sync': datetime.now(timezone.utc).isoformat(),
  'upstream_source': 'local',
  'upstream_path': '$UPSTREAM_BASE',
  'upstream_version': '$UPSTREAM_VERSION',
  'files_synced': $FILE_COUNT,
  'sync_frequency_days': 7
}
json.dump(state, open('$STATE_FILE', 'w'), indent=2)
"

echo "Healer data synced from UI-UX-Pro-Max v$UPSTREAM_VERSION ($FILE_COUNT CSV files)"
```

### 6.4 Command Template — New Command Structure

Each new command markdown file follows this skeleton:
```
---
description: "{one-line}"
---
**ENFORCEMENT: Read and apply all protocols from commands/_enforcement.md**

# Healer: {Name}

<HARD-GATE>...</HARD-GATE>

## Procedure
### Step 0: Check Prior Artifacts
### Step 0.5: Design Intelligence Lookup (LOCAL DATABASE)
### Step 1: Research Phase (WEB)
### Step N: {Command-specific work}
### Step N+1: Save Artifact

## Anti-Rationalization Table
## Red Flags
## Rules
```

### 6.5 Command Template — Enhanced Command Insertion

For the 5 enhanced commands, insert this block between existing Step 0 and Step 1:

```markdown
### Step 0.5: Design Intelligence Lookup (NEW)

Before proceeding to web research, query the local design database:

Run via Bash:
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query from $ARGUMENTS>" --design-system

For domain-specific lookups:
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --domain {relevant}

For stack-specific guidelines:
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<query>" --stack {detected}

DATA LOOKUP ORDER:
  1. CSV database (instant, offline) → baseline
  2. Web research (HARD-GATE still enforced) → current trends
  3. Merge both → final output
```

---

## 7. Error Catalog

| Code | Condition | User-Facing Message | Recovery Action |
|------|-----------|---------------------|-----------------|
| SYNC_001 | Python 3 not installed | "Healer sync: Python 3 required for data sync" | Install Python 3 or use web-research-only mode |
| SYNC_002 | Upstream not installed | (silent — no message) | Install UI-UX-Pro-Max or manually populate data/ |
| SYNC_003 | CSV schema mismatch | "Healer sync skipped: CSV schema mismatch in {file}" | Check upstream version, manually review changes |
| SYNC_004 | Major version bump | "Healer sync: upstream major version bump (X → Y). Manual review recommended." | Review changelog, verify compatibility |
| SYNC_005 | Atomic swap failure | "Healer sync failed: directory swap error" | Check disk space, permissions. data.backup/ preserved. |
| DATA_001 | search.py returns error | "Error: {message from search.py}" | Check CSV file integrity, re-run sync |
| DATA_002 | CSV file not found | "Error: file not found: data/{file}.csv" | Run sync or manually populate data/ |
| CMD_001 | Command invoked without data/ | Command falls back to web-research-only | Populate data/ via sync or manual copy |

---

## 8. Success Metrics (Strategy Recommendation #1)

Three measurable success signals:

| Metric | Baseline (before) | Target (after) | How to Measure |
|--------|-------------------|----------------|----------------|
| Plugin switch count | ~100+/week between Healer and UI-UX-Pro-Max | 0/week | Self-reported: count how many times you invoke UI-UX-Pro-Max directly |
| Visual flow completion time | Unmeasured | Measure time for /healer:flow visual end-to-end | Timestamp in .healer/state.json (start vs end) |
| Sync hook uptime | N/A | 30 days without manual intervention | Check sync-state.json: last_sync stays within 7 days of current date |

**Kill criteria**: If after 2 weeks the plugin switch count hasn't dropped below 20/week, the integration isn't solving the problem. Investigate why.

---

## 9. Implementation Plan (Wave-Based — Strategy Recommendation #3)

### Wave 1: Infrastructure + Pattern Validation (~3 hours AI-assisted)
1. Create `.claude-plugin/plugin.json`
2. Create `data/` directory — copy all CSVs from UI-UX-Pro-Max
3. Create `references/` directory — copy all reference docs
4. Create `scripts/` directory — copy search.py, core.py, design_system.py
5. Update core.py DATA_DIR if needed
6. Verify: `python3 scripts/search.py "test" --domain style` works
7. Create `hooks/hooks.json` with SessionStart sync hook
8. Create `scripts/sync-upstream.sh`
9. Write ONE new command: `healer:brand.md`
10. Enhance ONE existing command: `healer:design-system.md` (add Step 0.5)
11. Test both commands end-to-end

**Gate: USE Wave 1 for one week before proceeding.**

### Wave 2: Remaining New Commands (~4 hours AI-assisted)
12. Write `healer:logo.md`
13. Write `healer:cip.md`
14. Write `healer:banner.md`
15. Write `healer:icon.md`
16. Write `healer:slides.md`
17. Test each command individually

### Wave 3: Remaining Enhanced Commands (~4 hours AI-assisted)
18. Enhance `healer:design.md` (add Step 0.5)
19. Enhance `healer:design-review.md` (add UX guidelines)
20. Enhance `healer:implement.md` (add stack guidelines)
21. Enhance `healer:audit.md` (add UX audit dimensions)
22. Test each enhanced command

### Wave 4: Flow + Help + Polish (~2 hours AI-assisted)
23. Update `healer:flow.md` — add identity, brand-to-production presets
24. Update `healer:flow.md` — enhance visual preset
25. Update `config/recipes.yaml` — add 4 new recipes
26. Update `healer:help.md` — document everything
27. Update `healer.md` — add 6 new sub-commands to listing
28. Update `README.md` — document new capabilities and MIT attribution
29. Full end-to-end test: `/healer:flow identity`

---

## 10. Testing Strategy

### 10.1 Infrastructure Tests
- Verify all CSV files present and parseable
- Verify search.py works for each domain (style, color, chart, etc.)
- Verify sync hook handles all 6 scenarios from FR-4

### 10.2 Command Tests
- Invoke each new command with sample input
- Verify CSV lookup occurs (check Bash tool calls)
- Verify web research still occurs (HARD-GATE compliance)
- Verify output follows Healer format (not UI-UX-Pro-Max format)

### 10.3 Flow Tests
- Run `/healer:flow identity` end-to-end
- Run `/healer:flow visual` end-to-end
- Verify gate operators work correctly
- Verify state.json updates at each step

### 10.4 Regression Tests
- Run each of the 26 EXISTING commands
- Verify zero behavior changes (REQ-C01)
- Verify _enforcement.md is unmodified (REQ-C02)

---

## 11. Rollout Plan

### 11.1 Deployment Strategy
- Wave-based deployment (4 waves, 1 week between Wave 1 and Wave 2)
- Each wave is a separate git commit
- No feature flags needed (purely additive)

### 11.2 Rollback Criteria
Roll back if ANY:
- Existing commands break (regression)
- Sync hook blocks session start for >10 seconds
- search.py crashes on valid queries
- More than 3 commands produce incorrect output in one session

### 11.3 Rollback Procedure
1. `git revert` the wave commit
2. Remove data/, references/, scripts/, hooks/ directories
3. Verify existing 26 commands still work
4. Investigate and fix before re-attempting

---

## 12. Requirements Traceability Matrix

| Req ID | Requirement | Traces To | Spec Section | Acceptance Criteria | Test | Error Codes |
|--------|------------|-----------|-------------|--------------------|----|------------|
| FR-1 | Data directory | REQ-F01, D1 | 6.1 | 2 scenarios | 10.1 | DATA_002 |
| FR-2 | Reference docs | REQ-F02 | 4 | 1 scenario | 10.1 | — |
| FR-3 | Python scripts | REQ-F03, D2 | 6.3 | 3 scenarios | 10.1 | DATA_001 |
| FR-4 | Sync hook | REQ-F04/F05, D4-D7 | 6.3 | 6 scenarios | 10.1 | SYNC_001-005 |
| FR-5 | Plugin manifest | Open Q #1 | 6.2 | 2 scenarios | 10.1 | — |
| FR-6 | healer:brand | REQ-F06 | 6.4 | 2 scenarios | 10.2 | CMD_001 |
| FR-7 | healer:logo | REQ-F07 | 6.4 | 1 scenario | 10.2 | CMD_001 |
| FR-8 | healer:cip | REQ-F08 | 6.4 | 1 scenario | 10.2 | CMD_001 |
| FR-9 | healer:banner | REQ-F09 | 6.4 | 1 scenario | 10.2 | CMD_001 |
| FR-10 | healer:icon | REQ-F10 | 6.4 | 1 scenario | 10.2 | CMD_001, DATA_001 |
| FR-11 | healer:slides | REQ-F11 | 6.4 | 1 scenario | 10.2 | CMD_001, DATA_001 |
| FR-12 | design enhanced | REQ-F12 | 6.5 | 2 scenarios | 10.2 | CMD_001 |
| FR-13 | design-system enhanced | REQ-F13 | 6.5 | 1 scenario | 10.2 | CMD_001 |
| FR-14 | design-review enhanced | REQ-F14 | 6.5 | 1 scenario | 10.2 | CMD_001 |
| FR-15 | implement enhanced | REQ-F15 | 6.5 | 1 scenario | 10.2 | CMD_001 |
| FR-16 | audit enhanced | REQ-F16 | 6.5 | 1 scenario | 10.2 | CMD_001 |
| FR-17 | Flow presets new | REQ-F17 | 5 | 2 scenarios | 10.3 | — |
| FR-18 | Visual preset enhanced | REQ-F17 | 5 | 1 scenario | 10.3 | — |
| FR-19 | Flow recipes | REQ-F17 | 5 | 2 scenarios | 10.3 | — |
| FR-20 | Help update | REQ-F19 | — | 1 scenario | 10.2 | — |
| FR-21 | healer.md update | REQ-F20 | — | 1 scenario | 10.4 | — |
| FR-22 | Suggested-next update | Design 5 | — | 1 scenario | 10.3 | — |
| NFR-1 | Performance | REQ-NF02 | 5 | Latency targets | 10.1 | — |
| NFR-2 | Reliability | REQ-C04 | 5 | Atomic swap | 10.1 | SYNC_005 |
| NFR-3 | Maintainability | Strategy | 5 | Wave deployment | 10.4 | — |
| NFR-4 | Compatibility | REQ-C03 | 5 | Python 3.6+ | 10.1 | SYNC_001 |

**Traceability gaps: 0** — all requirements traced end-to-end.

---

## 13. Alternatives Considered

| Alternative | Pros | Cons | Why Rejected |
|-------------|------|------|-------------|
| Git subtree | Native git sync, full history | Verbose commands, UI-UX-Pro-Max repo structure doesn't map cleanly | Adds complexity with marginal benefit over shell-based sync |
| Embed CSV data in markdown | No external files, simpler structure | Massive markdown files, can't use BM25 search, unmaintainable | User explicitly chose B (separate CSVs) |
| MCP server for search | Universal access across all tools | Additional complexity, server startup overhead | Deferred to future 10x enhancement |
| Symlink to UI-UX-Pro-Max install | Zero copy, always fresh | Plugin cache isolation breaks symlinks | Technically impossible per Claude Code docs |
| Wrapper commands that call UI-UX-Pro-Max | No data duplication | Plugin path traversal blocked, can't reference external plugin | Technically impossible per Claude Code docs |

---

## 14. Open Questions
None remaining — all resolved in prior phases.
