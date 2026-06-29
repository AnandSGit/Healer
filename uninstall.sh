#!/bin/bash
# Healer — Uninstall Script
# Reverses install.sh: unregisters the Healer Claude Code plugin/marketplace and
# (optionally) removes user-local state under ~/.healer.
#
# Usage:
#   ./uninstall.sh           # unregister plugin; PRESERVE ~/.healer user data
#   ./uninstall.sh --purge   # additionally delete ~/.healer + synced design data
#   ./uninstall.sh --help

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_SETTINGS="$HOME/.claude/settings.json"
CLAUDE_COMMANDS="$HOME/.claude/commands"
HEALER_CONFIG="$HOME/.healer"
# Mirror the override honored by scripts/sync-upstream.sh so --purge finds the real dir.
SYNC_STATE_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/healer}"

PURGE=0
for arg in "$@"; do
  case "$arg" in
    --purge|--all) PURGE=1 ;;
    -h|--help)
      echo "Healer uninstaller — reverses install.sh"
      echo ""
      echo "Usage: ./uninstall.sh [--purge]"
      echo ""
      echo "  (no flags)   Unregister the plugin from Claude Code."
      echo "               Preserves your ~/.healer data (recipes, brainstorms,"
      echo "               research, validations, strategies)."
      echo "  --purge      Additionally delete ~/.healer and synced design data."
      echo "  --help       Show this help."
      exit 0 ;;
    *)
      echo "Unknown option: $arg (try ./uninstall.sh --help)" >&2
      exit 1 ;;
  esac
done

echo "═══════════════════════════════════════════════════"
echo "  Healer — Uninstall"
echo "═══════════════════════════════════════════════════"
echo ""

# ─── Step 1: Unregister plugin from settings.json + installed_plugins.json ───
if [ -f "$CLAUDE_SETTINGS" ]; then
  echo "Unregistering Healer plugin..."
  # Best-effort: if python3 is missing or a file is read-only, keep going so the
  # legacy-file cleanup and (with --purge) data removal still run.
  python3 << 'PYEOF' || echo "  ⚠️  Plugin-unregister step failed (continuing with cleanup)."
import json, os

settings_path = os.path.join(os.environ["HOME"], ".claude", "settings.json")
installed_path = os.path.join(os.path.dirname(settings_path), "plugins", "installed_plugins.json")

# --- settings.json: drop marketplace source + enabled flag, keep everything else ---
try:
    with open(settings_path) as f:
        settings = json.load(f)
except (FileNotFoundError, json.JSONDecodeError):
    settings = None

if settings is None:
    print("  ⚠️  settings.json missing or unparseable — skipped (left untouched)")
else:
    changed = False
    mkts = settings.get("extraKnownMarketplaces")
    if isinstance(mkts, dict) and "healer" in mkts:
        del mkts["healer"]
        changed = True
        if not mkts:
            settings.pop("extraKnownMarketplaces", None)
    enabled = settings.get("enabledPlugins")
    if isinstance(enabled, dict) and "healer@healer" in enabled:
        del enabled["healer@healer"]
        changed = True
        if not enabled:
            settings.pop("enabledPlugins", None)
    if changed:
        with open(settings_path, "w") as f:
            json.dump(settings, f, indent=2)
            f.write("\n")
        print("  ✅ Removed marketplace + enabledPlugins entry from settings.json")
    else:
        print("  ✅ No Healer entries in settings.json (already clean)")

# --- installed_plugins.json ---
if os.path.exists(installed_path):
    try:
        with open(installed_path) as f:
            installed = json.load(f)
    except json.JSONDecodeError:
        installed = None
    if installed is None:
        print("  ⚠️  installed_plugins.json unparseable — skipped (left untouched)")
    else:
        plugins = installed.get("plugins")
        if isinstance(plugins, dict) and "healer@healer" in plugins:
            del plugins["healer@healer"]
            with open(installed_path, "w") as f:
                json.dump(installed, f, indent=2)
                f.write("\n")
            print("  ✅ Removed healer@healer from installed_plugins.json")
        else:
            print("  ✅ No Healer entry in installed_plugins.json (already clean)")
PYEOF
else
  echo "  ⚠️  Claude settings not found at $CLAUDE_SETTINGS — nothing to unregister."
fi

# ─── Step 2: Remove any legacy raw command files (pre-plugin installs) ───
echo "Removing legacy raw command files (if any)..."
OLD_COUNT=0
for f in "$CLAUDE_COMMANDS"/healer*.md "$CLAUDE_COMMANDS"/_enforcement.md; do
  if [ -f "$f" ]; then
    rm -f "$f"
    OLD_COUNT=$((OLD_COUNT + 1))
  fi
done
if [ "$OLD_COUNT" -gt 0 ]; then
  echo "  ✅ Removed $OLD_COUNT legacy command file(s)"
else
  echo "  ✅ None found"
fi

# ─── Step 3: User-local state ───
if [ "$PURGE" -eq 1 ]; then
  echo "Purging user-local Healer data..."
  if [ -d "$HEALER_CONFIG" ]; then
    rm -rf "$HEALER_CONFIG"
    echo "  ✅ Removed $HEALER_CONFIG"
  else
    echo "  ✅ $HEALER_CONFIG not present"
  fi
  if [ -d "$SYNC_STATE_DIR" ]; then
    rm -rf "$SYNC_STATE_DIR"
    echo "  ✅ Removed synced design data ($SYNC_STATE_DIR)"
  else
    echo "  ✅ Synced design data not present"
  fi
else
  if [ -d "$HEALER_CONFIG" ]; then
    echo "Preserving user-local data at $HEALER_CONFIG"
    echo "    (recipes, brainstorms, research, validations, strategies)"
    echo "    Run ./uninstall.sh --purge to delete it as well."
  fi
fi

echo ""
echo "═══════════════════════════════════════════════════"
echo "  Healer uninstalled."
echo "  ⚠️  Restart Claude Code for the change to take effect."
echo "═══════════════════════════════════════════════════"
