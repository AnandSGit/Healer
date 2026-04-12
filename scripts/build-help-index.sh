#!/usr/bin/env bash
# build-help-index.sh — thin wrapper around build_help_index.py
# Usage: bash scripts/build-help-index.sh
# Exit codes propagated from the Python script.
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$SCRIPT_DIR/build_help_index.py" "$@"
