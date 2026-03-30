#!/usr/bin/env bash
# Healer v6 — Upstream Sync Script
# Syncs CSV data from UI-UX-Pro-Max plugin installation.
# Called by SessionStart hook. Silent on no-op, reports on sync.
set -euo pipefail

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"
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

# Step 1: Ensure persistent data directory exists
mkdir -p "$PLUGIN_DATA"

# Step 2: Check staleness — skip if synced recently
if [ -f "$STATE_FILE" ]; then
  DAYS_SINCE=$(python3 -c "
import json, sys
from datetime import datetime, timezone
try:
    state = json.load(open('$STATE_FILE'))
    last = datetime.fromisoformat(state['last_sync'].replace('Z', '+00:00'))
    days = (datetime.now(timezone.utc) - last).days
    print(days)
except:
    print(999)
" 2>/dev/null || echo "999")

  FREQ=$(python3 -c "
import json
try:
    state = json.load(open('$STATE_FILE'))
    print(state.get('sync_frequency_days', 7))
except:
    print(7)
" 2>/dev/null || echo "7")

  if [ "$DAYS_SINCE" -lt "$FREQ" ] 2>/dev/null; then
    exit 0  # Silent — no sync needed
  fi
fi

# Step 3: Check upstream exists
if [ ! -d "$UPSTREAM_DATA" ]; then
  exit 0  # Silent — upstream not installed
fi

# Step 4: Version check — warn on major version bump
UPSTREAM_VERSION="unknown"
if [ -f "$UPSTREAM_BASE/skill.json" ]; then
  UPSTREAM_VERSION=$(python3 -c "
import json
try:
    print(json.load(open('$UPSTREAM_BASE/skill.json')).get('version', 'unknown'))
except:
    print('unknown')
" 2>/dev/null || echo "unknown")
fi

if [ -f "$STATE_FILE" ]; then
  OLD_VERSION=$(python3 -c "
import json
try:
    print(json.load(open('$STATE_FILE')).get('upstream_version', 'unknown'))
except:
    print('unknown')
" 2>/dev/null || echo "unknown")

  if [ "$OLD_VERSION" != "unknown" ] && [ "$UPSTREAM_VERSION" != "unknown" ]; then
    OLD_MAJOR="${OLD_VERSION%%.*}"
    NEW_MAJOR="${UPSTREAM_VERSION%%.*}"
    if [ "$OLD_MAJOR" != "$NEW_MAJOR" ]; then
      echo "Healer sync: upstream major version bump ($OLD_VERSION -> $UPSTREAM_VERSION). Manual review recommended."
    fi
  fi
fi

# Step 5: Copy upstream data to staging directory
rm -rf "${HEALER_DATA}.new"
cp -r "$UPSTREAM_DATA" "${HEALER_DATA}.new"

# Step 6: Validate CSV headers on key files
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
      echo "Healer sync skipped: CSV schema mismatch in $FILE (expected '$HEADER' in header)"
      rm -rf "${HEALER_DATA}.new"
      VALID=false
      break
    fi
  fi
done

if [ "$VALID" = false ]; then
  exit 0
fi

# Step 7: Atomic directory swap
if [ -d "$HEALER_DATA" ]; then
  mv "$HEALER_DATA" "${HEALER_DATA}.backup"
fi
mv "${HEALER_DATA}.new" "$HEALER_DATA"
rm -rf "${HEALER_DATA}.backup"

# Step 8: Also sync reference docs if upstream has them
UPSTREAM_SKILLS="$UPSTREAM_BASE/.claude/skills"
HEALER_REFS="$PLUGIN_ROOT/references"
if [ -d "$UPSTREAM_SKILLS/brand/references" ] && [ -d "$HEALER_REFS" ]; then
  cp "$UPSTREAM_SKILLS/brand/references/"*.md "$HEALER_REFS/brand/" 2>/dev/null || true
  for skill_dir in design design-system ui-styling slides banner-design; do
    src_dir="$UPSTREAM_SKILLS/$skill_dir/references"
    if [ -d "$src_dir" ]; then
      target="$HEALER_REFS/${skill_dir/banner-design/slides}"
      [ -d "$target" ] && cp "$src_dir/"*.md "$target/" 2>/dev/null || true
    fi
  done
fi

# Step 9: Count files and update state
FILE_COUNT=$(find "$HEALER_DATA" -name "*.csv" 2>/dev/null | wc -l | tr -d ' ')

python3 -c "
import json
from datetime import datetime, timezone
state = {
    'last_sync': datetime.now(timezone.utc).isoformat(),
    'upstream_source': 'local',
    'upstream_path': '$UPSTREAM_BASE',
    'upstream_version': '$UPSTREAM_VERSION',
    'files_synced': int('$FILE_COUNT'),
    'sync_frequency_days': 7
}
json.dump(state, open('$STATE_FILE', 'w'), indent=2)
"

echo "Healer data synced from UI-UX-Pro-Max v$UPSTREAM_VERSION ($FILE_COUNT CSV files)"
