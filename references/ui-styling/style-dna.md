# Style DNA — Machine-Readable Schema for Imitate → Adapt

**Purpose.** Style DNA is the deterministic, machine-parseable companion to the prose `imitate` document. Where the markdown explains visual design to humans, Style DNA encodes every source-derivable visual decision — tokens, per-context micro-decisions, page compositions, animation literals, chart render configs, icon styles, branding assets, copy voice, and AI response patterns — as structured YAML that `/healer:adapt` consumes without interpretation.

**Design principle.** Any field in Style DNA must trace to a **file path + line range** in the source project. No estimates. No generalizations. If a value is not source-derivable in mode `--rendered=false`, it is omitted (not guessed). This makes the format deterministic: two runs of `/healer:imitate` on the same git SHA produce byte-identical StyleDNA after canonical sort.

**Format.** YAML (human-readable, diff-friendly, Claude-parseable). Validated by JSON Schema sibling embedded at the end of this file. Conventional filename: `{AppName}_StyleDNA_{MMDDYYYY}.yaml` alongside the imitate markdown.

---

## 1. Top-Level Envelope

```yaml
style_dna_version: "1.0.0"          # schema version; adapt rejects unknown majors
app_identity:
  name: string                       # e.g., "Prism"
  source_sha: string                 # git HEAD SHA at imitate time
  source_repo_root: string           # absolute path or origin URL
  imitate_mode: exhaustive|sample    # D1 choice
  rendered_evidence: bool            # D2 — did we run a headless browser?
  generated_at: ISO-8601
  generated_by: "healer:imitate@{version}"
  canonical_hash: sha256             # hash of sorted body — deterministic fingerprint
tokens: {...}                        # §2
visual_motifs: [...]                 # §3 (VM-NNN)
page_compositions: [...]             # §4 (PC-NNN)
chart_renders: [...]                 # §5 (CH-NNN)
icon_usage: [...]                    # §6 (IC-NNN)
branding_assets: [...]               # §7 (BR-NNN)
copy_voice: {...}                    # §8 (CV-NNN)
ai_response_patterns: [...]          # §9 (AR-NNN)
motion_literals: [...]               # §10 (MD-NNN)
primitives_ref: [...]                # §11 — pointers to CP-NNN from imitate.md
provenance: {...}                    # §12 — file → field backmap
```

---

## 2. tokens — Atomic Design Values

Every token **must** include its `source_file` and `source_line`. Enums close the value space so adapt can translate rather than interpret.

```yaml
tokens:
  colors:
    palette:
      - id: "color-surface-base"
        role: enum[surface|surface-raised|surface-sunken|surface-overlay|surface-inverse|
                    text-primary|text-secondary|text-tertiary|text-inverse|text-muted|
                    border-subtle|border-default|border-strong|border-focus|
                    accent|accent-hover|accent-active|accent-subtle|
                    success|success-hover|warning|warning-hover|danger|danger-hover|info|info-hover|
                    chart-1..chart-12|brand-primary|brand-secondary|brand-tertiary]
        value:
          light: "#hex"
          dark: "#hex"                 # optional; omit if single-theme
          hc_light: "#hex"             # high-contrast; optional
          hc_dark: "#hex"              # optional
        css_variable: "--color-surface-base"
        tailwind_key: "surface.base"   # optional if Tailwind
        source_file: "styles/tokens.css"
        source_line: 12
        usage_count: 47                # grep count in src/
    gradients:
      - id: "gradient-hero-orange"
        stops:
          - { offset: 0.0, color: "#FF8A3D", opacity: 1.0 }
          - { offset: 1.0, color: "#E55A1F", opacity: 0.92 }
        angle_deg: 135
        source_file: "styles/hero.css"
        source_line: 8
  typography:
    families:
      - id: "font-heading"
        stack: ["Outfit", "system-ui", "sans-serif"]
        weight_axis: variable|[400, 600, 700]
        loading: local|google-fonts|self-hosted
        source_file: "app/layout.tsx"
        source_line: 14
    scale:                                # fluid clamp() or static
      - id: "size-h1"
        type: clamp|static
        min_px: 32
        max_px: 56
        vw_bp: 1280                       # breakpoint at which max is reached
        line_height_ratio: 1.1
        letter_spacing_em: -0.02
        weight: 700
        family_ref: "font-heading"
        tabular_nums: bool                # CRITICAL for financial/numeric polish
    body_baseline:                        # root rhythm grid
      base_size_px: 16
      rhythm_multiplier: 1.5
      numeric_alignment: tabular-nums|lining-nums|none
  spacing:
    base_unit_px: 4
    scale_keys: [0, 1, 2, 3, 4, 5, 6, 8, 10, 12, 16, 20, 24, 32, 40, 48, 64]
    per_context_overrides:                # the "p-4 vs p-6 per page" problem
      - context: "card.dashboard"
        padding: "p-6"
        padding_px: {x: 24, y: 24}
        source_file: "app/dashboard/page.tsx"
        source_line: 88
      - context: "card.transactions.row"
        padding: "p-4"
        padding_px: {x: 16, y: 16}
        source_file: "app/transactions/page.tsx"
        source_line: 142
  radii:
    scale:
      - id: "radius-sm"
        px: 6
      - id: "radius-md"
        px: 10
      - id: "radius-lg"
        px: 16
      - id: "radius-pill"
        px: 9999
    per_element:
      - element: "button.primary"
        radius_ref: "radius-md"
      - element: "card.default"
        radius_ref: "radius-lg"
      - element: "modal"
        radius_ref: "radius-lg"
      - element: "chip.category"
        radius_ref: "radius-pill"
  elevation:
    shadow_levels:
      - id: "elev-0"
        css: "none"
      - id: "elev-1"
        css: "0 1px 2px rgb(0 0 0 / 0.04), 0 1px 3px rgb(0 0 0 / 0.06)"
        used_on: ["card.default", "input.default"]
      - id: "elev-hover"
        css: "0 8px 24px rgb(0 0 0 / 0.08)"
        used_on: ["card:hover"]
    blur_backdrop:                        # "hazed liquid glass" style
      - id: "backdrop-haze"
        css_value: "blur(24px) saturate(140%)"
        used_on: ["modal.overlay", "sidebar.glass"]
        source_file: "styles/glass.css"
        source_line: 4
  borders:
    widths_px: [0, 1, 2, 3]
    styles: [solid, dashed, dotted]
    focus_ring:
      width_px: 2
      offset_px: 2
      color_ref: "color-border-focus"
      style: solid
      source_file: "styles/focus.css"
      source_line: 1
  opacity:
    scale: [0, 0.04, 0.08, 0.12, 0.2, 0.4, 0.6, 0.8, 1.0]
  z_index:
    layers:
      base: 0
      raised: 10
      dropdown: 1000
      sticky: 1100
      overlay: 1200
      modal: 1300
      toast: 1400
      tooltip: 1500
  breakpoints:
    sm: 640
    md: 768
    lg: 1024
    xl: 1280
    "2xl": 1536
```

---

## 3. visual_motifs — Reusable Visual Gestures (VM-NNN)

A "motif" is a named visual gesture that shows up in >1 place: card hover, sidebar glass, number ticker, etc. These are the things that carry "feel" but aren't primitives.

```yaml
visual_motifs:
  - id: "VM-001"
    name: "card-lift-on-hover"
    gesture: transform|filter|composite
    definition:
      from: "translateY(0)"
      to: "translateY(-2px)"
      duration_ms: 180
      easing_ref: "MD-001"
      shadow_shift: { from: "elev-1", to: "elev-hover" }
    triggers: [":hover", ":focus-visible"]
    applied_to: ["card.default", "metric-card", "suggested-prompt"]
    source_file: "components/Card.tsx"
    source_line: 34
  - id: "VM-002"
    name: "glass-overlay"
    gesture: backdrop-blur
    definition:
      backdrop_filter: "blur(24px) saturate(140%)"
      background: "rgba(20, 20, 24, 0.72)"
      border: "1px solid rgb(255 255 255 / 0.08)"
    applied_to: ["sidebar", "modal.overlay", "command-palette"]
  - id: "VM-003"
    name: "number-ticker"
    gesture: count-up-animation
    definition:
      library: "framer-motion" | custom
      duration_ms: 900
      easing_ref: "MD-001"
      stepping: smooth|integer
      tabular_nums: true
    applied_to: ["metric-card.value", "dashboard.hero-number"]
```

---

## 4. page_compositions — The Missing Layer (PC-NNN)

**This is the section that closes the "5-6/10 visual fidelity" gap.** For every page (exhaustive by default, D1), capture the composition grammar — not just which primitives appear, but how they're arranged, what density, what hierarchy, what framing.

```yaml
page_compositions:
  - id: "PC-001"
    route: "/dashboard"
    source_file: "app/dashboard/page.tsx"
    source_lines: [1, 284]
    layout_shell:
      type: enum[sidebar-main|top-nav-main|three-column|centered-single-column|split|full-bleed]
      sidebar_ref: "CP-014"            # reference to primitive in imitate.md
      header_ref: "CP-002"
      scroll_behavior: page|inner
    content_grammar:
      hero:
        present: true
        variant: headline-metric|search-bar|visualization|empty
        grid: "grid-cols-12 gap-6"
        padding: "px-8 pt-8 pb-4"
        content_refs: ["CP-020 MetricCard × 4"]
      primary_section:
        role: summary|detail|list|mixed
        layout: "grid grid-cols-2 lg:grid-cols-3 gap-4"
        density: compact|comfortable|spacious
        item_refs: ["CP-021 TransactionRow"]
      secondary_sections:
        - role: chart-panel
          ref: "CH-001"
          frame: "card rounded-lg p-6"
        - role: activity-feed
          ref: "CP-030"
      empty_state:
        present: true
        variant: illustration|icon|text-only|cta-focused
        copy_ref: "CV-003"
        illustration_ref: "BR-008"
    micro_spacing:                      # per-page overrides of global tokens
      card_padding: "p-6"
      row_gap: "gap-4"
      section_gap: "gap-8"
    iconography:
      section_icon_color_map:           # the Prism accent/success/info/warning pattern
        - section: "revenue"
          color_ref: "color-success"
          icon_ref: "IC-012"
        - section: "expenses"
          color_ref: "color-danger"
          icon_ref: "IC-013"
        - section: "insights"
          color_ref: "color-info"
          icon_ref: "IC-014"
    copy_voice_ref: "CV-001"
    composition_hash: sha256            # so adapt can detect "has this page changed"
  - id: "PC-002"
    route: "/assistant"
    source_file: "app/assistant/page.tsx"
    # ... same shape
    content_grammar:
      hero:
        variant: search-bar
        content_refs: ["CP-040 CommandInput"]
      primary_section:
        role: suggested-prompt-grid
        layout: "grid grid-cols-2 md:grid-cols-3 gap-3"
        density: comfortable
        item_count: 6                   # the "6 suggested-prompt grid" from Prism
        item_refs: ["CP-041 SuggestedPromptCard"]
```

---

## 5. chart_renders — Render-Output Specifics (CH-NNN)

Named components are not enough. Two apps using `BarChart` can look entirely different. Capture the render config.

```yaml
chart_renders:
  - id: "CH-001"
    name: "revenue-bar-chart"
    component_ref: "CP-050"
    library: recharts|chartjs|d3|visx|nivo|custom
    source_file: "components/charts/RevenueBarChart.tsx"
    chart_type: bar|line|area|pie|donut|scatter|stacked-bar|heatmap|sparkline
    axes:
      x:
        show: true
        tick_format: "MMM 'YY"          # date-fns format string
        tick_color_ref: "color-text-tertiary"
        font_size_px: 11
        tick_count: auto|N
        show_gridlines: false
      y:
        show: true
        tick_format: "$0,0"             # numbro format
        tabular_nums: true
        show_gridlines: true
        gridline_color_ref: "color-border-subtle"
        gridline_opacity: 0.5
    legend:
      position: top|right|bottom|left|hidden
      alignment: start|center|end
      swatch_shape: circle|square|line
    tooltip:
      shape: card|line|pill
      background_ref: "color-surface-overlay"
      border_radius_ref: "radius-md"
      shadow_ref: "elev-hover"
      padding: "p-3"
    colors:
      series_palette_refs: ["chart-1", "chart-2", "chart-3"]
      hover_brightness_pct: 115
    animation:
      entry_duration_ms: 600
      entry_stagger_ms: 30
      easing_ref: "MD-001"
    empty_state: illustration|text|placeholder-bars
```

---

## 6. icon_usage — Deep Icon Capture (IC-NNN)

Per user requirement: "Even icons styles should be adapted." Not just "which library" — the full style fingerprint.

```yaml
icon_usage:
  system:
    primary_library: lucide|phosphor|heroicons|feather|tabler|radix-icons|custom
    style: outline|solid|duotone|mixed
    stroke_width: 1.5|2|2.5
    corner_style: rounded|square|mitered
    default_size_px: 20
    size_scale_px: [12, 14, 16, 18, 20, 24, 28, 32, 40, 48, 64]
    color_strategy: currentColor|theme-mapped|per-context
    source_file: "components/Icon.tsx"
  per_icon:
    - id: "IC-001"
      role: "nav.dashboard"
      name_in_library: "LayoutDashboard"
      size_px: 20
      stroke_width: 2
      color_ref: "color-text-secondary"
      color_ref_active: "color-accent"
      used_in_files: ["components/Sidebar.tsx:24"]
    - id: "IC-002"
      role: "button.primary.trailing"
      name_in_library: "ArrowRight"
      size_px: 16
      alignment: leading|trailing|only
    - id: "IC-012"
      role: "section.revenue"
      name_in_library: "TrendingUp"
      size_px: 24
      color_ref: "color-success"
      background_shape: none|circle|square|squircle
      background_ref: "color-success-subtle"
  custom_icons:                         # inline SVGs not from a library
    - id: "IC-100"
      name: "layered-prism-logomark"
      svg_path_d: "M12 2 L2 7 L12 12 L22 7 Z M2 12 L12 17 L22 12 M2 17 L12 22 L22 17"
      viewbox: "0 0 24 24"
      fill: "url(#brand-gradient-1)"
      stroke: "none"
      source_file: "components/Logo.tsx"
      source_line: 12
```

---

## 7. branding_assets — Logos, Gradients, Marks (BR-NNN)

Every logo SVG, gradient definition, and brand mark with exact path data and gradient stops.

```yaml
branding_assets:
  - id: "BR-001"
    name: "primary-logomark"
    format: svg-inline|svg-file|png
    viewbox: "0 0 64 64"
    path_data: "M32 4 L8 18 L32 32 L56 18 Z ..."
    gradient_refs: ["BR-010"]
    aspect_ratio: 1.0
    source_file: "components/Logo.tsx"
    source_line: 8
    contexts: [sidebar, loading-screen, email-header]
  - id: "BR-010"
    name: "brand-gradient-primary"
    type: linear|radial|conic
    angle_deg: 135
    stops:
      - { offset: 0.0, color: "#FF8A3D" }
      - { offset: 0.5, color: "#FF6B1F" }
      - { offset: 1.0, color: "#B84515" }
    svg_id_in_defs: "brand-gradient-1"
```

---

## 8. copy_voice — Microcopy & Tone (CV-NNN)

```yaml
copy_voice:
  tone_markers:
    warmth: 0..1                         # 0.8 = warm, 0.2 = terse
    formality: 0..1
    playfulness: 0..1
    technicality: 0..1
  sentence_patterns:
    empty_states: ["No {entity} yet — {cta}", "Nothing here. {cta}"]
    error_messages: ["Something went wrong. {action}", "Couldn't {verb} — {cause}"]
    success_confirmations: ["{entity} {verb}ed", "Done. {next}"]
    cta_labels: ["Get started", "Try it", "Continue"]
  emoji_usage:
    allowed_contexts: [category-chips, onboarding, celebration]
    forbidden_contexts: [error-messages, security-warnings, legal]
    per_category_map:
      - category: "food"
        emoji: "🍔"
      - category: "transport"
        emoji: "🚗"
    source_file: "lib/categories.ts"
  microcopy_catalog:
    - id: "CV-001"
      context: "dashboard.empty-state"
      copy: "Connect your first account to see insights."
      source_file: "app/dashboard/page.tsx"
      source_line: 201
    - id: "CV-002"
      context: "button.primary.default"
      copy_template: "{verb} {entity}"
```

---

## 9. ai_response_patterns — RichResponse-Style Rendering (AR-NNN)

If the app has an AI surface, capture how its output is rendered — the component schema for markdown, citations, suggestion chips.

```yaml
ai_response_patterns:
  - id: "AR-001"
    name: "rich-response"
    component_ref: "CP-045"
    source_file: "components/RichResponse.tsx"
    renders:
      markdown:
        library: react-markdown|marked|custom
        gfm: true
        syntax_highlighting: shiki|prism|highlight.js|none
        code_block_style: "card rounded-md bg-surface-sunken p-4"
      citations:
        style: numbered-superscript|inline-badge|footnote
        badge_ref: "CP-046"
      suggestion_chips:
        present: true
        layout: "flex flex-wrap gap-2"
        chip_ref: "CP-047"
        max_visible: 4
      streaming:
        present: true
        cursor_style: blinking-bar|pulse|none
        typing_stagger_ms: 12
      structured_outputs:
        table_renderer: "CP-048"
        chart_renderer_ref: "CH-002"
```

---

## 10. motion_literals — Exact Animation Values (MD-NNN)

**The numbers that carry the feel.** Not prose — literal arrays, stiffness values, stagger amounts.

```yaml
motion_literals:
  easings:
    - id: "MD-001"
      name: "standard"
      cubic_bezier: [0.25, 0.46, 0.45, 0.94]
      used_in: [card-hover, page-transition, modal-open]
    - id: "MD-002"
      name: "emphasized"
      cubic_bezier: [0.2, 0.0, 0.0, 1.0]
  springs:
    - id: "MD-010"
      name: "modal-spring"
      library: framer-motion|react-spring|custom
      stiffness: 300
      damping: 30
      mass: 1
      used_in: [modal, sheet, tooltip]
  durations_ms:
    micro: 80
    short: 180
    medium: 280
    long: 420
    extra_long: 680
  stagger_ms:
    list_items: 30
    grid_items: 40
    hero_letters: 20
  page_transitions:
    type: fade|slide-up|slide-down|scale|shared-element|none
    y_offset_px: 8
    duration_ms: 280
    easing_ref: "MD-001"
  reduced_motion:
    respects_prefers_reduced_motion: bool
    fallback_strategy: fade-only|instant|opacity-fade
```

---

## 11. primitives_ref — Backmap to imitate.md

This section contains ONLY pointers back to `CP-NNN` entries in the imitate markdown document. StyleDNA stays lean; the prose document remains the primitive source of truth.

```yaml
primitives_ref:
  - cp_id: "CP-001"
    name: "Button"
    file: "components/Button.tsx"
    variants: [primary, secondary, ghost, destructive]
    imitate_doc_anchor: "#cp-001-button"
```

---

## 12. provenance — Traceability

Every non-trivial field records which file it came from. This enables adapt to warn if a target project is missing the corresponding concept.

```yaml
provenance:
  field_to_source:
    "tokens.colors.palette[0].value.dark": "styles/tokens.css:L12"
    "motion_literals.easings[0].cubic_bezier": "lib/motion.ts:L3"
  file_to_fields:
    "styles/tokens.css":
      - "tokens.colors.palette[*]"
      - "tokens.radii.*"
    "lib/motion.ts":
      - "motion_literals.*"
  scan_coverage:
    files_scanned: N
    files_producing_fields: N
    unscanned_candidates: []              # source files with CSS-adjacent content that did not produce fields — flagged for human review
```

---

## Validation

A companion JSON Schema Draft 2020-12 lives at `data/schema/style-dna.schema.json` (generated from this spec). `/healer:imitate` emits StyleDNA that conforms to that schema. `/healer:adapt` refuses to run on non-conforming input.

## Determinism Contract

1. **Canonical sort**: all list keys sorted by `id` ascending before serialization.
2. **Stable hashing**: `canonical_hash` is `sha256(canonical_yaml_bytes_minus_hash_field)`. Two imitate runs on the same SHA produce identical hashes.
3. **No timestamps inside body**: `generated_at` is at envelope level only — excluded from `canonical_hash`.
4. **Source paths are relative** to `app_identity.source_repo_root`.
5. **No guessing**: missing source-derivable data → field omitted, NOT null-stubbed.
