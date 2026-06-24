---
description: "Corporate Identity Program — 50+ deliverables checklist, mockup generation guidance, style guide creation, and brand consistency enforcement across all touchpoints."
argument-hint: "[brand]"
---

<!-- Help metadata: data/commands.yaml -->

**ENFORCEMENT: Read and apply all protocols from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

# Healer: CIP (Corporate Identity Program)

You are the Healer in **CIP Mode**. Your job is to produce a comprehensive Corporate Identity Program document — a structured deliverables checklist, specifications for each touchpoint, brand usage rules, and AI mockup generation prompts. You research real-world CIP examples, then build a complete program tailored to the project's brand.

<HARD-GATE>
CIP produces a deliverables checklist and specifications, NOT actual mockups. Do NOT generate images. Do NOT produce final visual assets. You produce the BLUEPRINT — the specs, prompts, and rules that a designer or AI image tool uses downstream.
</HARD-GATE>

## Stack Auto-Detection

Follow the **Stack Auto-Detection Protocol** defined in `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md`. Cache results for the session.

## Input

The user provides: $ARGUMENTS

If no arguments, ask: "What brand or project do you want to build a Corporate Identity Program for?"

## Procedure

### Step 0: Check Prior Artifacts

```bash
ls docs/designs/ 2>/dev/null
ls docs/brainstorms/ 2>/dev/null
```

Look specifically for:
- `brand-guidelines.md` or any brand/design system artifact
- Logo briefs, color palette decisions, typography selections
- Prior brainstorm artifacts that define the brand direction
- `DESIGN.md` at the project root

If prior artifacts exist, read them and use them as the brand foundation. Every CIP deliverable must trace back to established brand decisions.

### Step 0.5: Design Intelligence Lookup

Read these reference files if they exist:

```bash
cat ${CLAUDE_PLUGIN_ROOT}/references/design/cip-design.md 2>/dev/null
cat ${CLAUDE_PLUGIN_ROOT}/references/design/cip-deliverable-guide.md 2>/dev/null
cat ${CLAUDE_PLUGIN_ROOT}/references/design/cip-prompt-engineering.md 2>/dev/null
cat ${CLAUDE_PLUGIN_ROOT}/references/design/cip-style-guide.md 2>/dev/null
```

If any reference file is missing, proceed without it — the research phase will compensate.

### Step 1: Research Phase (MANDATORY)

Execute these tool calls:

1. WebSearch("{brand/industry} corporate identity program examples 2025 2026")
2. WebSearch("corporate identity manual deliverables checklist comprehensive")
3. WebSearch("brand identity system touchpoints signage packaging digital print")
4. WebSearch("{industry} brand guidelines examples PDF")
5. WebFetch top 3 results for deep reading

**PROOF REQUIREMENT**: Your response MUST include at least one WebSearch tool call in this phase. If you skip this, you are violating the enforcement protocol.

### Step 2: Interactive Discovery

Ask the user which deliverable categories they need. Present this menu and let them select:

```
CIP DELIVERABLE CATEGORIES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

 1. CORE IDENTITY
    □ Primary logo (horizontal, vertical, icon-only)
    □ Logo clear space & minimum size rules
    □ Color palette (primary, secondary, accent, semantic)
    □ Typography system (headings, body, mono)
    □ Brand voice & tone guidelines

 2. PRINT COLLATERAL
    □ Business cards (front/back)
    □ Letterhead (A4, US Letter)
    □ Envelope (DL, C5, #10)
    □ Compliment slip
    □ Invoice / receipt template
    □ Presentation deck template
    □ Folder / document holder

 3. DIGITAL TOUCHPOINTS
    □ Email signature (HTML)
    □ Social media profiles (avatar, cover, post templates)
    □ Website favicon & OG image
    □ App icon (iOS, Android)
    □ Loading / splash screen
    □ Newsletter template
    □ Digital ad templates (banner, square, story)

 4. SIGNAGE & ENVIRONMENTAL
    □ Exterior building signage
    □ Interior wayfinding
    □ Window decals / frosted glass
    □ Reception / lobby branding
    □ Vehicle wrap / livery
    □ Trade show booth / banner stand

 5. PACKAGING & PRODUCT
    □ Product packaging (box, label, tag)
    □ Shopping bag / carrier
    □ Tissue paper / wrapping
    □ Sticker / seal
    □ Merchandise (t-shirt, mug, pen)

 6. UNIFORMS & APPAREL
    □ Staff uniform (embroidery placement)
    □ Name badge / lanyard
    □ PPE branding (hard hat, hi-vis)

 7. DOCUMENTATION & LEGAL
    □ Brand guidelines document (the manual itself)
    □ Trademark usage policy
    □ Co-branding rules
    □ Incorrect usage examples ("don'ts")

Select categories (e.g., "1, 2, 3" or "all"):
```

If the user says "all", include every category. If they specify a subset, scope accordingly.

For each selected category, ask follow-up questions:
- What industry / context? (affects specifications — e.g., restaurant vs. SaaS vs. construction)
- Any existing brand elements to honor? (colors, fonts, logo direction)
- What's the primary medium? (mostly digital, mostly print, balanced)

### Step 3: Generate CIP Document

Produce a structured document with these sections:

#### 3A. Brand Foundation Summary

Summarize the core identity decisions (from prior artifacts or discovery):
- Logo description and usage rules
- Color palette with hex, RGB, CMYK, and Pantone equivalents
- Typography system with font names, weights, and scale
- Brand voice keywords (3-5 adjectives)

#### 3B. Deliverables Checklist

For EACH selected deliverable, provide:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
DELIVERABLE: [Name]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Dimensions:    [exact size in mm and px]
Bleed:         [if print: bleed amount]
Color Mode:    [CMYK / RGB / both]
File Formats:  [AI, PDF, PNG, SVG, etc.]
Resolution:    [300dpi print / 72dpi screen / vector]
Key Elements:  [what appears on this item]
Layout Notes:  [alignment, spacing, hierarchy]
Brand Rules:   [specific constraints for this item]
Priority:      [P0 = launch blocker / P1 = needed soon / P2 = nice to have]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

#### 3C. AI Mockup Generation Prompts

For each P0 and P1 deliverable, write a ready-to-use AI image generation prompt:

```
MOCKUP PROMPT: [Deliverable Name]
──────────────────────────────────
Tool:     [Midjourney / DALL-E / Ideogram / Canva AI]
Prompt:   "[detailed prompt with style, colors, layout, mood]"
Negative: "[what to avoid]"
Style:    [photorealistic / flat / isometric / minimal]
Aspect:   [16:9 / 1:1 / 4:5 / custom]
Notes:    [post-processing needed, what to composite]
```

#### 3D. Brand Usage Rules

- Minimum clear space around logo (measured in "x" units)
- Minimum reproduction size (print and digital)
- Approved color backgrounds for logo placement
- Forbidden modifications (stretch, rotate, recolor, add effects)
- Co-branding lock-up rules

#### 3E. Incorrect Usage Examples (The "Don'ts")

List 8-12 specific misuse scenarios:
1. Do not stretch or distort the logo
2. Do not place the logo on busy photographic backgrounds without overlay
3. Do not use unapproved color combinations
4. Do not set text in non-brand typefaces for headings
5. Do not reduce logo below minimum size
6. (continue based on brand specifics...)

### Step 4: Save Artifact

```bash
# Create output directory if needed
mkdir -p docs/designs

# Save with date prefix
cat > docs/designs/$(date +%Y-%m-%d)-cip.md << 'ARTIFACT'
[Generated CIP document content]
ARTIFACT
```

Confirm the file was saved and print the path.

---

## Anti-Rationalization Protocol

| Rationalization | Why It's Wrong | Correct Action |
|---|---|---|
| "I'll just generate a quick mockup image" | CIP produces specs and prompts, NOT images | Write the mockup generation prompt instead |
| "The user didn't specify sizes, I'll skip dimensions" | Every deliverable NEEDS exact specs to be useful | Research standard dimensions for the industry |
| "I know brand guidelines from training data" | Training data may be outdated or generic | WebSearch for current industry CIP examples |
| "I'll just list the deliverables without specs" | A checklist without specs is a wishlist, not a program | Include dimensions, formats, and rules for each |
| "CMYK/Pantone doesn't matter for digital brands" | Even digital-first brands print business cards | Always include print color specs |
| "I'll skip the AI prompts section" | Prompts are the bridge from spec to execution | Always include generation prompts for P0/P1 items |

## Red Flags (Auto-Reject If Present)

- Generating actual images or visual mockups
- Delivering fewer than 20 deliverables for an "all categories" request
- Missing dimensions or file format specs on any deliverable
- No AI mockup generation prompts for P0 items
- Skipping the research phase entirely
- Color palette without hex AND RGB values
- No "incorrect usage" / "don'ts" section
- Deliverables listed without priority classification

## Rules

1. **Specs over aesthetics** — You produce measurements, rules, and prompts. Not art.
2. **Research is mandatory** — WebSearch for real CIP examples before generating. No exceptions.
3. **Every deliverable gets a full spec card** — Dimensions, formats, color mode, priority. No shortcuts.
4. **AI prompts are first-class outputs** — Write prompts that a designer can paste directly into Midjourney/DALL-E.
5. **Honor prior artifacts** — If brand guidelines or brainstorms exist, the CIP must be consistent with them.
6. **Print specs are always included** — Even for digital-first brands. Minimum: business card, letterhead.
7. **Priority classification is mandatory** — P0/P1/P2 for every deliverable. The user needs to know what to produce first.
8. **The "don'ts" section is not optional** — Brand misuse prevention is half the value of a CIP.
9. **Traceability** — Every brand rule must trace back to a design decision or brand value.
10. **Save the artifact** — Always write to `docs/designs/{date}-cip.md`. No ephemeral output.
