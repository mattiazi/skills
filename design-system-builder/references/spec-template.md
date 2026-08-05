# Output template: the design system spec

Produce the design system as a single Markdown document following the structure below **in this order**. This is a template, not a form to copy verbatim — adapt headings to the project and cut a section only if it genuinely doesn't apply (say so if you do). Every value must be real and specific.

Two rules that apply everywhere:

- **Interleave the two layers.** In each section, give the *rules and rationale* in prose, then the *values* in a fenced code block. Use semantic names (`--color-surface`, not `--color-1`).
- **Resolve everything to a concrete value.** No placeholders. Colors are hex (or other real color syntax). Fonts are full stacks with fallbacks and a source. Sizes, radii, durations are numbers with units.

---

## 1. Directive preamble (this makes the doc a usable prompt)

Open with a short instruction block addressed to the agent that will consume the spec. Roughly:

> **Build [product] using the design system below.** [Product] is [one line]. Follow these rules exactly: use only the defined tokens, honor the stated voice in all copy, and treat the signature element as the centerpiece. Where this spec is silent, choose the option most consistent with the stated direction.

Keep it to a few sentences. Then a one-paragraph **creative direction / thesis**: the aesthetic point of view, why it fits this subject, and the named signature element.

## 2. Brand foundation

- **Personality** — the 3–5 adjectives, each with a sentence on how it shows up in the UI.
- **What to avoid** — the looks/words/clichés that would betray this brand (including any relevant generic defaults).
- **Signature element** — name it explicitly and describe how it's executed and where it appears.

## 3. Color

Prose: the palette concept, how it maps to meaning, light/dark handling, and contrast notes (state the ratio for primary text-on-background and for the primary button — must clear WCAG AA, i.e. ≥ 4.5:1 for body text, ≥ 3:1 for large text/UI).

Then a token block — semantic, not just raw swatches:

```css
:root {
  /* Core */
  --color-bg:            #......;  /* page background */
  --color-surface:       #......;  /* cards, panels */
  --color-text:          #......;  /* primary text — contrast on bg: X.X:1 */
  --color-text-muted:    #......;
  --color-border:        #......;

  /* Brand + accent */
  --color-primary:       #......;
  --color-primary-hover: #......;
  --color-on-primary:    #......;  /* text/icon on primary */
  --color-accent:        #......;

  /* Status */
  --color-success:       #......;
  --color-warning:       #......;
  --color-danger:        #......;
}
```

If the system is dark or supports both, give the dark values too (e.g. a `:root[data-theme="dark"]` block).

## 4. Typography

Prose: the display/body pairing and *why this pairing* (not a default), the role of each face, and any utility/mono face. State where to get each font (Google Fonts, system stack, foundry).

```css
:root {
  --font-display: "Name", <fallbacks>;   /* source: ... */
  --font-body:    "Name", <fallbacks>;   /* source: ... */
  --font-mono:    "Name", <fallbacks>;   /* if used */

  /* Type scale (rem). Name the steps by role, not just size. */
  --text-display: ...rem/...;   /* size/line-height */
  --text-h1:      ...rem/...;
  --text-h2:      ...rem/...;
  --text-h3:      ...rem/...;
  --text-body:    1rem/1.5;
  --text-small:   ...rem/...;
  --text-caption: ...rem/...;
}
```

Add a short **usage** note: which weights to use, letter-spacing/tracking for display vs body, and any treatment that belongs to the signature.

## 5. Spacing, layout & shape

Prose: the spatial feel (airy / dense / rhythmic), the grid, breakpoints, container widths, and how generous or tight the system is.

```css
:root {
  /* Spacing scale (consistent ratio, e.g. 4px base) */
  --space-1: ...; --space-2: ...; --space-3: ...; --space-4: ...;
  --space-6: ...; --space-8: ...; --space-12: ...; --space-16: ...;

  /* Radii */
  --radius-sm: ...; --radius-md: ...; --radius-lg: ...; --radius-full: 9999px;

  /* Elevation / shadow */
  --shadow-sm: ...;
  --shadow-md: ...;
  --shadow-lg: ...;

  /* Layout */
  --container-max: ...px;
  --breakpoint-sm: ...px; --breakpoint-md: ...px; --breakpoint-lg: ...px;
}
```

## 6. Components

For each core component, give the **rules and states** in prose plus the token references it uses — not full CSS. Cover at minimum: **buttons** (primary / secondary / ghost; default, hover, active, focus, disabled), **inputs/forms** (incl. focus and error), and **cards**. Add others the project needs (nav, badges, tabs, modals…).

Each component should reference the tokens above rather than inventing new values. Always specify the **focus state** (visible keyboard focus is the accessibility floor).

Example shape:

> **Button — primary**
> Background `--color-primary`, text `--color-on-primary`, radius `--radius-md`, padding `--space-3 --space-5`, weight 600.
> Hover → `--color-primary-hover`. Focus → 2px outline `--color-accent`, offset 2px. Disabled → 50% opacity, no pointer.

## 7. Iconography & imagery

Direction for icon style (line vs solid, weight, corner treatment) and for photography/illustration (subject matter, treatment, what's off-limits). Tie both back to the signature where possible. Concrete do's and don'ts.

## 8. Motion

Prose principles (restrained vs expressive) plus values:

```css
:root {
  --motion-fast:   ...ms;
  --motion-base:   ...ms;
  --motion-slow:   ...ms;
  --ease-standard: cubic-bezier(...);
  --ease-emphasis: cubic-bezier(...);
}
```

Name 1–2 signature motion moments (page-load, scroll reveal, hover) and state that reduced-motion preferences must be respected.

## 9. Tone of voice & copy rules

This is design material — treat it with the same rigor as color.

- **Voice attributes** — 3–4, each contrasting ("confident but not boastful"), with a sentence each.
- **Mechanics** — casing (sentence case vs title case), person (you/we), contractions, emoji policy, terminology to use and to avoid.
- **Microcopy patterns** — buttons (active voice, name the action), errors (what went wrong + how to fix, in the brand's voice, no apologizing), empty states (invitation to act).
- **Real examples** — write actual sample copy for this brand: a primary CTA, one error message, one empty-state line, and a one-line value proposition. Generic examples don't count.

## 10. Consolidated tokens (for lifting into a repo)

End with one fenced block gathering every token defined above into a single `:root { … }` (and dark variant if any), so Claude Code can copy it wholesale. Note that it converts 1:1 to a `tokens.json` if the team prefers JSON.

---

After the document, in chat (not in the file), remind the user they can paste it into Claude Design to build, or drop it into a repo for Claude Code — and offer to refine any section.
