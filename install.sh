#!/bin/bash
# Healer v3 — Install Script
# Copies commands to Claude Code global commands directory

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_COMMANDS="$HOME/.claude/commands"
HEALER_CONFIG="$HOME/.healer"

echo "═══════════════════════════════════════════════════"
echo "  Healer v3 — Universal Development Lifecycle Engine"
echo "═══════════════════════════════════════════════════"
echo ""

# Create directories
mkdir -p "$CLAUDE_COMMANDS"
mkdir -p "$HEALER_CONFIG"

# Copy commands
echo "Installing 25 commands to $CLAUDE_COMMANDS..."
cp "$SCRIPT_DIR/commands/"healer*.md "$CLAUDE_COMMANDS/"
echo "  ✅ Commands installed"

# Copy config
echo "Installing recipes to $HEALER_CONFIG..."
cp "$SCRIPT_DIR/config/recipes.yaml" "$HEALER_CONFIG/"
echo "  ✅ Recipes installed"

# Copy docs
echo "Installing user guide to $HEALER_CONFIG..."
cp "$SCRIPT_DIR/docs/healer-user-guide.html" "$HEALER_CONFIG/"
echo "  ✅ User guide installed"

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Installation complete!"
echo ""
echo "  Commands:  $CLAUDE_COMMANDS/healer*.md (25 files)"
echo "  Recipes:   $HEALER_CONFIG/recipes.yaml"
echo "  Guide:     $HEALER_CONFIG/healer-user-guide.html"
echo ""
echo "  Usage:"
echo "    /healer              # Full autonomous heal"
echo "    /healer:diagnose     # Health check"
echo "    /healer:flow feature # Feature pipeline"
echo ""
echo "  Open user guide:"
echo "    open $HEALER_CONFIG/healer-user-guide.html"
echo "═══════════════════════════════════════════════════"
