# Healer Deep-Research + Options-First Protocol v1.0

**This file is the shared research+selection layer referenced by every ideation/planning Healer command.** When a command's procedure says "Reference the Deep-Research Protocol in `${CLAUDE_PLUGIN_ROOT}/shared/_research_and_options.md`", the rules in this file apply verbatim.

Commands that reference this module: `brainstorm`, `design`, `spec`, `plan`, `catchup`, `architect`, `strategy`, `implement`, `refactor`, `optimize`, `research`. Others may reference subsets (usually just the Deep-Research section).

---

## HARD-GATE: Deep-Research Protocol

<HARD-GATE>
NO OPTIONS, PROPOSALS, OR DECISIONS WITHOUT DEEP RESEARCH FIRST.
"Deep" means: multi-angle queries, multi-source diversity, credibility scoring, and negative-research — not one WebSearch and a vibe. Skipping any REQUIRED category below violates this protocol.
</HARD-GATE>

### The Query Matrix (mandatory categories)

For every command that invokes this protocol, execute queries from these categories. Domain-specific commands may add categories; they may NOT remove them.

```
┌────────────────────────────────────┬──────────────────────────────────────────┐
│ Category                           │ Required for                             │
├────────────────────────────────────┼──────────────────────────────────────────┤
│ 1. Best-practice current state     │ all                                      │
│ 2. Competitor / reference teardown │ all (at least 3 competitors/refs)        │
│ 3. Reference implementations       │ all (top-starred GitHub repos)           │
│ 4. Anti-patterns / postmortems     │ all (negative research — non-negotiable) │
│ 5. Authoritative specs             │ spec, architect, plan (RFCs, W3C, ADRs)  │
│ 6. Visual inspiration galleries    │ any command with UI output              │
│ 7. Library / API current docs      │ any command referencing a library        │
│ 8. Contradiction & consensus scan  │ all                                      │
└────────────────────────────────────┴──────────────────────────────────────────┘
```

### Required Tool Calls by Category

**Category 1 — Best-practice current state** (≥2 WebSearch):
- `WebSearch("{topic} best practices {year}")` where year is the current year
- `WebSearch("{topic} modern approach {framework}")`
- `WebSearch("state of {topic} {year}")`

**Category 2 — Competitor / reference teardown** (≥3 competitors):
- Identify 3+ products that solve the same problem. Examples: Stripe, Linear, GitHub, Vercel, Notion, Figma, Arc, Raycast, Cal.com, Supabase, Resend, Clerk, Tailwind UI, shadcn, Superhuman, Height, Pitch, Framer.
- `WebSearch("{competitor} {feature} design approach")` per competitor
- `WebFetch` the actual product/docs page when available (not just screenshots — read the text)
- Document the SPECIFIC pattern each uses, with URL.

**Category 3 — Reference implementations** (GitHub top-starred):
- `WebSearch("{topic} github site:github.com")`
- `WebSearch("awesome {topic}")` — lands on curated `awesome-*` lists
- `WebSearch("{topic} open source implementation stars:>1000")`
- Prefer repos with >1K stars. Note stargazer count in the research brief.

**Category 4 — Anti-patterns / postmortems** (non-negotiable, ≥2 queries):
- `WebSearch("{topic} considered harmful")`
- `WebSearch("{topic} postmortem failure")`
- `WebSearch("{topic} common mistakes anti-patterns")`
- `WebSearch("why not {topic}")`
- Learn from others' failures BEFORE proposing. Every "novel" option must survive a known failure mode.

**Category 5 — Authoritative specs** (for spec, architect, plan):
- `WebSearch("{topic} RFC")` — IETF RFCs
- `WebSearch("{topic} W3C specification")` — W3C standards
- `WebSearch("{topic} ADR architecture decision record")` — public ADR repos (e.g., `github.com/joelparkerhenderson/architecture-decision-record`)
- `WebFetch` the actual RFC / spec text, not commentary.

**Category 6 — Visual inspiration galleries** (any UI output):
- `WebSearch("{product-type} UI Mobbin")` — mobile app screenshots
- `WebSearch("{product-type} Dribbble {style-keyword}")` — curated concepts
- `WebSearch("{product-type} Awwwards")` — award-winning production sites
- `WebSearch("{product-type} Behance {style-keyword}")` — portfolio work
- `WebSearch("{product-type} Land-book")` — landing-page gallery
- `WebSearch("{product-type} godly.website")` — curated modern sites
- `WebSearch("SaaS landing page {year} examples")`
- For top 3-5 references: `WebFetch` the page URL and describe the visual treatment in prose (layout grid, typography choices, color relationships, motion, density).

**Category 7 — Library / API current docs** (if any library is involved):
- `the Context7 MCP resolve-library-id tool` for each library
- `the Context7 MCP query-docs tool` for each resolved library
- Cross-check method signatures, config keys, and types against your training-data assumptions. Context7 wins every conflict.

**Category 8 — Contradiction & consensus scan** (synthesis):
- When sources disagree, explicitly flag: `⚠ CONTRADICTION: Source A says X; Source B says Y. My read: {which is more credible and why}`
- When a claim is only in one source: `⚠ SINGLE-SOURCE: {claim} — corroborate or treat as unverified`

### Source Credibility Scoring

Tag every cited source in the Research Brief:

```
★★★★★ Official vendor docs (via Context7 or vendor sites)
★★★★  High-star GitHub repos (>1K stars), canonical RFCs/W3C specs
★★★   Reputable tech blogs (Martin Fowler, Addy Osmani, Julia Evans, Jepsen, engineering blogs of well-known companies)
★★    Forum posts (Stack Overflow answers with 10+ votes), Reddit highly-upvoted, HN comment threads with corroboration
★     Random blog posts, personal sites with no cross-reference (use with caution, flag in brief)
```

Do not cite ★ sources for decisions. They may appear as leads, but every decision must rest on ≥★★★.

### Source Diversity Requirement

<HARD-GATE>
Research is invalid if it draws from a single vendor, author, or ecosystem. You MUST have sources from at least 3 distinct organizations/authors for Category 2 (competitor teardown) and Category 3 (reference implementations). A brief that cites only Stripe, Stripe's blog, and Stripe's GitHub fails this gate even if all three are ★★★★★.
</HARD-GATE>

### Research Brief Template

Every command's Research Phase ends with this structured brief:

```
RESEARCH BRIEF — {topic}
═══════════════════════════════════════════════════
Queries run: {N} (matrix categories covered: 1✓ 2✓ 3✓ 4✓ 5✓ 6✓ 7✓ 8✓)
Sources consulted: {N} (★★★★★: n₁, ★★★★: n₂, ★★★: n₃, ★★: n₄, ★: n₅)
Organizations/authors represented: {N distinct}

COMPETITOR / REFERENCE TEARDOWN
─────────────────────────────────────────────
| Product | Approach observed | What works | What doesn't | ★ | URL |
|---------|-------------------|-----------|--------------|---|-----|
| {name}  | {pattern}         | {strength}| {weakness}  | ★★★★ | {URL} |
(≥3 rows — non-negotiable)

REFERENCE IMPLEMENTATIONS
─────────────────────────────────────────────
| Repo | Stars | Pattern | Relevance | URL |
|------|-------|---------|-----------|-----|

ANTI-PATTERNS & FAILURE MODES (mandatory)
─────────────────────────────────────────────
- {anti-pattern} — reported by {source, ★} — avoid by {mitigation}
- {failure mode} — from {postmortem, ★} — avoid by {mitigation}

AUTHORITATIVE SPECS (if applicable)
─────────────────────────────────────────────
- {RFC / W3C / ADR title} — {one-line relevance} — {URL}

VISUAL INSPIRATION (if UI)
─────────────────────────────────────────────
- Mobbin:    {N refs described}
- Dribbble:  {N refs described}
- Awwwards:  {N refs described}
- Behance:   {N refs described}
- Land-book: {N refs described}
- godly:     {N refs described}
- SaaS:      {N refs described}
(Per-reference: screenshot description of layout + typography + color + motion, plus URL.)

LIBRARY / API DOC DIFFS (Context7, if applicable)
─────────────────────────────────────────────
- {library}: {API change or current signature} — matches training? {yes/no — if no, list diff}

CONTRADICTIONS & OPEN QUESTIONS
─────────────────────────────────────────────
⚠ CONTRADICTION: {A} vs {B} — my read: {assessment}
? UNCLEAR: {claim} — single-source, needs corroboration

CONSENSUS FINDINGS
─────────────────────────────────────────────
- {finding backed by ≥3 sources} — sources: {list}
- {finding backed by ≥3 sources} — sources: {list}
═══════════════════════════════════════════════════
```

A command that cannot produce a brief with ALL required sections has not completed research and MUST NOT proceed to the Options Phase.

---

## HARD-GATE: Options-First Protocol

<HARD-GATE>
WHEN MULTIPLE VALID APPROACHES EXIST, YOU MUST PRESENT N CANDIDATES AND WAIT FOR USER SELECTION. DO NOT SILENTLY PICK.
"Pick one" is the user's job. "Curate the design space and explain the tradeoffs" is yours. Skipping this gate is equivalent to making an unapproved decision on the user's behalf.
</HARD-GATE>

### Minimum Candidate Counts (by command + domain)

These counts are the FLOOR. Generate more if the space genuinely has more distinct options. Generate fewer ONLY if the space is provably narrow (e.g., "FIPS 140-3 compliant hashing" has very few).

| Command | Domain | Minimum distinct candidates |
|---------|--------|------------------------------|
| brainstorm | approach | **7** |
| design | UI visual direction | **10** |
| design | API / data-model | **7** |
| design | UX flow | **5** |
| spec | structural variant | **5** |
| plan | execution order | **4** |
| architect | topology / service boundary | **5** |
| strategy | strategic posture | **4** |
| implement | algorithmic choice | **3** (when the space permits) |
| catchup | fix strategy per gap-cluster | **3** |
| refactor | transformation strategy | **5** |
| optimize | hypothesis | **5** |

"Distinct" means *conceptually different*, not *cosmetically different*. 10 variations of glassmorphism are 1 option, not 10. 10 options should look like: brutalist, neo-brutalist, glassmorphism, neumorphism, editorial, swiss-grid, bento, terminal/CLI-aesthetic, skeuomorphic-modern, Memphis.

### The Candidate Divergence Rule

<HARD-GATE>
Candidates MUST come from different points in the design space. If all N options share the same architecture/aesthetic/strategy and vary only in parameters, you have 1 option with tuning knobs, not N options. Re-generate.
</HARD-GATE>

Examples of INVALID sets (all too similar):
- ❌ "Blue SaaS", "Indigo SaaS", "Sky-blue SaaS" (one aesthetic, color tuning)
- ❌ REST with JWT, REST with session cookies, REST with API keys (one architecture, auth tuning)
- ❌ React+Tailwind+shadcn v1 / v2 / v3 (one stack, minor variation)

Examples of VALID sets (genuinely distinct):
- ✅ "Editorial newspaper", "Brutalist monochrome", "Bento grid", "Terminal/CLI", "Swiss grid poster" (5 aesthetics)
- ✅ REST / GraphQL / tRPC / Server Actions / gRPC (5 API architectures)
- ✅ Vertical-slice-first / Horizontal-layer-first / Risk-first / Happy-path-first (4 execution strategies)

### Presentation Format — Numbered Pros/Cons Table (all commands)

For every options-producing step, render this block:

```
═══════════════════════════════════════════════════
OPTIONS — {what is being chosen}
═══════════════════════════════════════════════════
Topic:          {summary of the decision point}
Recommended:    {N} (if you have a considered recommendation; otherwise "no single recommendation")
Your pick?      reply with option number, or "{N}, but change X" to modify

─── Option 1: {short evocative name} ───────────────
Essence:        {one-sentence characterization}
Inspired by:    {ref from research brief, with URL}
Best for:       {when this option wins}
Pros:
  + {pro}
  + {pro}
  + {pro}
Cons:
  − {con}
  − {con}
Risks:
  ⚠ {risk}
Fit for this project:
  {yes/partial/requires refactor — cite specific files/patterns}
Effort (AI-assisted):
  {estimate}

─── Option 2: {short evocative name} ───────────────
{same structure}

...

─── Option N: {short evocative name} ───────────────
{same structure}

═══════════════════════════════════════════════════
TRADEOFF MATRIX
═══════════════════════════════════════════════════
| Option | Simplicity | Performance | Flex | Cost | Risk | Fit |
|--------|------------|-------------|------|------|------|-----|
| 1      | ●●●○○      | ●●●●●       | ●●   | ●    | low  | ✓   |
| 2      | ●●○○○      | ●●●○○       | ●●●● | ●●   | med  | ~   |
| ...    | ...        | ...         | ...  | ...  | ...  | ... |
═══════════════════════════════════════════════════

Select by number. You can also say:
- "N, but {modification}"     — pick with changes
- "hybrid of N and M"         — composite
- "none of these, try {hint}" — regenerate
- "you pick"                  — delegate (will use "Recommended" above)
```

**After presenting, HALT. Do not proceed to synthesis until the user responds.** A response of `"you pick"` (or silence explicitly yielded by the user) is the ONLY acceptable delegation — and you must then announce "Going with Option N because {reason from research brief}" before continuing.

### Presentation Format — HTML Gallery (UI commands only)

For any options phase whose candidates have visual output (UI layouts, color palettes, typography systems, full-page designs), you MUST additionally render an HTML gallery:

```
1. mkdir -p docs/design-previews/options/{YYYY-MM-DD}-{slug}/
2. For each of the N candidates, generate a self-contained HTML file
   at docs/design-previews/options/{YYYY-MM-DD}-{slug}/option-{n}-{name}.html
   that demonstrates the option as a real-looking mockup (not lorem-ipsum —
   use domain-accurate content from Step 1's context).
3. Generate an index gallery at docs/design-previews/options/{YYYY-MM-DD}-{slug}/index.html
   that embeds all N options as <iframe> or <object> tiles in a responsive
   grid (3 columns desktop, 2 tablet, 1 mobile), each tile labeled
   "Option N: {name}" with "view full" link and "pick this" button that
   copies "N" to the user's clipboard.
4. The gallery MUST be 100% self-contained — no CDN, no external
   fonts-cdn, no network dependencies. Use system fonts or inline
   @font-face data URIs.
5. After generating, print the absolute file:// URL for the index page so
   the user can open it in one click.
```

The HTML gallery does NOT replace the numbered pros/cons table — it accompanies it. The user sees the numbered table in the conversation AND opens the HTML gallery for visual comparison. They pick by replying with the option number.

### Visual Direction Starter Catalog (for UI options)

When generating 10 UI visual directions, draw from (mix, don't repeat):

```
Aesthetic families — pick distinct families, not variations
  1.  Editorial / newspaper          — serif-heavy, column-driven, density
  2.  Swiss grid / poster            — type-as-hero, strict grid, negative space
  3.  Brutalist / monochrome         — raw, oversized type, zero ornament
  4.  Neo-brutalist                  — brutalist + saturated accents + hard shadows
  5.  Glassmorphism / frosted-glass  — translucent panes over rich backdrops
  6.  Neumorphic / soft-ui           — extruded surfaces, soft shadows
  7.  Bento grid                     — discrete content tiles, Apple-keynote-style
  8.  Terminal / CLI-aesthetic       — mono, scan-lines, green-on-black or amber
  9.  Skeuomorphic-modern            — textured surfaces, physical affordances
  10. Memphis / anti-design          — chaotic, playful, geometric chaos
  11. Corporate-memphis illustration — stylized human figures, flat vector
  12. Editorial-photo-led            — full-bleed imagery, overlay typography
  13. Data-dense / terminal-app       — small type, heavy information surface
  14. Pastel / soft-gradient         — gradient-heavy, playful Gen-Z aesthetic
  15. Dark-mode-first / cyberpunk    — neon accents, deep background
  16. Liquid-glass / Apple-visionOS  — frosted panels + orbital shadows
  17. Zine / print-offset            — halftone, dithering, CMYK-print feel
  18. Maximalist-animated            — motion-heavy, WebGL, bespoke transitions
  19. Document-as-app / Obsidian-like — dense text, markdown, sidebar-heavy
  20. Command-palette-first          — keyboard-driven, Raycast/Linear style
```

Map your 10 to 10 DIFFERENT families. Then within each family, adapt to the user's domain (HearthHut ≠ a DevTool).

---

## Integration Contract (how commands use this module)

Commands reference this module at two points:

1. **Research Phase** — replace the command's Research Phase with:
   > "Execute the Deep-Research Protocol in `${CLAUDE_PLUGIN_ROOT}/shared/_research_and_options.md`, covering Categories 1-8 (or the subset applicable). Produce the Research Brief before continuing."

2. **Options Phase** — insert before any synthesis step with:
   > "Generate at least N candidates per the Options-First Protocol in `${CLAUDE_PLUGIN_ROOT}/shared/_research_and_options.md` (count in the minimum-candidates table for this command + domain). Present with the numbered pros/cons template. {If UI:} Also render the HTML gallery per the template. HALT and await user selection."

---

## Anti-Rationalization (Research + Options edition)

| Rationalization | Reality | Correction |
|-----------------|---------|------------|
| "I already know the best N options" | Training data is biased toward popular/recent/English patterns. Real space is wider. | Run the queries. Every category. Find what you didn't already know. |
| "Negative research is pessimistic" | Postmortems are the highest-signal source in engineering. Free failure data. | Non-negotiable. Every decision must survive ≥2 known failure modes. |
| "10 UI options is too many" | The user explicitly asked for max-choice. Fatigue-by-curation beats regret-by-default. | Generate 10. Let the user skim. HTML gallery makes it 2 minutes of scrolling. |
| "My 10 options are all just slightly different" | Variations aren't options. See Divergence Rule. | Re-generate from 10 DIFFERENT aesthetic families / architectures / strategies. |
| "The user is busy, I'll just pick" | Busy users tolerate 30s to pick; they don't tolerate wrong-feature-rebuilt. | Present options. Picking is 30 seconds. Rebuilding is days. |
| "The space is too narrow for options" | Almost never true. If you think it is, name 3 axes and try again. | If truly narrow (rare), present that analysis explicitly and ask for approval. |
| "I'll just list alternatives in a footnote" | Footnotes don't drive decisions. A numbered picker does. | Promote options to the primary output, not Section 16. |
| "HTML gallery is overhead for UI" | It is THE differentiator for UI picks. Text descriptions of visual designs fail. | Build it. Every time the command has visual output. |
| "I researched enough" | Check the matrix — all 8 categories? ≥3 competitors? ≥2 anti-patterns? 3+ distinct orgs? | Complete the matrix. Partial research produces partial options. |
| "Context7 is slow" | 10 seconds of Context7 > 30 minutes of spec-divergence debugging later | Use it whenever a library is mentioned. |
| "The user said 'make it good', I'll just ship" | "Make it good" = "make me a good option to PICK from" | Options-First still applies. Present N candidates and the recommendation. |

---

## The Iron Law of Research + Options

```
CURATE THE DESIGN SPACE. LET THE USER CHOOSE.

No deep research  → partial options.
No options        → unapproved decisions.
No selection gate → the user is a spectator, not a collaborator.
```
