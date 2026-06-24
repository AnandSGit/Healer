#!/usr/bin/env python3
"""
generate_readme.py — Replace marker sections in README.md with auto-generated tables.

Reads:  data/commands.yaml, data/flows.yaml
Writes: README.md (only between marker comments)

Markers:
  <!-- HEALER:COMMANDS:START --> ... <!-- HEALER:COMMANDS:END -->
  <!-- HEALER:FLOWS:START -->    ... <!-- HEALER:FLOWS:END -->

Same generator can be invoked for healer-user-guide.html (uses different markers).
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

try:
    import yaml
except ImportError:
    print("ERROR: PyYAML not installed (pip3 install --user pyyaml)", file=sys.stderr)
    sys.exit(4)

ROOT = Path(__file__).resolve().parent.parent
README = ROOT / "README.md"
USER_GUIDE = ROOT / "docs" / "healer-user-guide.html"
COMMANDS_YAML = ROOT / "data" / "commands.yaml"
FLOWS_YAML = ROOT / "data" / "flows.yaml"

# Display order for command categories (controls README section order)
CATEGORY_ORDER = [
    ("core", "Core"),
    ("ideation", "Ideation & Strategy"),
    ("design-intel", "Design Intelligence"),
    ("implementation", "Implementation"),
    ("quality", "Testing & Quality"),
    ("debug", "Debugging & Fixing"),
    ("health", "Health & Reporting"),
    ("recording", "Recording & Flow Testing"),
    ("shipping", "Shipping"),
    ("help", "Help"),
]


def render_commands_table(commands: dict) -> str:
    """Render commands grouped by category."""
    by_cat: dict[str, list[tuple[str, str]]] = {}
    for name, entry in commands.items():
        cat = entry.get("category", "help")
        purpose_short = entry["purpose"].strip().splitlines()[0]
        if len(purpose_short) > 100:
            purpose_short = purpose_short[:97] + "..."
        by_cat.setdefault(cat, []).append((name, purpose_short))

    lines: list[str] = []
    for cat_key, cat_label in CATEGORY_ORDER:
        if cat_key not in by_cat:
            continue
        lines.append(f"\n### {cat_label}")
        lines.append("")
        lines.append("| Command | Description |")
        lines.append("|---------|-------------|")
        for name, purpose in sorted(by_cat[cat_key]):
            # Special case: 'healer' command is the bare /healer, not /healer:healer
            display = "/healer" if name == "healer" else f"/healer:{name}"
            lines.append(f"| `{display}` | {purpose} |")
    lines.append("")
    return "\n".join(lines)


def render_flows_table(flows: dict) -> str:
    """Render all flow presets as a single table."""
    lines: list[str] = []
    lines.append("")
    lines.append("| Preset | Pipeline | Purpose |")
    lines.append("|--------|----------|---------|")
    gate_sym = {"auto": "→", "interactive": "?→", "must-pass": "!→"}
    for name in sorted(flows.keys()):
        entry = flows[name]
        steps = entry.get("steps", [])
        # Render pipeline as: cmd1 ?→ cmd2 → cmd3 !→ ...
        # Gate symbol appears BETWEEN steps, representing the transition
        pipeline_parts = []
        for i, st in enumerate(steps):
            pipeline_parts.append(st["command"])
            if i < len(steps) - 1:
                # Use the NEXT step's gate as the transition? Actually each step
                # has its OWN gate (what gate to apply after it). We use this step's gate.
                pipeline_parts.append(gate_sym.get(st["gate"], "→"))
            else:
                # Final step's gate (terminal)
                pipeline_parts.append(gate_sym.get(st["gate"], ""))
        pipeline = " ".join(p for p in pipeline_parts if p)
        purpose = entry["purpose"].strip().splitlines()[0]
        if len(purpose) > 80:
            purpose = purpose[:77] + "..."
        lines.append(f"| `{name}` | {pipeline} | {purpose} |")
    lines.append("")
    return "\n".join(lines)


def replace_marker_section(text: str, start_marker: str, end_marker: str, new_content: str) -> tuple[str, bool]:
    """Replace content between markers. Returns (new_text, was_replaced)."""
    pattern = re.compile(
        re.escape(start_marker) + r"(.*?)" + re.escape(end_marker),
        re.DOTALL,
    )
    if not pattern.search(text):
        return text, False
    replacement = f"{start_marker}\n{new_content.strip()}\n{end_marker}"
    return pattern.sub(replacement, text, count=1), True


def main() -> int:
    if not COMMANDS_YAML.exists() or not FLOWS_YAML.exists():
        print(f"ERROR: missing YAML source(s)", file=sys.stderr)
        return 3

    commands = yaml.safe_load(COMMANDS_YAML.read_text(encoding="utf-8")) or {}
    flows = yaml.safe_load(FLOWS_YAML.read_text(encoding="utf-8")) or {}

    commands_table = render_commands_table(commands)
    flows_table = render_flows_table(flows)

    updated_files: list[str] = []

    # Update README.md
    if README.exists():
        text = README.read_text(encoding="utf-8")
        text, did_cmd = replace_marker_section(
            text,
            "<!-- HEALER:COMMANDS:START -->",
            "<!-- HEALER:COMMANDS:END -->",
            commands_table,
        )
        text, did_flow = replace_marker_section(
            text,
            "<!-- HEALER:FLOWS:START -->",
            "<!-- HEALER:FLOWS:END -->",
            flows_table,
        )
        if did_cmd or did_flow:
            README.write_text(text, encoding="utf-8")
            updated_files.append(f"README.md (commands={did_cmd}, flows={did_flow})")
        else:
            print(f"  WARN README.md has no marker sections; skipped", file=sys.stderr)

    # Update healer-user-guide.html (HTML markers use same syntax)
    if USER_GUIDE.exists():
        text = USER_GUIDE.read_text(encoding="utf-8")
        text, did_cmd_html = replace_marker_section(
            text,
            "<!-- HEALER:COMMANDS:START -->",
            "<!-- HEALER:COMMANDS:END -->",
            commands_table,
        )
        text, did_flow_html = replace_marker_section(
            text,
            "<!-- HEALER:FLOWS:START -->",
            "<!-- HEALER:FLOWS:END -->",
            flows_table,
        )
        if did_cmd_html or did_flow_html:
            USER_GUIDE.write_text(text, encoding="utf-8")
            updated_files.append(f"healer-user-guide.html (commands={did_cmd_html}, flows={did_flow_html})")

    if updated_files:
        for f in updated_files:
            print(f"  OK  updated {f}")
        return 0
    else:
        print("  WARN no marker sections found in any target file", file=sys.stderr)
        return 0


if __name__ == "__main__":
    sys.exit(main())
