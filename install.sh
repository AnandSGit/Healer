#!/bin/bash
# Healer — Install Script
# Registers Healer as a Claude Code plugin (marketplace)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
CLAUDE_COMMANDS="$HOME/.claude/commands"
HEALER_CONFIG="$HOME/.healer"
HEALER_VERSION=$(HEALER_ROOT="$SCRIPT_DIR" python3 -c 'import json,os; d=os.environ["HEALER_ROOT"]; p=os.path.join(d,".claude-plugin","plugin.json"); p=p if os.path.exists(p) else os.path.join(d,"plugin.json"); print(json.load(open(p))["version"])')

echo "═══════════════════════════════════════════════════"
echo "  Healer v${HEALER_VERSION} — Universal Development Lifecycle Engine"
echo "  with Karpathy Enforcement + Deep-Research & Options-First"
echo "  44 commands | 27 flow presets | 8-category research matrix"
echo "  max-choice options (brainstorm:7 / design-UI:10 / spec:5 / plan:4)"
echo "  HTML option galleries for UI | 161 palettes | 57 fonts | 99 UX"
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

# Use python3 to safely modify settings.json and installed_plugins.json.
# Paths are passed via the environment (not interpolated into the source) so
# they survive repo paths containing quotes/backslashes.
CLAUDE_SETTINGS="$CLAUDE_SETTINGS" SCRIPT_DIR="$SCRIPT_DIR" python3 << 'PYEOF'
import json, sys, os
from datetime import datetime, timezone

settings_path = os.environ["CLAUDE_SETTINGS"]
healer_path = os.environ["SCRIPT_DIR"]
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
manifest_path = os.path.join(healer_path, ".claude-plugin", "plugin.json")
if not os.path.exists(manifest_path):
    manifest_path = os.path.join(healer_path, "plugin.json")
with open(manifest_path) as f:
    plugin_manifest = json.load(f)
healer_version = plugin_manifest["version"]

plugins['healer@healer'] = [{
    "scope": "user",
    "installPath": healer_path,
    "version": healer_version,
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

# ─── Step 4: Install Python dependencies for help catalog ───
echo "Installing help catalog dependencies (PyYAML + jsonschema)..."
if python3 -c "import yaml, jsonschema" 2>/dev/null; then
  echo "  ✅ Dependencies already present"
else
  pip3 install --quiet --user pyyaml jsonschema 2>&1 | tail -3 || {
    echo "  ⚠️  Failed to install help catalog dependencies."
    echo "      The \`?\` postfix help system requires PyYAML and jsonschema."
    echo "      Install manually: pip3 install --user pyyaml jsonschema"
  }
  if python3 -c "import yaml, jsonschema" 2>/dev/null; then
    echo "  ✅ Dependencies installed"
  fi
fi

# ─── Step 5: Build help index ───
echo "Building help catalog index..."
if bash "$SCRIPT_DIR/scripts/build-help-index.sh" >/dev/null 2>&1; then
  INDEX_SIZE=$(wc -c < "$SCRIPT_DIR/data/help-index.json" 2>/dev/null | tr -d ' ')
  if [ -n "$INDEX_SIZE" ]; then
    INDEX_KB=$((INDEX_SIZE / 1024))
    echo "  ✅ Help index built ($INDEX_KB KB)"
    echo "  ✨ Try: /healer:flow ?  (or any /healer:<command> ?)"
  fi
else
  echo "  ⚠️  Help index build failed — \`?\` postfix help may be slow."
  echo "      Run manually: bash $SCRIPT_DIR/scripts/build-help-index.sh"
fi

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
echo "    /healer:verify         # Functional verification (9 dimensions)"
echo "    /healer:karpathy       # Karpathy-lens code review (P1-P4)"
echo "    /healer:flow feature   # Feature pipeline"
echo "    /healer:flow ideate    # Full ideation pipeline"
echo ""
echo "  Imitate & Flow Testing (v8.1 — Style DNA + Adapt):"
echo "    /healer:imitate               # Reverse-engineer all 5 layers into 4-in-1 doc"
echo "    /healer:imitate --layer=frontend  # Scope: frontend | backend | server | db | ai"
echo "    /healer:imitate --deep-style  # NEW: style-dna + exhaustive pages + rendered"
echo "    /healer:imitate --full        # 10x: Mermaid, risk, timeline, impact, diff"
echo "    /healer:adapt <StyleDNA.yaml> # NEW: replicate source style onto target project"
echo "    /healer:adapt ... --plan-only # NEW: preview adaptation plan (zero writes)"
echo "    /healer:adapt ... --full      # NEW: full rewrite incl. page compositions"
echo "    /healer:indulge               # Test every flow (6 dimensions)"
echo "    /healer:indulge --full        # 10x: visual, a11y, security, perf, dashboard"
echo "    /healer:flow imitate-test     # Imitate → test pipeline"
echo "    /healer:flow imitate-onboard  # Full onboarding + CLAUDE.md"
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
echo ""
echo "  To uninstall:"
echo "    ./uninstall.sh           # unregister plugin (keeps your ~/.healer data)"
echo "    ./uninstall.sh --purge   # also remove ~/.healer + synced design data"
echo "═══════════════════════════════════════════════════"
