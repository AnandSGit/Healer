#!/usr/bin/env bash
# help_catalog_hook.sh — PostToolUse hook for keeping help-index.json fresh
#
# Triggered by Write|Edit on any file. Activates only when the touched file is
# part of the help catalog: commands/*.md, data/commands.yaml, data/flows.yaml,
# data/schema/*.json. Otherwise exits silently.
#
# On activation:
#   1. Run drift check (commands/*.md ↔ commands.yaml bijection)
#   2. Rebuild data/help-index.json
#   3. If anything fails, print loud error to stderr and exit non-zero
#      (PostToolUse can't undo the edit, but the loud error gets the user's
#       attention so they know to fix the drift)
#
# Receives via env (Claude Code passes tool_input as JSON in $CLAUDE_TOOL_INPUT
# or as positional arg). We accept either to be robust.
set -uo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Extract edited path — first try positional arg, then env var, then stdin JSON
EDITED_PATH="${1:-${CLAUDE_TOOL_INPUT_PATH:-}}"
if [ -z "$EDITED_PATH" ] && [ ! -t 0 ]; then
  # Read JSON from stdin, extract file_path field
  EDITED_PATH="$(python3 -c "
import json, sys
try:
    data = json.load(sys.stdin)
    inp = data.get('tool_input', data)
    print(inp.get('file_path', '') or inp.get('path', ''))
except Exception:
    pass
" 2>/dev/null || echo "")"
fi

# If we still don't know which file, exit silently — we'd rather miss a
# rebuild than spam errors on every unrelated edit.
if [ -z "$EDITED_PATH" ]; then
  exit 0
fi

# Path filter — only react to catalog-relevant edits.
# Accept absolute paths from Claude Code OR relative paths from manual testing.
case "$EDITED_PATH" in
  *commands/*.md)
    ;;
  *data/commands.yaml|*data/flows.yaml)
    ;;
  *data/schema/*.json)
    ;;
  *)
    # Unrelated edit — silent exit
    exit 0
    ;;
esac

# Activated path — rebuild index. Capture output for diagnostics.
BUILD_OUT="$(python3 "$ROOT/scripts/build_help_index.py" 2>&1)"
BUILD_RC=$?

if [ $BUILD_RC -ne 0 ]; then
  echo "" >&2
  echo "════════════════════════════════════════════════════════════" >&2
  echo "  ⚠️  HEALER HELP CATALOG HOOK — REBUILD FAILED" >&2
  echo "════════════════════════════════════════════════════════════" >&2
  echo "" >&2
  echo "  File edited: $EDITED_PATH" >&2
  echo "" >&2
  echo "  Build output:" >&2
  echo "$BUILD_OUT" | sed 's/^/    /' >&2
  echo "" >&2
  echo "  The edit was applied but the help index is now stale or invalid." >&2
  echo "  Fix the underlying issue and re-run:" >&2
  echo "    bash $ROOT/scripts/build-help-index.sh" >&2
  echo "" >&2
  echo "════════════════════════════════════════════════════════════" >&2
  exit $BUILD_RC
fi

# Success — silent (don't spam on every successful edit)
exit 0
