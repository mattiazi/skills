---
name: security-by-design
description: >
  Derive specific, testable security acceptance criteria from any architectural document —
  CLAUDE.md, ARCHITECTURE.md, ADR, README, API spec, or plaintext system description. Use
  this skill whenever the user wants to shift security left: "generate security criteria from
  my design", "what should I test for security given this architecture", "turn my CLAUDE.md
  into a security checklist", "turn my ARCHITECTURE.md into security tests", "security
  acceptance tests for my system", "NIS2/CIS controls for my design", "security requirements
  from architecture doc". Also triggers when the user pastes or uploads an architecture
  document and asks anything security-related. Do NOT use for generic security advice
  unrelated to a specific system description.
---

# Security by Design

This skill bridges architecture documentation and security testing. The core insight: you
cannot write meaningful security tests without knowing what the system actually does. Generic
checklists miss context-specific risks. This skill reads what was actually built and derives
criteria from those specific decisions.

The output is not a generic security checklist — it is a set of criteria derived from the
design choices present in the input document. If the document doesn't mention an auth
mechanism, no auth criteria are emitted. Everything is traceable to a design decision.

---

## Input

The user provides one or more of:
- A `CLAUDE.md` or `ARCHITECTURE.md` file (or any markdown architecture doc)
- An ADR (Architecture Decision Record)
- A plaintext or structured description of the system
- An API spec (OpenAPI, Postman, etc.)
- A partial document with only some components described

If no document is in the conversation, ask the user to paste or upload it before proceeding.
Do not attempt to generate criteria from memory or assumptions about their system.

---

## What to extract from the document

Read the document and identify the following signals. Each signal class maps to a category
of security criteria. Only emit criteria for signals that are actually present.

**Authentication & session management**
Signals: JWT, OAuth, session tokens, cookies, API keys, SAML, OIDC, MFA mentions
→ Criteria around token validation, expiry, rotation, claim verification, storage

**Authorization & access control**
Signals: RBAC, roles, permissions, admin vs user, multi-tenancy, shared-schema, resource ownership
→ Criteria around privilege escalation, horizontal access, tenant isolation, default-deny

**Data storage & secrets**
Signals: PostgreSQL, Redis, S3, env vars, config files, `.env`, Vault, database credentials
→ Criteria around encryption at rest, secret rotation, no hardcoded credentials, connection string safety

**Input handling & injection**
Signals: ORM (GORM, SQLAlchemy, Eloquent), raw SQL, file uploads, HTML rendering, user-controlled input
→ Criteria around parameterized queries, output encoding, upload validation, sanitization

**Network & transport**
Signals: HTTP/HTTPS, TLS config, internal APIs, WebSocket, gRPC, CORS, reverse proxy
→ Criteria around TLS enforcement, CORS policy, header security, internal trust boundaries

**Logging & observability**
Signals: logging libraries, error handlers, audit trails, telemetry, sentry/datadog
→ Criteria around PII in logs, token/secret exposure in logs, audit log integrity

**Dependencies & supply chain**
Signals: go.mod, package.json, composer.json, Docker base images, third-party SDKs
→ Criteria around dependency pinning, known CVE scanning, image provenance

**Compliance-specific signals**
Signals: NIS2, GDPR, healthcare, financial data, personal data categories, data residency
→ Map findings to NIS2 art.21 controls or GDPR obligations where relevant

---

## Output format

Always produce the output in this structure:

```
# Security Acceptance Criteria
*Derived from: [document name or "provided architecture description"]*
*Generated: [date if available]*

---

## [Category Name]
*Design signals detected: [brief list of what triggered this category]*

### [Criterion title]
- **What to verify**: [concrete, testable statement]
- **How to test**: [specific test method — unit test, config audit, grep pattern, manual check, tool]
- **Risk if missing**: [one sentence on what could go wrong]
- **Standard reference**: [CIS Control X.Y / NIS2 art.21(X) / OWASP ASVS X.X.X / GDPR art.XX — pick the most relevant]

[repeat for each criterion in the category]

---
```

Emit only categories for which signals were detected. If a category has no signals, omit it
entirely rather than showing it as empty.

The criterion title should be specific to the system, not generic. Prefer:
> "JWT HS256 secret not hardcoded in repository"

Over:
> "Secrets management"

---

## Tone and depth calibration

- If the document is detailed (full CLAUDE.md with architecture sections), emit 4-8 criteria
  per detected category.
- If the document is a sketch or brief, emit 2-4 criteria per category and note that a more
  detailed document would yield more specific criteria.
- If a design decision is ambiguous (e.g., "we use auth" with no specifics), emit the
  criterion but flag it: `*Note: auth mechanism not specified — revisit this criterion once
  implementation is confirmed.*`

---

## After the criteria

Append a short **Gap Signals** section:

```
## Gap Signals
The following areas were NOT covered in the provided document. If they apply to your system,
consider adding them to the architecture doc so future runs of this skill can generate
criteria for them:

- [area not mentioned, e.g., "Backup and recovery strategy"]
- [area not mentioned, e.g., "Rate limiting / DoS protection"]
```

This is the "silence skill" embedded in the output: it tells the user what wasn't described,
not just what was.

---

## Mapping table: design signals → standards

Use this when the user wants compliance framing (NIS2, CIS, GDPR):

| Signal | CIS Control | NIS2 art.21 | OWASP ASVS |
|---|---|---|---|
| Auth / Identity | CIS 5, 6 | art.21(2)(i) | V2 |
| Network controls | CIS 12, 13 | art.21(2)(h) | V9 |
| Patch / deps | CIS 7 | art.21(2)(e) | V14 |
| Logging | CIS 8 | art.21(2)(j) | V7 |
| Encryption | CIS 3 | art.21(2)(h) | V6, V8 |
| Access control | CIS 6 | art.21(2)(i) | V4 |
| Incident response | CIS 17 | art.21(2)(c) | — |
| Backup | CIS 11 | art.21(2)(c) | — |

If the user does not explicitly request compliance framing, still include standard references
but keep them brief (one reference per criterion is enough).

---

## Example

**Input excerpt:**
> We use JWT with HS256 for auth. Secret stored in `AUTH_SECRET` env var. Postgres via GORM.
> Users can upload profile images stored in S3.

**Output excerpt:**

```
## Authentication & Session Management
*Design signals detected: JWT, HS256, env var secret*

### JWT secret not exposed in source or logs
- **What to verify**: `AUTH_SECRET` is loaded exclusively from environment and never
  interpolated into log statements, error messages, or API responses.
- **How to test**: `grep -r "AUTH_SECRET" --include="*.go" | grep -v "os.Getenv"` should
  return no results. Check log output during auth failures for token content.
- **Risk if missing**: Secret exposure allows token forgery and full auth bypass.
- **Standard reference**: CIS 3.11 / OWASP ASVS 2.10.4

### JWT claims fully validated on every request
- **What to verify**: Middleware validates `exp`, `iss`, `aud`, and `sub` on every
  protected route, not just at login.
- **How to test**: Unit test: forge a token with future `exp` but wrong `iss` — request
  must return 401. Integration test: replay an expired token after 1s with short-lived
  test config.
- **Risk if missing**: Accepted tokens from other services or expired sessions.
- **Standard reference**: OWASP ASVS 3.5.2 / NIS2 art.21(2)(i)
```

---

## Edge cases

- **No document provided**: Ask for it. Do not generate generic criteria.
- **Very large document**: Read the full document but focus criteria on the security-relevant
  sections. It's fine to note "this document also covers [topic] which was out of scope for
  security criteria."
- **Multiple services described**: Emit criteria per service if they have distinct security
  surfaces, or group by category if they share the same stack.
- **User asks for a specific standard only** (e.g., "only NIS2"): Limit standard references
  to that standard and skip others.
- **User asks to add criteria to an existing list**: Merge without duplicating. Identify
  which new signals in the document aren't covered by the existing criteria.
