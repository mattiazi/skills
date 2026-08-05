---
name: repo-threat-model
description: >
  Generate a STRIDE threat model directly from a GitHub repository or codebase — without
  interviews, without workshops, without a whiteboard. Use this skill when the user wants to
  threat model a real codebase: "threat model this repo", "run STRIDE on my project",
  "what are the threats in this codebase", "security review my GitHub repo",
  "threat model before the release", "STRIDE analysis of my service". Also triggers when
  the user shares a repo URL or pastes code and asks about attack surface, threats, or
  adversarial thinking. Prefer this skill over generic security advice when a concrete
  codebase or repository is available. Do NOT use for abstract system descriptions with no
  code — use the security-by-design skill for document-only inputs.
---

# Repo Threat Model

Traditional threat modeling requires assembling the team, running a workshop, drawing
data flow diagrams on a whiteboard, and then someone writing it all up. The reality: it
takes half a day and often doesn't reflect what's actually in the code.

This skill skips the process and reads the code directly. What the system does is in the
repository — the trust boundaries, the entry points, the data flows, the auth decisions.
The threat model is derivable from what was built, not from what someone remembers in a
meeting room.

The output is a STRIDE threat model grounded in the actual codebase, not a generic threat
matrix for a system that kind of sounds like this one.

---

## Input modes

**Mode A — GitHub URL**
The user provides a GitHub repository URL. Fetch the repository structure using web search
or available tools to understand the codebase layout before proceeding.

What to prioritize reading (in order):

1. `README.md`, `CLAUDE.md`, `ARCHITECTURE.md`, `docs/` — understand the system's intent
2. Entry points: `main.go`, `cmd/`, `app.py`, `index.js`, `routes/`, `controllers/`
3. Auth layer: middleware, JWT/session handling, auth providers
4. Database layer: migrations, models, ORM usage, raw queries
5. External integrations: HTTP clients, SDKs, webhook handlers
6. Config loading: `.env` handling, secrets injection, config structs
7. `Dockerfile`, `docker-compose.yml`, `k8s/` — deployment surface
8. `go.mod`, `package.json`, `composer.json` — dependency surface

Do not attempt to read every file. Focus on files where security decisions live.

**Mode B — Pasted code or file upload**
The user pastes code directly or uploads files. Read what's provided and note explicitly
what's missing (e.g., "the auth layer is not included — threats in that area will be
flagged as assumptions").

**Mode C — Mixed**
Repo URL + additional context (CLAUDE.md, architecture description). Combine both.

---

## STRIDE reference

Apply STRIDE per component, not per the whole system at once:

| Threat                     | Question to ask                                                   |
| -------------------------- | ----------------------------------------------------------------- |
| **S**poofing               | Can an attacker impersonate a user, service, or system component? |
| **T**ampering              | Can data be modified in transit, at rest, or in processing?       |
| **R**epudiation            | Can an actor deny an action they took? Is there an audit trail?   |
| **I**nformation Disclosure | Can sensitive data leak to unauthorized parties?                  |
| **D**enial of Service      | Can an attacker exhaust resources or make the system unavailable? |
| **E**levation of Privilege | Can an actor gain more permissions than intended?                 |

---

## Analysis workflow

### Step 1 — Map the system

Before producing any threats, build a concise mental model of the system from the code.
Output this as a brief **System Overview** section (5-10 lines max):

- What the system does
- Main components (services, workers, databases, external integrations)
- Trust boundaries identified (e.g., public internet → API gateway → internal services)
- Entry points (HTTP endpoints, queues, webhooks, CLI commands, cron jobs)
- Data sensitivity classification (PII, financial, healthcare, public)

This anchors the threats to the actual system rather than a generic category.

### Step 2 — Identify components and trust boundaries

From the code, enumerate:

- External actors (browsers, mobile clients, third-party services, other internal services)
- Internal components (API server, workers, databases, caches, file storage)
- Trust boundaries (where authentication/authorization decisions are made)
- Data flows across those boundaries

### Step 3 — Apply STRIDE per component

For each component and trust boundary, enumerate threats using STRIDE. Be specific: name
the file, function, or mechanism where the threat applies if you can identify it from the
code. Vague threats ("SQL injection is possible") without a code reference are less useful
than specific ones ("raw query interpolation in `pkg/db/users.go:fetchByFilter`").

### Step 4 — Assess likelihood and impact

For each threat, assign a simple rating:

- **Likelihood**: Low / Medium / High — based on exposure (internet-facing vs internal),
  complexity of exploit, and presence of existing controls
- **Impact**: Low / Medium / High / Critical — based on data sensitivity and blast radius
- **Priority**: derived from the combination (High likelihood + Critical impact = P0)

Do not over-engineer the scoring. The goal is actionable prioritization, not a risk matrix.

---

## Output format

```
# Threat Model: [Repository or System Name]
*Analysis date: [date if available]*
*Codebase scope: [what was read / what was not available]*

---

## System Overview
[5-10 line description of what was found in the code]

**Entry points**: [list]
**Trust boundaries**: [list]
**Data sensitivity**: [classification]

---

## Threat Inventory

### Component: [Component Name]
*e.g., "HTTP API — public internet facing"*

---

#### [STRIDE Category]: [Threat Title]
- **Description**: What an attacker could do and how
- **Code reference**: `path/to/file.go:functionName` or "not pinpointable from available code"
- **Existing control**: What's already in place (if anything visible in the code)
- **Likelihood**: Low / Medium / High
- **Impact**: Low / Medium / High / Critical
- **Priority**: P0 / P1 / P2 / P3
- **Recommended mitigation**: Specific, actionable countermeasure

---

[repeat for each threat]

---

## Prioritized Remediation Backlog

| Priority | Threat | Component | Effort |
|---|---|---|---|
| P0 | [threat title] | [component] | Low/Medium/High |
| P1 | ... | ... | ... |

---

## Assumptions and Blind Spots

List here:
- Components not present in the analyzed code (e.g., "auth service not in this repo")
- Threats that were assumed rather than code-confirmed
- Areas where a code read was insufficient and manual review is recommended

---
```

---

## Calibration by system size

- **Small repo / single service** (< 20 files of substance): go deep, reference specific
  files and functions where possible. Expect 15-25 threats total.
- **Medium repo** (20-100 files): focus on the critical path — auth, data layer, external
  integrations. Cover all STRIDE categories but don't enumerate every endpoint. 10-20
  threats.
- **Large monorepo or microservices**: scope to one service or the API gateway layer unless
  told otherwise. State the scoping decision explicitly.

---

## Threat actor profiles

When generating threats, briefly consider which actor is most realistic for each threat.
Annotate with the actor type where it helps prioritization:

- **External unauthenticated** — internet attacker with no account
- **External authenticated** — legitimate user abusing the system
- **Insider** — employee, contractor, or compromised internal service
- **Supply chain** — compromised dependency or third-party integration

This prevents the threat model from being purely theoretical. A threat from an
unauthenticated external actor is higher priority than the same threat requiring insider
access.

---

## Integration with security-by-design

If the user also has a `CLAUDE.md` or architecture document, run both skills and combine:

- This skill (`repo-threat-model`) identifies threats from the code
- `security-by-design` derives acceptance criteria from the design doc
- Together they cover both the "what could go wrong" and "how do we verify it's addressed"

Suggest this combination if the user has both a repo and a design document.

---

## Edge cases

- **Private repo with no URL access**: Ask the user to paste the relevant files or describe
  the architecture. Switch to Mode B.
- **No auth code visible**: Flag as a high-priority blind spot. Do not assume auth is
  handled correctly just because it's not in scope.
- **Already has a threat model**: Ask if they want to update it (diff mode) or produce a
  fresh one. In diff mode, focus on components that have changed since the last analysis.
- **User specifies a release date**: Note it in the output and prioritize P0/P1 threats
  that must be addressed before release. Mark P2/P3 as post-release backlog.
- **User asks for a specific threat category only** (e.g., "just elevation of privilege"):
  Run the full system overview, then filter the threat inventory to that category. Don't
  skip the overview — the context is needed to make threats specific.
