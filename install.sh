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
echo "  38 commands | 14 flow presets | 24+ recipes"
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

# Use python3 to safely modify settings.json and installed_plugins.json
python3 << PYEOF
import json, sys, os
from datetime import datetime, timezone

settings_path = "$CLAUDE_SETTINGS"
healer_path = "$SCRIPT_DIR"
installed_path = os.path.join(os.path.dirname(settings_path), "plugins", "installed_plugins.json")

# --- Update settings.json ---
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

# --- Update installed_plugins.json ---
if os.path.exists(installed_path):
    with open(installed_path, 'r') as f:
        installed = json.load(f)
else:
    installed = {"version": 2, "plugins": {}}

plugins = installed.setdefault('plugins', {})
now = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%S.000Z')
plugins['healer@healer'] = [{
    "scope": "user",
    "installPath": healer_path,
    "version": "6.0.0",
    "installedAt": now,
    "lastUpdated": now
}]

with open(installed_path, 'w') as f:
    json.dump(installed, f, indent=2)
    f.write('\n')

print("  ✅ Plugin registered in installed_plugins.json")
PYEOF

# ─── Step 3: Install user-local files ───
# Note: Commands access data/references/scripts via ${CLAUDE_PLUGIN_ROOT}
# (resolved by the plugin system to $SCRIPT_DIR). Only user-local state
# (recipes, brainstorms, research) lives in ~/.healer/.
mkdir -p "$HEALER_CONFIG"

# Copy user recipes (custom flow pipelines)
echo "Installing recipes..."
cp "$SCRIPT_DIR/config/recipes.yaml" "$HEALER_CONFIG/"
echo "  ✅ Recipes installed to $HEALER_CONFIG/recipes.yaml"

# Create user state directories
mkdir -p "$HEALER_CONFIG/brainstorms"
mkdir -p "$HEALER_CONFIG/research"
mkdir -p "$HEALER_CONFIG/validations"
mkdir -p "$HEALER_CONFIG/strategies"
echo "  ✅ State directories created"

# Copy user guide
echo "Installing documentation..."
cp "$SCRIPT_DIR/docs/healer-user-guide.html" "$HEALER_CONFIG/" 2>/dev/null || true
echo "  ✅ Documentation installed"

# Count plugin assets (accessed via ${CLAUDE_PLUGIN_ROOT})
CSV_COUNT=$(find "$SCRIPT_DIR/data" -name "*.csv" 2>/dev/null | wc -l | tr -d ' ')
REF_COUNT=$(find "$SCRIPT_DIR/references" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Installation complete!"
echo ""
echo "  Plugin:     healer@healer (registered in settings.json)"
echo "  Source:     $SCRIPT_DIR"
echo "  Recipes:    $HEALER_CONFIG/recipes.yaml"
echo "  Data:       $CSV_COUNT CSVs (via plugin root)"
echo "  References: $REF_COUNT docs (via plugin root)"
echo "  Scripts:    search engine + sync (via plugin root)"
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
