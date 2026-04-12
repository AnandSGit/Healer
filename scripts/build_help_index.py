#!/usr/bin/env python3
"""
build_help_index.py — Build data/help-index.json from data/commands.yaml + data/flows.yaml

Validates both YAMLs against their JSON Schemas, pre-renders the six-section
drill-down text per entry, computes source hashes, and writes a deterministic
JSON index that the `?` interceptor reads at runtime.

Exit codes:
  0  = success
  1  = schema validation failure
  2  = bijection drift (commands/*.md vs commands.yaml mismatch)
  3  = file I/O error
  4  = missing dependency (PyYAML / jsonschema)
"""
from __future__ import annotations

import hashlib
import json
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import yaml
    import jsonschema
except ImportError as e:
    print(f"ERROR: missing dependency — {e}", file=sys.stderr)
    print("Install: pip3 install pyyaml jsonschema", file=sys.stderr)
    sys.exit(4)

ROOT = Path(__file__).resolve().parent.parent
DATA = ROOT / "data"
SCHEMA = DATA / "schema"
COMMANDS_DIR = ROOT / "commands"

COMMANDS_YAML = DATA / "commands.yaml"
FLOWS_YAML = DATA / "flows.yaml"
COMMAND_SCHEMA = SCHEMA / "command.schema.json"
FLOW_SCHEMA = SCHEMA / "flow.schema.json"
INDEX_OUT = DATA / "help-index.json"

INDEX_VERSION = "1.0"


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def load_yaml(path: Path) -> dict:
    with path.open() as f:
        return yaml.safe_load(f) or {}


def load_schema(path: Path) -> dict:
    with path.open() as f:
        return json.load(f)


def validate(data: dict, schema: dict, label: str) -> None:
    try:
        jsonschema.validate(instance=data, schema=schema)
        print(f"  OK  schema validation: {label}")
    except jsonschema.ValidationError as e:
        path = ".".join(str(p) for p in e.absolute_path) or "<root>"
        print(f"\nFAIL schema validation: {label}", file=sys.stderr)
        print(f"     path: {path}", file=sys.stderr)
        print(f"     reason: {e.message}", file=sys.stderr)
        sys.exit(1)


METADATA_MARKER = "<!-- Help metadata: data/commands.yaml -->"


def check_bijection(commands_data: dict) -> None:
    """Every commands/*.md file must have a key in commands.yaml and vice versa.

    Also enforces the help-metadata marker presence in every command file
    (FR-8.10) — drift here means the file isn't pointing contributors to the
    YAML source of truth.
    """
    md_files = {
        p.stem
        for p in COMMANDS_DIR.glob("*.md")
        if not p.name.startswith("_")
    }
    yaml_keys = set(commands_data.keys())

    # Phantom entries (in YAML but no matching .md file) — always a hard error.
    phantom = yaml_keys - md_files
    if phantom:
        print(f"\nFAIL bijection drift", file=sys.stderr)
        print(f"     YAML keys with no matching commands/*.md: {phantom}", file=sys.stderr)
        sys.exit(2)

    # Missing entries (md exists but no YAML key) — hard error post-migration.
    missing = md_files - yaml_keys
    if missing:
        print(f"\nFAIL bijection drift", file=sys.stderr)
        print(f"     commands/*.md without YAML entry: {sorted(missing)}", file=sys.stderr)
        print(f"     Run /healer:add-command for new commands, or add YAML entry manually.", file=sys.stderr)
        sys.exit(2)

    # Bijection is clean
    print(f"  OK  bijection: {len(md_files)} commands ↔ {len(yaml_keys)} YAML keys")

    # Marker enforcement — every commands/*.md must contain the metadata marker
    missing_marker = []
    for p in sorted(COMMANDS_DIR.glob("*.md")):
        if p.name.startswith("_"):
            continue
        if METADATA_MARKER not in p.read_text():
            missing_marker.append(p.name)
    if missing_marker:
        print(f"\nFAIL metadata marker missing", file=sys.stderr)
        print(f"     The following commands/*.md files lack the marker:", file=sys.stderr)
        for name in missing_marker:
            print(f"       - commands/{name}", file=sys.stderr)
        print(f"     Required marker (insert after frontmatter):", file=sys.stderr)
        print(f"       {METADATA_MARKER}", file=sys.stderr)
        sys.exit(2)
    print(f"  OK  metadata markers: all {len(md_files)} files OK")


def render_command_panel(name: str, entry: dict) -> str:
    """Render the six-section drill-down text for a command.

    Output is the literal text the `?` interceptor will display.
    """
    lines: list[str] = []
    lines.append("═" * 60)
    lines.append(f"HEALER — /healer:{name}")
    lines.append("═" * 60)
    lines.append("")

    lines.append("1. PURPOSE")
    for ln in entry["purpose"].rstrip().splitlines():
        lines.append(f"   {ln}")
    lines.append("")

    lines.append("2. WHAT IT DOES")
    for ln in entry["what_it_does"].rstrip().splitlines():
        lines.append(f"   {ln}")
    lines.append("")

    lines.append("3. INPUT / EXPECTED TEXT")
    inp = entry["input"]
    lines.append(f"   Syntax: {inp['syntax']}")
    if inp.get("args"):
        lines.append("")
        lines.append("   Arguments:")
        for arg in inp["args"]:
            req = "required" if arg.get("required") else "optional"
            lines.append(f"     {arg['name']:<14} ({req}) — {arg['desc']}")
    if inp.get("valid"):
        lines.append("")
        lines.append("   Valid examples:")
        for v in inp["valid"]:
            lines.append(f"     • {v!r}")
    if inp.get("invalid"):
        lines.append("")
        lines.append("   Invalid examples:")
        for inv in inp["invalid"]:
            lines.append(f"     ✗ {inv['text']!r} — {inv['why']}")
    lines.append("")

    lines.append("4. CONCRETE EXAMPLE")
    ex = entry["example"]
    lines.append(f"   Command: {ex['command']}")
    lines.append("")
    lines.append("   Trace:")
    for step in ex["trace"]:
        lines.append(f"     → {step}")
    lines.append("")
    lines.append("   Why this example:")
    for ln in ex["why_this_example"].rstrip().splitlines():
        lines.append(f"     {ln}")
    lines.append("")

    lines.append("5. PURPOSE OF YOUR INPUT TEXT")
    for ln in entry["input_purpose"].rstrip().splitlines():
        lines.append(f"   {ln}")
    lines.append("")

    lines.append("6. AFTER THIS COMMAND")
    if entry.get("next"):
        lines.append(f"   Suggested next: {', '.join('/healer:' + n for n in entry['next'])}")
    if entry.get("related"):
        lines.append(f"   Related:        {', '.join('/healer:' + r for r in entry['related'])}")
    if entry.get("errors"):
        lines.append("")
        lines.append("   Errors / halts:")
        for err in entry["errors"]:
            lines.append(f"     ! {err}")

    lines.append("═" * 60)
    return "\n".join(lines)


def render_flow_panel(name: str, entry: dict) -> str:
    """Render the six-section drill-down text for a flow preset."""
    lines: list[str] = []
    lines.append("═" * 60)
    lines.append(f"HEALER — /healer:flow {name}")
    lines.append("═" * 60)
    lines.append("")

    lines.append("1. PURPOSE")
    for ln in entry["purpose"].rstrip().splitlines():
        lines.append(f"   {ln}")
    lines.append("")

    lines.append("2. WHAT IT DOES (sub-commands, in order)")
    for ln in entry["what_it_does"].rstrip().splitlines():
        lines.append(f"   {ln}")
    lines.append("")
    lines.append("   STEP  COMMAND               GATE          PRODUCES")
    lines.append("   ────  ────────────────────  ────────────  ──────────────────────────")
    gate_sym = {"auto": "→  auto", "interactive": "?→ interactive", "must-pass": "!→ must-pass"}
    for i, st in enumerate(entry["steps"], 1):
        cmd = f"/healer:{st['command']}"
        if st.get("args"):
            cmd += f" {st['args']}"
        gate = gate_sym.get(st["gate"], st["gate"])
        produces = st.get("produces", "—")
        lines.append(f"   {i:<4}  {cmd:<20}  {gate:<12}  {produces}")
    lines.append("")

    lines.append("3. INPUT / EXPECTED TEXT")
    inp = entry["input"]
    lines.append(f"   Syntax: {inp['syntax']}")
    if inp.get("args"):
        lines.append("")
        lines.append("   Arguments:")
        for arg in inp["args"]:
            req = "required" if arg.get("required") else "optional"
            lines.append(f"     {arg['name']:<14} ({req}) — {arg['desc']}")
    if inp.get("valid"):
        lines.append("")
        lines.append("   Valid examples:")
        for v in inp["valid"]:
            lines.append(f"     • {v!r}")
    if inp.get("invalid"):
        lines.append("")
        lines.append("   Invalid examples:")
        for inv in inp["invalid"]:
            lines.append(f"     ✗ {inv['text']!r} — {inv['why']}")
    lines.append("")

    lines.append("4. CONCRETE EXAMPLE")
    ex = entry["example"]
    lines.append(f"   Command: {ex['command']}")
    lines.append("")
    lines.append("   Trace:")
    for step in ex["trace"]:
        lines.append(f"     → {step}")
    lines.append("")
    lines.append("   Why this example:")
    for ln in ex["why_this_example"].rstrip().splitlines():
        lines.append(f"     {ln}")
    lines.append("")

    lines.append("5. PURPOSE OF YOUR INPUT TEXT")
    for ln in entry["input_purpose"].rstrip().splitlines():
        lines.append(f"   {ln}")
    lines.append("")

    lines.append("6. AFTER THIS FLOW")
    aft = entry.get("after", {})
    if aft.get("next"):
        lines.append(f"   Suggested next:   {', '.join('/healer:' + n for n in aft['next'])}")
    if aft.get("sister_presets"):
        lines.append(f"   Sister presets:   {', '.join('/healer:flow ' + p for p in aft['sister_presets'])}")
    if aft.get("on_failure"):
        lines.append(f"   On failure:       {aft['on_failure']}")

    lines.append("═" * 60)
    return "\n".join(lines)


def render_flow_overview(flows: dict) -> str:
    """Render the flat overview shown for `/healer:flow ?` (no preset specified)."""
    lines: list[str] = []
    lines.append("═" * 60)
    lines.append("HEALER — /healer:flow")
    lines.append("═" * 60)
    lines.append("")
    lines.append("Flow orchestrator — chains healer sub-commands into pipelines.")
    lines.append("Use a preset, a custom recipe, or an inline chain.")
    lines.append("")
    lines.append("USAGE")
    lines.append("  /healer:flow <preset>            # built-in preset")
    lines.append("  /healer:flow <recipe>            # custom recipe from ~/.healer/recipes.yaml")
    lines.append("  /healer:flow a → b ?→ c !→ d     # inline chain")
    lines.append("  /healer:flow <preset> ?          # drill-down help for a specific preset")
    lines.append("")
    lines.append(f"BUILT-IN PRESETS ({len(flows)})")
    name_w = max(len(n) for n in flows.keys()) if flows else 12
    for name in sorted(flows.keys()):
        purpose = flows[name]["purpose"].strip().splitlines()[0]
        if len(purpose) > 80:
            purpose = purpose[:77] + "..."
        lines.append(f"  {name:<{name_w}}  {purpose}")
    lines.append("")
    lines.append("GATE OPERATORS")
    lines.append("  →   AUTO         continue automatically")
    lines.append("  ?→  INTERACTIVE  pause for user approval")
    lines.append("  !→  MUST-PASS    halt if step fails (no override)")
    lines.append("")
    lines.append("Tip: append `?` to any preset for full drill-down (e.g., /healer:flow feature ?)")
    lines.append("═" * 60)
    return "\n".join(lines)


def main() -> int:
    print(f"Healer help-index builder v{INDEX_VERSION}")
    print()

    # Validate schema files exist
    for p in (COMMANDS_YAML, FLOWS_YAML, COMMAND_SCHEMA, FLOW_SCHEMA):
        if not p.exists():
            print(f"ERROR: missing {p}", file=sys.stderr)
            return 3

    print("Loading...")
    cmd_data = load_yaml(COMMANDS_YAML)
    flow_data = load_yaml(FLOWS_YAML)
    cmd_schema = load_schema(COMMAND_SCHEMA)
    flow_schema = load_schema(FLOW_SCHEMA)
    print(f"  loaded {len(cmd_data)} command entries, {len(flow_data)} flow presets")
    print()

    print("Validating...")
    validate(cmd_data, cmd_schema, "commands.yaml")
    validate(flow_data, flow_schema, "flows.yaml")
    check_bijection(cmd_data)
    print()

    print("Rendering panels...")
    commands_index: dict[str, dict] = {}
    for name in sorted(cmd_data.keys()):
        entry = cmd_data[name]
        commands_index[name] = {
            "category": entry["category"],
            "purpose_short": entry["purpose"].strip().splitlines()[0],
            "next": entry.get("next", []),
            "panel": render_command_panel(name, entry),
        }
    print(f"  rendered {len(commands_index)} command panels")

    flows_index: dict[str, dict] = {}
    for name in sorted(flow_data.keys()):
        entry = flow_data[name]
        flows_index[name] = {
            "purpose_short": entry["purpose"].strip().splitlines()[0],
            "step_count": len(entry["steps"]),
            "panel": render_flow_panel(name, entry),
        }
    print(f"  rendered {len(flows_index)} flow panels")
    flows_overview_panel = render_flow_overview(flow_data)
    print(f"  rendered flow overview panel")
    print()

    # Compute source hashes for staleness detection
    source_hashes = {
        "commands.yaml": sha256_of(COMMANDS_YAML),
        "flows.yaml": sha256_of(FLOWS_YAML),
        "command.schema.json": sha256_of(COMMAND_SCHEMA),
        "flow.schema.json": sha256_of(FLOW_SCHEMA),
    }

    index = {
        "_meta": {
            "version": INDEX_VERSION,
            "generated_at": datetime.now(timezone.utc).isoformat(),
            "source_hashes": source_hashes,
            "command_count": len(commands_index),
            "flow_count": len(flows_index),
        },
        "commands": commands_index,
        "flows": flows_index,
        "flow_overview": flows_overview_panel,
    }

    print(f"Writing {INDEX_OUT}...")
    INDEX_OUT.write_text(
        json.dumps(index, indent=2, sort_keys=True, ensure_ascii=False) + "\n"
    )
    size_kb = INDEX_OUT.stat().st_size / 1024
    print(f"  wrote {size_kb:.1f} KB")
    print()

    # Also regenerate README and user-guide marker sections (FR-6, FR-8.2)
    print("Regenerating doc marker sections...")
    try:
        from generate_readme import main as gen_readme
        gen_readme()
    except Exception as e:
        print(f"  WARN README/user-guide auto-generation failed: {e}", file=sys.stderr)
        # Non-fatal — index is still valid
    print()

    print("✓ help-index.json built successfully")
    return 0


if __name__ == "__main__":
    sys.exit(main())
