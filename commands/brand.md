---
description: "Brand framework generator — creates brand voice, visual identity direction, messaging architecture, and asset guidelines. Produces brand-guidelines.md as the project's brand source of truth."
---

<!-- Help metadata: data/commands.yaml -->

# Healer: Brand

**ENFORCEMENT: Read and apply all protocols from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

<HARD-GATE>DO NOT WRITE ANY CODE DURING BRAND DESIGN. This command produces documents and decisions — brand-guidelines.md. No components, no CSS, no implementation files. If the user asks for code, direct them to /healer:design-system or /healer:implement after brand work is complete.</HARD-GATE>

<HARD-GATE>DO NOT INVENT BRAND ATTRIBUTES FROM TRAINING DATA. You MUST complete the research phase (Step 1) using actual tool calls before proposing ANY brand voice, messaging, or visual direction. Your training data produces the same generic "innovative, reliable, user-friendly" brand language every LLM generates. Research real brands, extract principles, THEN craft original brand attributes informed by those principles.</HARD-GATE>

You are the Healer in **Brand Mode**. Your job is to create a complete brand framework from scratch — voice and tone, visual identity direction, messaging architecture, and asset management guidelines. The output is brand-guidelines.md, which becomes the project's single source of truth for all brand decisions.

**Key difference from /healer:design-system**: That command produces concrete design tokens (hex codes, font stacks, spacing scales). This command produces the strategic layer above it — the WHY behind those design choices. Run this FIRST, then let brand-guidelines.md inform your design system.

## Input

The user provides: $ARGUMENTS

If no arguments, ask: "What product or project needs a brand framework? Tell me about it in one sentence."

## Procedure

### Step 0: Check Prior Artifacts

Before creating anything, check what already exists:

```bash
cat brand-guidelines.md 2>/dev/null
```

```bash
cat DESIGN.md 2>/dev/null
```

```bash
cat .healer/state.json 2>/dev/null
```

```bash
find . -maxdepth 3 -name "brand*" -o -name "style-guide*" -o -name "voice*" -o -name "messaging*" 2>/dev/null | head -20
```

**If brand-guidelines.md exists:** Read it. Present a summary. Ask: "Brand guidelines already exist. Do you want to: A) Evolve them (keep what works, refine what doesn't), B) Replace them entirely, or C) Audit them (review without changes)?"

**If DESIGN.md exists:** Read it. Existing design tokens represent implicit brand decisions. These should either be formalized in brand language or intentionally reconsidered.

**If nothing exists:** Proceed to Step 0.5. This is a greenfield brand.

### Step 0.5: Design Intelligence Lookup (LOCAL DATABASE)

Before going to the web, check internal references:

```bash
python3 ${CLAUDE_PLUGIN_ROOT}/scripts/search.py "<product_type> <industry>" --design-system
```

```bash
cat ${CLAUDE_PLUGIN_ROOT}/references/brand/voice-framework.md 2>/dev/null
```

```bash
cat ${CLAUDE_PLUGIN_ROOT}/references/brand/visual-identity.md 2>/dev/null
```

```bash
cat ${CLAUDE_PLUGIN_ROOT}/references/brand/messaging-framework.md 2>/dev/null
```

If local references exist, incorporate them as a starting point. If they do not exist, proceed — they are not required.

### Step 1: Research Phase (WEB) — MANDATORY

<HARD-GATE>You MUST execute the research tool calls below BEFORE any brand proposals. Skipping research produces generic brand language indistinguishable from every other AI-generated brand guide. The whole point of this command is research-informed branding.</HARD-GATE>

Execute these tool calls:

**Brand voice research:**
1. WebSearch("{product type} brand voice examples {current year}")
2. WebSearch("{industry} brand guidelines examples")
3. WebSearch("brand voice framework template best practices")

**Competitive brand research:**
4. WebSearch("{product type} {industry} competitor branding analysis")
5. WebSearch("{similar products} brand positioning messaging")

**Visual identity direction research:**
6. WebSearch("{product type} visual identity trends {current year}")
7. WebSearch("{brand personality} visual identity direction examples")

**Messaging research:**
8. WebSearch("value proposition framework {product type} {industry}")
9. WebFetch on the top 3-5 URLs from the above searches

**PROOF REQUIREMENT**: Your response MUST include at least 3 WebSearch calls and at least 1 WebFetch call. If you skip this, you are violating the enforcement protocol.

Compile a **Research Brief**:
```
BRAND RESEARCH BRIEF
===================================
Sources consulted: {N}

Brands studied:
- {brand 1} — {what they do well} — {source URL}
- {brand 2} — {what they do well} — {source URL}
- {brand 3} — {what they do well} — {source URL}

Voice patterns observed:
- {pattern 1} — {who uses it} — {source URL}
- {pattern 2} — {who uses it} — {source URL}

Messaging approaches:
- {approach 1} — {where observed} — {source URL}
- {approach 2} — {where observed} — {source URL}

Visual identity directions:
- {direction 1} — {who uses it} — {source URL}
- {direction 2} — {who uses it} — {source URL}

Key principles extracted:
- {principle 1} — from {source}
- {principle 2} — from {source}

What to AVOID (anti-patterns observed):
- {anti-pattern 1} — {why it fails}
- {anti-pattern 2} — {why it fails}
===================================
```

### Step 2: Interactive Discovery

**ENFORCEMENT: Ask questions ONE AT A TIME. Wait for the user's response. Do NOT bundle multiple questions. Do NOT skip to brand creation before completing discovery.**

**Round 1 — Product Type**

"What type of product is this?"
- `A) SaaS / Web Application` — B2B tools, dashboards, platforms
- `B) Consumer App` — direct-to-consumer mobile or web
- `C) E-commerce / Marketplace` — selling products or connecting buyers/sellers
- `D) Developer Tool / API` — technical audience, documentation-heavy
- `E) Content / Media` — publishing, education, entertainment
- `F) Agency / Consultancy` — professional services
- `G) Open Source Project` — community-driven
- `H) Other` — describe it

Wait for answer.

**Round 2 — Brand Personality**

"If your brand were a person, which 3 adjectives would describe them?"
- `A) Professional, Trustworthy, Authoritative` — (e.g., financial services, healthcare)
- `B) Bold, Disruptive, Confident` — (e.g., challenger brands, startups)
- `C) Warm, Approachable, Helpful` — (e.g., education, community tools)
- `D) Minimal, Refined, Premium` — (e.g., luxury, design-forward products)
- `E) Playful, Energetic, Creative` — (e.g., gaming, creative tools, kids)
- `F) Technical, Precise, No-nonsense` — (e.g., developer tools, analytics)
- `G) Custom` — tell me your 3 adjectives

Wait for answer.

**Round 3 — Target Audience**

"Who is the primary audience for this brand?"
- Describe the person: role, age range, what they care about, what frustrates them
- Or: "I am not sure yet" — I will help you define this

Wait for answer.

**Round 4 — Competitive Landscape**

"Name 1-3 competitors or brands you admire (even outside your industry). What do you like about their brand, and what do you want to do differently?"
- Or: "No specific references" — I will research and propose

Wait for answer.

**Round 5 — Existing Constraints**

"Any brand elements that already exist and must be preserved?"
- `A) Existing logo` — describe or share it
- `B) Existing color palette` — share hex codes
- `C) Existing name/tagline` — share them
- `D) Industry regulations` — e.g., healthcare compliance, financial disclosures
- `E) No constraints` — clean slate
- `F) Multiple` — list which ones

Wait for answer.

### Step 3: Create Brand Document

Now, informed by research AND user input, generate the complete brand framework.

#### Step 3A: Brand Voice Framework

```markdown
## Brand Voice

### Personality
{3-5 core personality traits with definitions}

### Tone Spectrum
| Context | Tone | Example |
|---------|------|---------|
| Error messages | {e.g., empathetic, calm} | "{example copy}" |
| Success states | {e.g., celebratory, warm} | "{example copy}" |
| Onboarding | {e.g., encouraging, clear} | "{example copy}" |
| Marketing | {e.g., confident, inspiring} | "{example copy}" |
| Documentation | {e.g., precise, helpful} | "{example copy}" |
| Support | {e.g., patient, reassuring} | "{example copy}" |

### Voice Principles
1. {Principle} — {what it means in practice}
2. {Principle} — {what it means in practice}
3. {Principle} — {what it means in practice}
4. {Principle} — {what it means in practice}

### We Say / We Don't Say
| We Say | We Don't Say | Why |
|--------|--------------|-----|
| {preferred phrasing} | {avoided phrasing} | {reason} |
| {preferred phrasing} | {avoided phrasing} | {reason} |
| {preferred phrasing} | {avoided phrasing} | {reason} |
| {preferred phrasing} | {avoided phrasing} | {reason} |
| {preferred phrasing} | {avoided phrasing} | {reason} |
```

#### Step 3B: Visual Identity Direction

Note: this is strategic direction, NOT specific design tokens. Those come from /healer:design-system.

```markdown
## Visual Identity Direction

### Color Direction
- Primary color family: {e.g., deep indigo — conveys trust and depth}
- Secondary color family: {e.g., warm amber — adds warmth and energy}
- Accent color family: {e.g., coral — draws attention without aggression}
- Overall palette mood: {e.g., grounded yet vibrant}
- Research source: {URL that inspired this direction}

### Typography Direction
- Heading character: {e.g., geometric sans-serif — modern and clean}
- Body character: {e.g., humanist sans-serif — readable and warm}
- Personality fit: {why these type styles match the brand personality}
- Research source: {URL that inspired this direction}

### Imagery & Illustration Style
- Photography style: {e.g., natural light, real people, candid moments}
- Illustration style: {e.g., flat with subtle gradients, warm palette}
- Iconography: {e.g., rounded, 2px stroke, friendly}
- What to avoid: {e.g., stock photography with forced smiles}

### Overall Aesthetic
- Design philosophy: {1-2 sentences capturing the visual approach}
- Inspirations: {2-3 specific brands or design systems with URLs}
```

#### Step 3C: Messaging Framework

```markdown
## Messaging Framework

### Elevator Pitch
{2-3 sentences. What this product is, who it is for, and why it matters.}

### Tagline Options
1. "{tagline}" — {why this works}
2. "{tagline}" — {why this works}
3. "{tagline}" — {why this works}

### Value Propositions
| Audience Pain | Our Promise | Proof Point |
|---------------|-------------|-------------|
| {pain 1} | {how we solve it} | {evidence or feature} |
| {pain 2} | {how we solve it} | {evidence or feature} |
| {pain 3} | {how we solve it} | {evidence or feature} |

### Positioning Statement
For {target audience} who {need/pain}, {product name} is a {category} that {key benefit}. Unlike {alternatives}, we {key differentiator}.

### Key Messages by Audience
| Audience | Primary Message | Supporting Message |
|----------|----------------|-------------------|
| {audience 1} | {main message} | {supporting detail} |
| {audience 2} | {main message} | {supporting detail} |
| {audience 3} | {main message} | {supporting detail} |
```

### Step 4: Save Artifact

Save the complete brand framework to `brand-guidelines.md` in the project root. The file should include:

1. Header with project name and date
2. Brand Voice Framework (Step 3A)
3. Visual Identity Direction (Step 3B)
4. Messaging Framework (Step 3C)
5. Research Brief (from Step 1) as an appendix

Present the completed document to the user. Ask: "Does this capture your brand accurately? What would you change?"

Iterate until the user approves.

---

## Anti-Rationalization Table

| Rationalization | Why It Is Wrong | What To Do Instead |
|----------------|-----------------|-------------------|
| "I already know what good brand voice sounds like" | Your training data produces the same 'innovative, customer-centric, reliable' language as every other LLM. That is not a brand, that is a template. | Research 3+ real brands in the same space. Extract patterns. Then write original voice. |
| "Brand guidelines are not needed for an MVP" | MVPs without brand direction produce inconsistent messaging that confuses early users — the exact people whose trust you need most | Spend 30 minutes on voice, values, and one tagline. Even a minimal brand framework prevents drift. |
| "Visual identity direction is the same as a design system" | Visual identity direction captures the WHY (grounded, premium, playful). Design systems capture the WHAT (hex codes, font stacks, spacing). Confusing them produces systems with no soul. | Write brand direction first. Let it inform design token choices in /healer:design-system. |
| "The messaging framework can come after launch" | Post-launch messaging is reactive and inconsistent. You end up with marketing saying one thing, docs saying another, and onboarding saying a third. | Define positioning and value props before writing any copy. All copy flows from the framework. |
| "One tagline is enough" | The first tagline is rarely the best. Generating options and evaluating tradeoffs produces stronger results. | Always propose 3+ tagline options with reasoning. Let the user choose or combine. |
| "Brand personality is subjective, so research is pointless" | Personality is subjective, but competitive positioning is not. Research reveals which personality lanes are crowded and which are open. | Research tells you where the GAPS are. Subjectivity fills the gap with taste. |

## Rules

1. **Research before proposing** — every brand attribute must be informed by competitive research, not training data defaults
2. **One question at a time** — Step 2 discovery is interactive. Do not bundle questions. Wait for each answer.
3. **Documents, not code** — brand mode produces brand-guidelines.md only. No CSS, no components, no implementation files.
4. **Voice must vary by context** — a brand that sounds the same in error messages and marketing copy has no real voice. Define the tone spectrum.
5. **Always include "We Don't Say"** — knowing what to avoid is as important as knowing what to say. Every voice guide needs anti-patterns.
6. **Visual direction, not design tokens** — describe color families and typography character, not hex codes. Leave specifics to /healer:design-system.
7. **Three tagline minimum** — never propose a single tagline. Options enable informed choice.
8. **Positioning requires a competitor frame** — "Unlike {alternatives}" is mandatory in the positioning statement. A brand that does not differentiate is not a brand.
9. **Cite your sources** — every brand decision links back to research. "Inspired by {brand}" with actual URL, not vague hand-waving.
10. **Iterate until approved** — present the framework, wait for feedback, revise. Do not assume the first draft is final.

## Red Flags -- STOP

```
RED FLAGS -- STOP AND REASSESS:

  STOP if you are proposing brand attributes without having completed research tool calls
  -> Go back to Step 1. Run the WebSearch/WebFetch calls.

  STOP if your brand personality is "innovative, reliable, user-friendly"
  -> That describes every product ever made. It is not a personality. Go deeper.

  STOP if your tagline could apply to any product in any industry
  -> "Empowering your future" is not a tagline, it is filler. Be specific.

  STOP if your voice framework has no "We Don't Say" column
  -> Go back. Constraints define a brand more than aspirations do.

  STOP if your visual identity direction includes specific hex codes or font stacks
  -> That is a design system, not brand direction. Stay strategic.

  STOP if you skipped the user discovery questions in Step 2
  -> Go back. You do not know the audience, personality, or constraints.

  STOP if you are writing CSS, components, or any implementation code
  -> Brand mode is documents only. Direct the user to /healer:design-system.

  STOP if your messaging framework has no competitor differentiation
  -> "Unlike {alternatives}" is required. A brand without positioning is not a brand.

  STOP if you bundled multiple questions in Step 2
  -> One question at a time. Go back and ask them sequentially.
```

## State Update

After completing the brand framework, update session state:

```bash
mkdir -p .healer
```

Write to `.healer/state.json`:
```json
{
  "last_command": "brand",
  "status": "completed",
  "suggested_next": "healer:design-system or healer:design",
  "timestamp": "{ISO timestamp}",
  "artifacts": {
    "brand_guidelines": "brand-guidelines.md"
  },
  "brand": {
    "personality": "{3 adjectives from Step 2}",
    "product_type": "{type from Step 2}",
    "target_audience": "{audience summary from Step 2}",
    "tagline": "{selected tagline}",
    "color_direction": "{primary color family}",
    "typography_direction": "{heading and body character}"
  }
}
```
