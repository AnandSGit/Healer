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
import textwrap
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
PLUGIN_MANIFEST = ROOT / ".claude-plugin" / "plugin.json"

INDEX_VERSION = "1.0"


def sha256_of(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def read_plugin_version() -> str:
    """Read the canonical plugin version for man-page footers; tolerate absence."""
    try:
        with PLUGIN_MANIFEST.open(encoding="utf-8") as f:
            return json.load(f).get("version", "dev")
    except Exception:
        return "dev"


def load_yaml(path: Path) -> dict:
    with path.open(encoding="utf-8") as f:
        return yaml.safe_load(f) or {}


def load_schema(path: Path) -> dict:
    with path.open(encoding="utf-8") as f:
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
        if METADATA_MARKER not in p.read_text(encoding="utf-8"):
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


# ── man-page rendering primitives ───────────────────────────────────────────
# Healer help panels follow the Linux man-page convention (man-pages(7)):
# a centered header/footer banner plus the standard section order
# NAME · SYNOPSIS · DESCRIPTION · OPTIONS · EXAMPLES · EXIT STATUS · SEE ALSO.

MAN_WIDTH = 78          # classic terminal man width
BODY_INDENT = "       "  # 7 spaces, the man-page body indent
SUB_INDENT = "           "  # 11 spaces, for nested/option bodies


def _banner(left: str, center: str, right: str) -> str:
    """Center-justify a man-page header/footer line within MAN_WIDTH."""
    # leading half: left ... center ; trailing half: center ... right
    total = MAN_WIDTH
    # position center so it is centered overall
    cstart = (total - len(center)) // 2
    line = left + " " * max(1, cstart - len(left)) + center
    line = line + " " * max(1, total - len(right) - len(line)) + right
    return line[:total] if len(line) > total else line


def _wrap(text: str, indent: str = BODY_INDENT, width: int = MAN_WIDTH) -> list[str]:
    """Wrap a paragraph (preserving explicit newlines) to the man body column."""
    out: list[str] = []
    for para in text.rstrip().splitlines():
        if not para.strip():
            out.append("")
            continue
        wrapped = textwrap.wrap(para.strip(), width=width - len(indent)) or [""]
        out.extend(indent + w for w in wrapped)
    return out


def _tagline(purpose: str, cap: int = 62) -> str:
    """A concise one-line summary for the NAME section / apropos listing.

    Prefers the text before the first em-dash separator, else the first
    sentence, capped to `cap` characters.
    """
    first = purpose.strip().splitlines()[0].strip()
    for sep in (" — ", " – ", " - "):
        if sep in first:
            cand = first.split(sep, 1)[0].strip()
            if len(cand) >= 8:
                first = cand
                break
    else:
        for end in (". ", "? ", "! "):
            if end in first:
                first = first.split(end, 1)[0].strip()
                break
    if len(first) > cap:
        first = first[: cap - 1].rstrip() + "…"
    return first


def _man_id(name: str, *, flow: bool = False) -> str:
    base = f"flow:{name}" if flow else name
    return f"HEALER:{base.upper()}(1)"


def _options_section(inp: dict) -> list[str]:
    """Render the OPTIONS / ARGUMENTS section from input.args."""
    args = inp.get("args") or []
    if not args:
        return []
    lines = ["OPTIONS"]
    for arg in args:
        req = "required" if arg.get("required") else "optional"
        lines.append(f"{BODY_INDENT}{arg['name']}  ({req})")
        lines.extend(_wrap(arg["desc"], indent=SUB_INDENT))
        lines.append("")
    if lines and lines[-1] == "":
        lines.pop()
    return lines


def _examples_section(entry: dict, inp: dict) -> list[str]:
    lines = ["EXAMPLES"]
    ex = entry.get("example") or {}
    if ex.get("command"):
        lines.append(f"{BODY_INDENT}{ex['command']}")
        if ex.get("why_this_example"):
            lines.extend(_wrap(ex["why_this_example"], indent=SUB_INDENT))
        if ex.get("trace"):
            lines.append(f"{SUB_INDENT}Trace:")
            for step in ex["trace"]:
                lines.append(f"{SUB_INDENT}  → {step}")
        lines.append("")
    valid = [v for v in (inp.get("valid") or []) if v != ""]
    if valid:
        lines.append(f"{BODY_INDENT}Valid input:    " + ", ".join(repr(v) for v in valid))
    if inp.get("invalid"):
        for inv in inp["invalid"]:
            lines.append(f"{BODY_INDENT}Invalid input:  {inv['text']!r} — {inv['why']}")
    if lines and lines[-1] == "":
        lines.pop()
    return lines


def render_command_panel(name: str, entry: dict, version: str) -> str:
    """Render a man-page-style help panel for a command."""
    man_id = _man_id(name)
    inp = entry["input"]
    L: list[str] = []
    L.append(_banner(man_id, "Healer Manual", man_id))
    L.append("")

    L.append("NAME")
    L.extend(_wrap(f"healer:{name} — {_tagline(entry['purpose'])}"))
    L.append("")

    L.append("SYNOPSIS")
    L.append(f"{BODY_INDENT}{inp['syntax']}")
    L.append(f"{BODY_INDENT}/healer:{name} (-h | --help | ?)")
    L.append("")

    L.append("DESCRIPTION")
    L.extend(_wrap(entry["purpose"]))
    if entry.get("what_it_does"):
        L.append("")
        L.extend(_wrap(entry["what_it_does"]))
    if entry.get("input_purpose"):
        L.append("")
        L.extend(_wrap(entry["input_purpose"]))
    L.append("")

    opts = _options_section(inp)
    if opts:
        L.extend(opts)
        L.append("")

    L.extend(_examples_section(entry, inp))
    L.append("")

    if entry.get("errors"):
        L.append("EXIT STATUS")
        L.append(f"{BODY_INDENT}The command halts (must-pass gate failure) when:")
        for err in entry["errors"]:
            L.append(f"{SUB_INDENT}! {err}")
        L.append("")

    see = []
    see += [f"healer:{n}" for n in entry.get("next", [])]
    see += [f"healer:{r}" for r in entry.get("related", [])]
    if see:
        L.append("SEE ALSO")
        # de-dup while preserving order
        seen, uniq = set(), []
        for s in see:
            if s not in seen:
                seen.add(s); uniq.append(s)
        L.extend(_wrap(", ".join(uniq)))
        L.append("")

    L.append("ENFORCEMENT")
    L.extend(_wrap("Runs under the shared enforcement protocol "
                   "(shared/_enforcement.md): research and verification HARD-GATEs apply."))
    L.append("")
    L.append(_banner(f"Healer {version}", entry.get("category", "Healer"), man_id))
    return "\n".join(L)


def render_flow_panel(name: str, entry: dict, version: str) -> str:
    """Render a man-page-style help panel for a flow preset."""
    man_id = _man_id(name, flow=True)
    inp = entry["input"]
    L: list[str] = []
    L.append(_banner(man_id, "Healer Manual", man_id))
    L.append("")

    L.append("NAME")
    L.extend(_wrap(f"healer:flow {name} — {_tagline(entry['purpose'])}"))
    L.append("")

    L.append("SYNOPSIS")
    L.append(f"{BODY_INDENT}{inp['syntax']}")
    L.append(f"{BODY_INDENT}/healer:flow {name} (-h | --help | ?)")
    L.append("")

    L.append("DESCRIPTION")
    L.extend(_wrap(entry["purpose"]))
    if entry.get("what_it_does"):
        L.append("")
        L.extend(_wrap(entry["what_it_does"]))
    L.append("")

    L.append("PIPELINE")
    L.append(f"{BODY_INDENT}STEP  COMMAND               GATE            PRODUCES")
    L.append(f"{BODY_INDENT}────  ────────────────────  ──────────────  ─────────────────────")
    gate_sym = {"auto": "→  auto", "interactive": "?→ interactive", "must-pass": "!→ must-pass"}
    for i, st in enumerate(entry["steps"], 1):
        cmd = f"/healer:{st['command']}"
        if st.get("args"):
            cmd += f" {st['args']}"
        gate = gate_sym.get(st["gate"], st["gate"])
        produces = st.get("produces", "—")
        L.append(f"{BODY_INDENT}{i:<4}  {cmd:<20}  {gate:<14}  {produces}")
    L.append("")
    L.append(f"{BODY_INDENT}Gate operators:  →  auto      ?→ interactive (pause)      "
             "!→ must-pass (halt on failure)")
    L.append("")

    opts = _options_section(inp)
    if opts:
        L.extend(opts)
        L.append("")

    L.extend(_examples_section(entry, inp))
    L.append("")

    aft = entry.get("after", {})
    if aft.get("on_failure"):
        L.append("EXIT STATUS")
        L.extend(_wrap(f"On failure: {aft['on_failure']}"))
        L.append("")

    see = [f"healer:{n}" for n in aft.get("next", [])]
    see += [f"healer:flow {p}" for p in aft.get("sister_presets", [])]
    if see:
        L.append("SEE ALSO")
        L.extend(_wrap(", ".join(see)))
        L.append("")

    L.append(_banner(f"Healer {version}", "flow preset", man_id))
    return "\n".join(L)


def render_flow_overview(flows: dict, version: str) -> str:
    """Render the man-page intro shown for `/healer:flow ?` (no preset specified)."""
    man_id = "HEALER:FLOW(1)"
    L: list[str] = []
    L.append(_banner(man_id, "Healer Manual", man_id))
    L.append("")
    L.append("NAME")
    L.extend(_wrap("healer:flow — orchestrate healer sub-commands into gated pipelines"))
    L.append("")
    L.append("SYNOPSIS")
    L.append(f"{BODY_INDENT}/healer:flow <preset>")
    L.append(f"{BODY_INDENT}/healer:flow <recipe>")
    L.append(f"{BODY_INDENT}/healer:flow <cmd> → <cmd> ?→ <cmd> !→ <cmd>")
    L.append(f"{BODY_INDENT}/healer:flow <preset> (-h | --help | ?)")
    L.append("")
    L.append("DESCRIPTION")
    L.extend(_wrap("Chains healer sub-commands into a pipeline. Run a built-in preset, "
                   "a custom recipe from ~/.healer/recipes.yaml, or an inline chain. Each "
                   "step runs its complete procedure, including research and verification "
                   "gates; gate operators control how one step hands off to the next."))
    L.append("")
    L.append("GATE OPERATORS")
    L.append(f"{BODY_INDENT}→   auto         continue automatically")
    L.append(f"{BODY_INDENT}?→  interactive  pause for user approval")
    L.append(f"{BODY_INDENT}!→  must-pass    halt the flow if the step fails (no override)")
    L.append("")
    L.append(f"PRESETS ({len(flows)})")
    name_w = max((len(n) for n in flows.keys()), default=12)
    for name in sorted(flows.keys()):
        purpose = flows[name]["purpose"].strip().splitlines()[0]
        avail = MAN_WIDTH - len(BODY_INDENT) - name_w - 2
        if len(purpose) > avail:
            purpose = purpose[: avail - 3] + "..."
        L.append(f"{BODY_INDENT}{name:<{name_w}}  {purpose}")
    L.append("")
    L.append("SEE ALSO")
    L.extend(_wrap("healer:help, healer:help flows, healer:flow <preset> ?"))
    L.append("")
    L.append(_banner(f"Healer {version}", "flow orchestrator", man_id))
    return "\n".join(L)


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

    version = read_plugin_version()
    print(f"  plugin version: {version}")

    print("Rendering panels...")
    commands_index: dict[str, dict] = {}
    for name in sorted(cmd_data.keys()):
        entry = cmd_data[name]
        commands_index[name] = {
            "category": entry["category"],
            "purpose_short": _tagline(entry["purpose"], cap=72),
            "next": entry.get("next", []),
            "panel": render_command_panel(name, entry, version),
        }
    print(f"  rendered {len(commands_index)} command panels")

    flows_index: dict[str, dict] = {}
    for name in sorted(flow_data.keys()):
        entry = flow_data[name]
        flows_index[name] = {
            "purpose_short": _tagline(entry["purpose"], cap=72),
            "step_count": len(entry["steps"]),
            "panel": render_flow_panel(name, entry, version),
        }
    print(f"  rendered {len(flows_index)} flow panels")
    flows_overview_panel = render_flow_overview(flow_data, version)
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
        json.dumps(index, indent=2, sort_keys=True, ensure_ascii=False) + "\n",
        encoding="utf-8",
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
