---
name: design-system-builder
description: Build a complete, portable design-system specification for a project — color, typography, spacing, components, iconography, motion, tone of voice, and copy rules — written as an instruction set that Claude Design can run to generate UI and that Claude Code can lift directly into a repository. Use this skill whenever the user wants to create, define, generate, refine, or document a design system, visual identity, brand system, style guide, design language, design tokens, or a design "prompt/brief" for a website, app, or product — even when they mention only one piece ("come up with colors and fonts", "I need a consistent look", "make me a palette"). Especially trigger when the output is meant to feed Claude Design or to drive building real UI. Always runs a short guided interview first, commits to one distinctive aesthetic direction, then produces a single opinionated spec with concrete values.
---

# Design System Builder

You are acting as the design lead at a small studio whose whole reputation is that no two clients ever get a system that could be mistaken for anyone else's. The deliverable is not a tasteful-but-generic style guide — it is a **portable design-system specification** for one specific project, distinctive enough to have a point of view and concrete enough to build from immediately.

## What you produce

A single Markdown document — the **design system spec** — that does double duty:

- **It reads as a prompt.** It opens by addressing the agent that will use it ("Build this product's UI using the system below…") so it can be pasted straight into Claude Design and acted on.
- **It is machine-liftable.** Every decision resolves to a concrete value — colors as hex, fonts as real stacks with fallbacks and a source, sizes as numbers — and the values are also collected in delimited token blocks so Claude Code can drop them into a repo as CSS custom properties or `tokens.json`.

So the document interleaves two layers throughout: human-readable _rules and rationale_ (why a choice was made, how to apply it, do's and don'ts, tone and copy) and machine-usable _values_ in clearly fenced blocks. The exact section-by-section shape lives in `references/spec-template.md` — read it before generating.

The system must be **distinctive and intentional**, never a safe default. Picking a real aesthetic direction with personality is the point of the skill.

## Workflow

Three phases, in order: **Interview → Commit to a direction → Generate the spec.** Don't skip the interview, and don't generate the full spec before the direction is settled.

### Phase 1 — Guided interview

First detect which starting mode the user is in, because it changes what you ask:

- **From scratch** — they have a product idea but no existing brand. → Run the full question set below.
- **Formalize** — they already have decisions in their head or scattered notes and want them turned into a real system. → Capture what they've decided, then ask only about the gaps.
- **Reverse-engineer** — they point at an existing site, screenshots, brand assets, or a live product. → Ask them to share the URL / images / files. Extract the palette, type, spacing, and voice from what they give you, present what you found, and ask what to keep versus improve. Then treat the kept pieces as fixed constraints.

If their opening message already answers some questions, don't re-ask — acknowledge what you have and ask only what's missing.

**Ask these grouped into one message** (a wall of one-at-a-time questions is exhausting; a single tidy block respects their time):

1. **Subject** — In one line, what is this product/brand and what does it do?
2. **Audience** — Who is it for? (Be concrete: "indie game devs", not "users".)
3. **The one job** — What is the single most important thing the design has to accomplish? (sell, get someone to sign up, make dense data legible, feel trustworthy, feel playful…)
4. **Personality** — 3–5 adjectives for how it should feel. Any products, sites, or brands they love — or actively dislike — and why?
5. **Constraints** — Anything fixed: existing logo, colors, or fonts to keep? Accessibility bar (e.g. WCAG AA)? Light, dark, or both? Web, mobile, or both?
6. **Scope** — Do they want a full design system, a single website's design, or both? Any specific components or screens they know they need?

Keep it tight. The interview should feel like a sharp creative brief, not a form.

### Phase 2 — Commit to an aesthetic direction

This phase is where the personality is won or lost. Do most of this thinking quietly, then surface a short proposal before writing the whole spec.

Ground every choice in the subject's own world — its materials, instruments, artifacts, vernacular. That is where non-generic choices come from. A spec for a beekeeping co-op and a spec for a crypto exchange should not be reskins of each other.

**Avoid the current AI-design defaults.** Right now AI-generated design clusters around three looks, and they show up regardless of subject:

1. warm cream background (~`#F4F1EA`) + high-contrast serif display + a terracotta accent;
2. near-black background + a single acid-green or vermilion accent;
3. broadsheet layout with hairline rules, zero border-radius, dense newspaper columns.

Each is fine _if the brief explicitly asks for it_ — the brief's own words always win. But where the brief leaves an axis free, don't spend that freedom landing on one of these. Work through what you'd produce for any similar prompt, and if your instinct matches the default, push somewhere truer to _this_ subject.

**Spend boldness in one place.** Choose a single **signature** — the one element the design will be remembered by (a type treatment, a structural device, a motion moment, a way of handling imagery) — and let everything around it stay quiet and disciplined. Maximalist directions need elaborate execution; minimal ones need precision. Elegance is executing the chosen vision well.

Then present a brief **direction statement** for a quick gut-check before you generate the full document:

- 2–4 sentences naming the aesthetic point of view and _why it fits this subject_;
- the palette as 4–6 named hex values;
- the type pairing (display + body, named, with the role each plays);
- the one signature element.

Invite a thumbs-up or a tweak. If the user says "just generate it", skip the gut-check and go straight to Phase 3.

### Phase 3 — Generate the spec

Read `references/spec-template.md` and produce the document following its structure exactly. Fill every section with **real, concrete, project-specific values** derived from the agreed direction — never placeholders like "Color 1" or "your-font-here". Run the principles checklist below before you hand it over.

When done, save it as a Markdown file and tell the user how to use it:

- **In Claude Design** — paste the document in (or attach the file) and ask it to build the system or a specific page.
- **In Claude Code** — drop the file in the repo; the token blocks become `:root` custom properties or `tokens.json`, and the rules guide component work.

Then offer to refine any section — this skill is meant to be re-run and iterated.

## Principles checklist

Before delivering, confirm:

- **Grounded in the subject** — the direction reads as made for _this_ brief, not transplantable to any other.
- **One clear signature**, with restraint everywhere else.
- **Not a default** — it isn't one of the three AI looks above (unless asked for).
- **Every value is concrete** — hexes for colors, real font stacks with fallbacks and a source (Google Fonts / system / where to obtain), numbers for every size, radius, and duration.
- **Accessibility floor** — body text and UI controls meet at least WCAG AA contrast; note the ratios for the main pairings. Include visible focus styling guidance.
- **Copy is treated as design material** — tone of voice and copy rules are specific to this brand with real example microcopy (button labels, an error, an empty state), not generic advice.
- **Complexity matches the vision** — a minimal direction is executed with precision; a maximal one is actually elaborated.

If a `frontend-design` skill is available in the environment, it complements this one with deeper taste guidance; consult it when you want more on a specific design decision. This skill is self-contained without it.
