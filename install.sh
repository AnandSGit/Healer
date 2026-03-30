#!/bin/bash
# Healer v6 — Install Script
# Installs commands, data, references, scripts, hooks to Claude Code

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_COMMANDS="$HOME/.claude/commands"
HEALER_CONFIG="$HOME/.healer"

echo "═══════════════════════════════════════════════════"
echo "  Healer v6 — Universal Development Lifecycle Engine"
echo "  with Design Intelligence"
echo "  32 commands | 11 flow presets | 24+ recipes"
echo "  161 palettes | 57 fonts | 99 UX guidelines"
echo "═══════════════════════════════════════════════════"
echo ""

# Create directories
mkdir -p "$CLAUDE_COMMANDS"
mkdir -p "$HEALER_CONFIG"

# Copy enforcement layer first
echo "Installing enforcement protocol..."
cp "$SCRIPT_DIR/commands/_enforcement.md" "$CLAUDE_COMMANDS/"
echo "  ✅ Enforcement protocol"

# Copy commands
CMD_COUNT=$(ls "$SCRIPT_DIR/commands/"healer*.md 2>/dev/null | wc -l | tr -d ' ')
echo "Installing $CMD_COUNT commands..."
cp "$SCRIPT_DIR/commands/"healer*.md "$CLAUDE_COMMANDS/"
echo "  ✅ $CMD_COUNT commands installed"

# Copy config
echo "Installing recipes..."
cp "$SCRIPT_DIR/config/recipes.yaml" "$HEALER_CONFIG/"
echo "  ✅ Recipes installed"

# Copy data (design intelligence CSVs)
if [ -d "$SCRIPT_DIR/data" ]; then
  echo "Installing design intelligence data..."
  mkdir -p "$HEALER_CONFIG/data/stacks"
  cp "$SCRIPT_DIR/data/"*.csv "$HEALER_CONFIG/data/" 2>/dev/null || true
  cp "$SCRIPT_DIR/data/stacks/"*.csv "$HEALER_CONFIG/data/stacks/" 2>/dev/null || true
  CSV_COUNT=$(find "$HEALER_CONFIG/data" -name "*.csv" | wc -l | tr -d ' ')
  echo "  ✅ $CSV_COUNT CSV data files installed"
fi

# Copy references
if [ -d "$SCRIPT_DIR/references" ]; then
  echo "Installing reference documents..."
  cp -r "$SCRIPT_DIR/references" "$HEALER_CONFIG/"
  REF_COUNT=$(find "$HEALER_CONFIG/references" -name "*.md" | wc -l | tr -d ' ')
  echo "  ✅ $REF_COUNT reference docs installed"
fi

# Copy scripts (search engine)
if [ -d "$SCRIPT_DIR/scripts" ]; then
  echo "Installing search engine scripts..."
  mkdir -p "$HEALER_CONFIG/scripts"
  cp "$SCRIPT_DIR/scripts/"*.py "$HEALER_CONFIG/scripts/" 2>/dev/null || true
  cp "$SCRIPT_DIR/scripts/"*.sh "$HEALER_CONFIG/scripts/" 2>/dev/null || true
  chmod +x "$HEALER_CONFIG/scripts/"*.sh 2>/dev/null || true
  echo "  ✅ Search engine installed"
fi

# Copy hooks
if [ -d "$SCRIPT_DIR/hooks" ]; then
  echo "Installing hooks..."
  mkdir -p "$HEALER_CONFIG/hooks"
  cp "$SCRIPT_DIR/hooks/"*.json "$HEALER_CONFIG/hooks/" 2>/dev/null || true
  echo "  ✅ Hooks installed"
fi

# Copy docs
echo "Installing documentation..."
cp "$SCRIPT_DIR/docs/healer-user-guide.html" "$HEALER_CONFIG/" 2>/dev/null || true
echo "  ✅ Documentation installed"

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Installation complete!"
echo ""
echo "  Commands:    $CLAUDE_COMMANDS/healer*.md ($CMD_COUNT files)"
echo "  Enforce:     $CLAUDE_COMMANDS/_enforcement.md"
echo "  Recipes:     $HEALER_CONFIG/recipes.yaml"
echo "  Data:        $HEALER_CONFIG/data/ ($CSV_COUNT CSVs)"
echo "  References:  $HEALER_CONFIG/references/ ($REF_COUNT docs)"
echo "  Scripts:     $HEALER_CONFIG/scripts/"
echo "  Hooks:       $HEALER_CONFIG/hooks/"
echo ""
echo "  Core Commands:"
echo "    /healer                # Full autonomous heal"
echo "    /healer:diagnose       # Health check"
echo "    /healer:flow feature   # Feature pipeline"
echo "    /healer:flow ideate    # Full ideation pipeline"
echo ""
echo "  Design Intelligence (NEW in v6):"
echo "    /healer:brand          # Brand voice + identity"
echo "    /healer:logo           # Logo design brief"
echo "    /healer:design-system  # Design system (enhanced)"
echo "    /healer:flow visual    # Brand → design → review"
echo "    /healer:flow identity  # Brand → logo → CIP → system"
echo ""
echo "  Open user guide:"
echo "    open $HEALER_CONFIG/healer-user-guide.html"
echo "═══════════════════════════════════════════════════"
