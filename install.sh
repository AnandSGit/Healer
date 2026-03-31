#!/bin/bash
# Healer v6 — Install Script
# Registers Healer as a Claude Code plugin (marketplace)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
CLAUDE_COMMANDS="$HOME/.claude/commands"
HEALER_CONFIG="$HOME/.healer"

echo "═══════════════════════════════════════════════════"
echo "  Healer v6 — Universal Development Lifecycle Engine"
echo "  with Design Intelligence"
echo "  36 commands | 11 flow presets | 24+ recipes"
echo "  161 palettes | 57 fonts | 99 UX guidelines"
echo "═══════════════════════════════════════════════════"
echo ""

# Ensure Claude settings exist
if [ ! -f "$CLAUDE_SETTINGS" ]; then
  echo "Error: Claude Code settings not found at $CLAUDE_SETTINGS"
  echo "Please install Claude Code first."
  exit 1
fi

# ─── Step 1: Clean up old raw command files ───
echo "Cleaning up old installation (raw command files)..."
OLD_COUNT=0
for f in "$CLAUDE_COMMANDS"/healer*.md "$CLAUDE_COMMANDS"/_enforcement.md; do
  if [ -f "$f" ]; then
    rm "$f"
    OLD_COUNT=$((OLD_COUNT + 1))
  fi
done
if [ "$OLD_COUNT" -gt 0 ]; then
  echo "  ✅ Removed $OLD_COUNT old command files from $CLAUDE_COMMANDS/"
else
  echo "  ✅ No old files to clean up"
fi

# ─── Step 2: Register Healer as a local marketplace ───
echo "Registering Healer plugin..."

# Use python3 to safely modify settings.json
python3 << PYEOF
import json, sys

settings_path = "$CLAUDE_SETTINGS"
healer_path = "$SCRIPT_DIR"

with open(settings_path, 'r') as f:
    settings = json.load(f)

# Add marketplace source
if 'extraKnownMarketplaces' not in settings:
    settings['extraKnownMarketplaces'] = {}

settings['extraKnownMarketplaces']['healer'] = {
    'source': {
        'source': 'directory',
        'path': healer_path
    }
}

# Enable the plugin
if 'enabledPlugins' not in settings:
    settings['enabledPlugins'] = {}

settings['enabledPlugins']['healer@healer'] = True

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2)
    f.write('\n')

print("  ✅ Marketplace registered: healer → " + healer_path)
print("  ✅ Plugin enabled: healer@healer")
PYEOF

# ─── Step 3: Install supporting data files ───
mkdir -p "$HEALER_CONFIG"

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

# Copy docs
echo "Installing documentation..."
cp "$SCRIPT_DIR/docs/healer-user-guide.html" "$HEALER_CONFIG/" 2>/dev/null || true
echo "  ✅ Documentation installed"

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Installation complete!"
echo ""
echo "  Plugin:     healer@healer (registered in settings.json)"
echo "  Source:     $SCRIPT_DIR"
echo "  Recipes:    $HEALER_CONFIG/recipes.yaml"
echo "  Data:       $HEALER_CONFIG/data/ ($CSV_COUNT CSVs)"
echo "  References: $HEALER_CONFIG/references/ ($REF_COUNT docs)"
echo "  Scripts:    $HEALER_CONFIG/scripts/"
echo ""
echo "  ⚠️  Restart Claude Code for the plugin to take effect."
echo ""
echo "  Core Commands:"
echo "    /healer                # Full autonomous heal"
echo "    /healer:diagnose       # Health check"
echo "    /healer:flow feature   # Feature pipeline"
echo "    /healer:flow ideate    # Full ideation pipeline"
echo ""
echo "  Design Intelligence:"
echo "    /healer:brand          # Brand voice + identity"
echo "    /healer:logo           # Logo design brief"
echo "    /healer:design-system  # Design system (enhanced)"
echo "    /healer:flow visual    # Brand → design → review"
echo "    /healer:flow identity  # Brand → logo → CIP → system"
echo ""
echo "  Open user guide:"
echo "    open $HEALER_CONFIG/healer-user-guide.html"
echo "═══════════════════════════════════════════════════"
