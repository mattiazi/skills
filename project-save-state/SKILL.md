---
name: project-save-state
description: >
  Capture, compress, and reload the complete epistemic state of a project — architecture
  decisions, open questions, technical debt, client context, next actions — into a dense,
  portable snapshot that can be pasted at the start of any Claude conversation to instantly
  restore full context. Use this skill whenever the user wants to: "save the state of this
  project", "create a context snapshot", "make a save point for this conversation",
  "reload where we left off", "catch Claude up on my project", "generate a project brief
  for future chats", "compress this conversation into a reusable context". Also triggers
  when the user says "I always have to re-explain everything" or asks how to persist context
  across conversations. Operates in two modes: CAPTURE (generate a snapshot from the current
  conversation or provided material) and LOAD (activate a snapshot and confirm readiness).
---

# Project Save State

Claude has no memory between conversations. Every new chat starts from zero. This skill
solves the re-explanation problem: it captures the living state of a project into a compact,
structured snapshot that can be pasted at the top of any future conversation to instantly
restore shared context.

This is not a README. A README describes what the project is. A save state captures what
_you_ know right now: the decisions made and why, the things still open, the assumptions
that are fragile, the context that would take 20 minutes to reconstruct from scratch.

---

## Two modes

### Mode: CAPTURE

Triggered when the user wants to create or update a save state.

**Trigger phrases**: "save state", "create a snapshot", "compress this into a context block",
"make a save point", "generate a project brief for future chats".

**Input sources** (use whatever is available, in order of priority):

1. The current conversation — extract decisions, context, and open items from the exchange
2. Provided files: CLAUDE.md, architecture docs, previous save states to update
3. User description: ask if nothing else is available

**What to capture**:

```
DECISIONS[] — Architectural and technical choices that are settled. For each:
  - What was decided
  - Why (the reasoning, not just the outcome)
  - What was rejected and why
  - Confidence: HIGH (committed) / MEDIUM (revisable) / LOW (provisional)

OPEN_QUESTIONS[] — Things that are unresolved, deferred, or actively uncertain.
  Format: question + why it's blocked or open + what would unblock it

CONSTRAINTS[] — Hard limits that must not be violated. Tech stack locks, compliance
  requirements, client mandates, budget ceilings, deadlines.

CONTEXT_FOR_CLAUDE[] — Implicit knowledge that Claude would need to avoid wasting time.
  Examples: "we tried Redis and abandoned it because of X", "the client insists on Y even
  though it's suboptimal", "this is a multi-tenant system, never mix tenant data"

NEXT_ACTIONS[] — The concrete next steps as of this snapshot.
  Format: action + owner (if known) + blocking condition (if blocked)

DEBT[] — Known technical debt or deferred decisions that are accepted but tracked.

CLIENT_CONTEXT[] — (for consulting/client work) Who the client is, their constraints,
  their sensitivities, what has already been agreed vs. proposed.
```

**Output format — the save state block**:

Produce a save state as a fenced code block labeled `project-save-state`. It must be:

- **Dense**: target ≤ 2KB of text. Every word earns its place. Cut prose, keep facts.
- **Machine-readable and human-readable**: structured with clear section headers
- **Self-contained**: someone with no prior context can read it and understand the project
- **Dated**: include a `snapshot_date` so stale states are identifiable

````
```project-save-state
project: [Project Name]
snapshot_date: [YYYY-MM-DD]
owner: [user name or team]

## system
[2-4 sentence description of what the system is and does. Pure facts, no fluff.]

## stack
[Comma-separated list of core tech: Go 1.23, PostgreSQL 16, Vue 3, Docker, etc.]

## decisions
- [Decision]: [What was decided]. Rejected: [what wasn't chosen]. Reason: [why]. Confidence: HIGH|MEDIUM|LOW
- [repeat]

## open_questions
- [Question]? Blocked by: [reason]. Unblocks when: [condition]
- [repeat]

## constraints
- [Hard constraint — one line each]

## next_actions
- [ ] [Action] — [owner if known] — [blocking condition if blocked]
- [repeat]

## debt
- [Deferred item]: [why accepted, when to revisit]

## context_for_claude
- [Implicit knowledge Claude needs. E.g.: "We use shared-schema multi-tenancy, never
  suggest row-level security — it was evaluated and rejected (see decisions)."]

## client_context  [omit section if not a client project]
- [Client name / type], [key constraint], [agreed vs proposed], [sensitivities]
\```
````

After producing the save state block, add a short note:

> _Save state generated. Paste this block at the start of any Claude conversation.
> Claude will read it and confirm it's loaded before proceeding._

---

### Mode: LOAD

Triggered when the user pastes a save state block into a conversation (the block starts
with ` ```project-save-state `).

**Behavior on load**:

1. Read the entire block
2. Confirm loading with a brief summary: project name, snapshot date, top 2-3 decisions,
   number of open questions, next actions
3. Flag any potential staleness: if `snapshot_date` is more than 30 days ago, note it
4. Ask: "Anything changed since this snapshot that I should know about before we proceed?"
5. Then wait for the user's actual task — do not start generating output unsolicited

**Confirmation format**:

```
📦 Save state loaded — [Project Name] (snapshot: [date])

Decisions in effect:
- [decision 1 summary]
- [decision 2 summary]

Open: [N] questions | Next: [first action] | Debt: [N items]

[Flag if stale]: ⚠️ This snapshot is [X] days old — some context may have changed.

Ready. What are we working on?
```

---

## Update mode

When the user says "update the save state" or "refresh the snapshot" after a conversation
where decisions were made or questions resolved:

1. Read the existing save state (from the conversation)
2. Apply changes: move resolved open questions to decisions, add new decisions, update
   next actions, add new debt items
3. Produce an updated save state block with a new `snapshot_date`
4. Briefly note what changed: "Updated: resolved JWT decision, added 2 new open questions,
   removed 3 completed actions."

---

## Size discipline

The ≤2KB target is a forcing function. If the save state grows beyond this:

- Collapse low-confidence decisions into a single "provisional decisions" line
- Archive completed items rather than keeping them
- Move detailed rationale to a separate linked document and reference it by name
- Prefer bullet points over prose everywhere

The save state is not a knowledge base. It is a minimum viable context transfer. If it
takes more than 30 seconds to read, it's too long.

---

## Edge cases

- **No project material available**: Ask the user to describe the project in 5-10 sentences,
  then generate the save state from that description. Flag all items as LOW confidence.
- **Very early-stage project**: Fewer decisions, more open questions. That's fine — the
  save state is still valuable for capturing constraints and intent.
- **Multiple projects**: Generate one save state per project. Do not merge them.
- **Team project**: Include an `owner` field per decision if authorship matters.
- **Confidential client work**: Remind the user to redact client names or PII before
  sharing the save state in contexts where confidentiality applies.
