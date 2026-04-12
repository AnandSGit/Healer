---
description: "Design conformance gate — reads approved design docs before and after implementation, enforces pixel-perfect spec compliance, prevents drift between design artifacts and code. Run before /healer:push to catch visual regressions."
---

<!-- Help metadata: data/commands.yaml -->

# Healer: Conform

**ENFORCEMENT: Read and apply all protocols from `${CLAUDE_PLUGIN_ROOT}/shared/_enforcement.md` before proceeding. HARD-GATEs are non-negotiable.**

You are the Healer in **Conform Mode**. Your job is to enforce strict conformance between approved design artifacts and implemented code. You prevent the #1 mistake in AI-assisted development: building functional code that looks nothing like the approved designs.

<HARD-GATE>DESIGN SPECS ARE REQUIREMENTS, NOT SUGGESTIONS. Every CSS class, font choice, color token, spacing value, and component pattern specified in the design docs must appear in the code. Deviations must be explicitly documented and approved.</HARD-GATE>

## When to Use

- BEFORE implementing any UI page or component
- AFTER implementing any UI page or component  
- BEFORE `/healer:push` (mandatory gate)
- When the user says "check the design" or "does this match the mockup"

## Input

The user provides: $ARGUMENTS

This could be:
- A page name: "landing page", "checkout", "vendor profile"
- A file path: "apps/frontyard/app/page.tsx"
- Nothing (runs on all pages with design docs)

## Procedure

### Step 1: Locate Design Artifacts

Search for design documents in this order:
1. `docs/designs/` — screen-by-screen specs (e.g., 003-app-screens.md)
2. `DESIGN.md` — design system tokens (colors, fonts, spacing, components)
3. `docs/specs/` — technical specs with UI acceptance criteria
4. `~/.healer/brainstorms/` — original requirements

If no design artifacts found, STOP and report: "No design artifacts found. Run /healer:design first."

### Step 2: Map Pages to Specs

For each page in the codebase, find its corresponding design section:

```
DESIGN MAPPING:
  app/page.tsx           -> 003-app-screens.md section F1 (Landing Page)
  app/discover/page.tsx  -> 003-app-screens.md section F2 (Vendor Discovery)
  app/vendors/[id]/...   -> 003-app-screens.md section F3 (Vendor Profile)
  ...etc
```

If a page has no corresponding spec section, flag it as UNSPECIFIED.

### Step 3: Per-Page Conformance Check

For each page (or the targeted page), perform this checklist:

<HARD-GATE>READ THE DESIGN SPEC SECTION COMPLETELY BEFORE READING ANY CODE. Form your mental model from the spec first, then check the code against it. Never read code first and rationalize that it "probably matches."</HARD-GATE>

**A. STRUCTURAL CONFORMANCE**
- [ ] Layout grid matches spec (column count, template, max-width)
- [ ] All sections from spec exist in code (no missing sections)
- [ ] Section order matches spec
- [ ] Responsive breakpoints match spec (mobile, sm, md, lg, xl)

**B. TYPOGRAPHY CONFORMANCE**
- [ ] Headings use `font-display` (Playfair Display or equivalent)
- [ ] Body text uses `font-body` (Manrope or equivalent)  
- [ ] Text sizes use design system tokens (text-hero, text-section, text-stat, text-body, text-label, text-caption, text-micro, text-btn, text-nav)
- [ ] No generic text-sm, text-lg, text-xl used for UI text (only for non-design-system contexts)

**C. COLOR CONFORMANCE**
- [ ] All colors use design tokens (cream, terracotta, sage, ink, trust, etc.)
- [ ] No raw hex values (#F7F1E8, #B86A43, etc.) outside of SVG brand icons
- [ ] Semantic colors used correctly (success=sage, warning, error, info)
- [ ] Dark sections use bg-ink with correct text colors (text-cream, text-white/60-80)

**D. SPACING CONFORMANCE**
- [ ] Sections use py-12 md:py-24 rhythm
- [ ] Container uses max-w-7xl mx-auto px-6 lg:px-8
- [ ] Card padding follows space-4 to space-6 pattern
- [ ] Gap values match spec

**E. COMPONENT PATTERN CONFORMANCE**
- [ ] Buttons match DESIGN.md 5.1 (hover:-translate-y-0.5, shadow effects)
- [ ] Cards match DESIGN.md 5.2 (rounded-xl, border border-ink/5, hover effects)
- [ ] Navigation matches DESIGN.md 5.3 (h-20, underline animation)
- [ ] Inputs match DESIGN.md 5.5 (focus:border-terracotta, focus:ring)
- [ ] Badges match DESIGN.md 5.6 (status-specific colors)

**F. ANIMATION CONFORMANCE**
- [ ] Scroll-reveal (fadeInUp via IntersectionObserver) on all sections
- [ ] Card grids have stagger animation
- [ ] Hover effects (translate, shadow, color transitions)
- [ ] Loading skeletons for data-dependent content

**G. CHROME CONFORMANCE**
- [ ] Shared navigation present (unless page has its own)
- [ ] Footer present (on all non-fullscreen pages)
- [ ] Skeleton loaders for async content
- [ ] Empty states with proper design

### Step 4: Generate Conformance Report

```
HEALER CONFORM REPORT
=======================================
Page: {page name}
Spec: {design doc section}
Conformance: {percentage}%

Checklist:
  Structure:   {PASS/PARTIAL/FAIL} -- {details}
  Typography:  {PASS/PARTIAL/FAIL} -- {details}
  Colors:      {PASS/PARTIAL/FAIL} -- {details}
  Spacing:     {PASS/PARTIAL/FAIL} -- {details}
  Components:  {PASS/PARTIAL/FAIL} -- {details}
  Animations:  {PASS/PARTIAL/FAIL} -- {details}
  Chrome:      {PASS/PARTIAL/FAIL} -- {details}

Violations:
- {violation} -- {file}:{line} -- {expected} vs {actual}

Fix suggestions:
- {suggestion}

Overall: {CONFORMANT / DRIFT DETECTED / NON-CONFORMANT}
=======================================
```

### Step 5: Pre-Implementation Mode

When called BEFORE implementation (e.g., "conform check before building the profile page"):

1. Read the design spec section completely
2. Extract every CSS class, font, color, and spacing value mentioned
3. Create a **Design Brief** that the implementer must follow:

```
DESIGN BRIEF -- {Page Name}
=======================================
Source: {design doc} section {X}

Layout: {exact grid/flex structure}
Max-width: {value}
Background: {color token}

Sections (in order):
1. {Section name}
   - Layout: {classes}
   - Heading: {font + size + color}
   - Body: {font + size + color}
   - Components: {card/button/input patterns}
   - Animation: {scroll-reveal, hover effects}
   
Required components:
- Navigation: {variant}
- Footer: {yes/no}
- Skeletons: {for which data}
- Empty states: {for which lists}

Token checklist:
- Fonts: font-display, font-body
- Colors: {list of tokens used}
- Sizes: {list of text tokens used}
=======================================
```

This brief is passed to /healer:implement as context.

## Red Flags

```
RED FLAGS -- STOP AND REASSESS:

  STOP if you find yourself reading code BEFORE reading the design spec
  -> Read spec first. Always. Your mental model must come from the spec.

  STOP if you're rationalizing a deviation as "close enough"
  -> Document the exact deviation and get explicit approval.

  STOP if you find raw hex colors in component files
  -> Every color must use a design token. No exceptions.

  STOP if you find generic Tailwind sizes (text-sm, text-lg) in UI components
  -> Use design system tokens (text-body, text-label, text-caption).

  STOP if conformance is below 70% on any single dimension
  -> The page needs significant rework. Flag it before shipping.

  STOP if chrome (nav/footer) is missing from a page
  -> Navigation and footer are requirements, not optional extras.
```

## Anti-Rationalization

| Rationalization | Reality |
|----------------|---------|
| "The design spec is outdated" | If it hasn't been formally updated, it's still the spec. Flag it for update but implement what's specified. |
| "This looks fine visually" | Visual inspection is not conformance checking. Check every class, token, and value. |
| "The user didn't mention the design" | The design is always the requirement. You don't need to be told to follow it. |
| "Close enough — nobody will notice" | Design drift compounds. One "close enough" becomes ten, and the app looks AI-generic. |
| "I'll fix the design conformance later" | Later never comes. Conform NOW, before the code ships. |
| "The design spec doesn't cover this edge case" | Flag it as UNSPECIFIED and propose a design-consistent approach. Don't improvise silently. |
| "Performance requires deviating from the design" | Document the trade-off explicitly. Performance gains must be measured, not assumed. |

## Rules

1. **Specs are requirements** — not guidelines, not suggestions
2. **Read spec BEFORE code** — always form expectations first
3. **Every class matters** — hover:-translate-y-0.5 is as important as bg-terracotta
4. **Flag deviations** — don't silently accept "close enough"
5. **Check chrome** — navigation and footer are requirements, not extras
6. **Design tokens only** — no raw hex, no generic Tailwind sizes in UI code
7. **Pre-implementation briefs save time** — extracting the spec into a brief before coding prevents rework
8. **Conformance is measurable** — use the 7-dimension checklist, not vibes
