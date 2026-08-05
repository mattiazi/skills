---
name: security-translator
description: >
  Translate technical security findings — CVEs, CVSS scores, pentest results, incident
  logs, vulnerability reports — into clear, accurate, decision-ready language for
  non-technical stakeholders: board members, CDA, CEO, CFO, legal counsel, or top
  management. Use this skill whenever the user needs to: "explain this CVE to my board",
  "translate this pentest report for management", "write an executive summary of this
  incident", "explain this CVSS score in business terms", "turn this security finding into
  a budget ask", "brief the CEO on this vulnerability", "make this finding understandable
  for legal". Also triggers when the user has a technical security document and an
  upcoming management meeting, investor call, or board presentation. Do NOT use for
  technical-to-technical translation or peer security reviews.
---

# Security Translator

The gap between a CVSS 9.8 and a board decision to fund remediation is not technical —
it's communicative. Security professionals know what a critical RCE means. Boards know
what revenue loss, regulatory fines, and reputational damage mean. This skill bridges
the two.

The translation must be accurate without being condescending, and urgent without being
alarmist. Boards that are constantly told everything is critical stop hearing it.
The goal is to give decision-makers exactly what they need to act — no more, no less.

---

## Input

The user provides one or more of:

- CVE identifiers (CVE-2024-XXXXX)
- CVSS scores and vectors
- Pentest report excerpts or full reports
- Incident response summaries or raw logs
- Vulnerability scan results
- Security assessment findings

If no material is provided, ask for it. Do not translate from memory or generate
fictional findings.

---

## Translation principles

**Accuracy first.** Never downplay a critical finding to avoid alarm, and never inflate
a low finding to justify budget. The translation must preserve the true severity.

**No jargon in the output.** If you find yourself writing "RCE", "SSRF", "lateral
movement", or "privilege escalation" in the executive output, replace them with plain
language. The technical terms belong only in the appendix.

**Business framing, not technical framing.** The question the board is asking is not
"what is the vulnerability?" — it's "what could happen to us, what does it cost to fix,
and what is the risk of not fixing it?"

**Proportionality.** A CVSS 4.0 finding does not warrant the same urgency as a CVSS 9.8
with active exploitation. Calibrate tone to actual severity.

**Decision enablement.** Every executive summary must end with a clear ask: approve
budget, approve timeline, acknowledge risk, authorize remediation. No ask = no action.

---

## Severity mapping

Translate technical severity ratings to business language:

| Technical | CVSS Range | Business framing                                  |
| --------- | ---------- | ------------------------------------------------- |
| Critical  | 9.0–10.0   | Immediate business risk — action required now     |
| High      | 7.0–8.9    | Significant risk — action required within 30 days |
| Medium    | 4.0–6.9    | Manageable risk — plan remediation within 90 days |
| Low       | 0.1–3.9    | Accepted risk — monitor, no immediate action      |

If a finding is actively exploited in the wild (CISA KEV, threat intel), escalate one
level in business urgency regardless of CVSS score.

---

## Output format

Produce two sections: **Executive Brief** (for the board/management) and **Technical
Appendix** (optional, for reference).

```
# Security Briefing: [Topic]
*Prepared for: [audience — e.g., "Board of Directors", "CEO and CFO"]*
*Date: [date]*
*Prepared by: [if known]*

---

## Executive Brief

### What happened / what was found
[2-4 sentences in plain language. What is the vulnerability or incident, in terms of
what an attacker could do — not how the vulnerability works technically.]

### What is at risk
[Concrete business consequences. Use these categories where relevant:]
- **Data at risk**: [what data, whose data, how many records]
- **Operational impact**: [could the service go down? for how long? what would stop working?]
- **Regulatory exposure**: [GDPR fines, NIS2 obligations, industry-specific obligations]
- **Financial exposure**: [estimated range if quantifiable — breach costs, downtime cost,
  fine ranges]
- **Reputational exposure**: [customer trust, press risk, partner relationships]

### Current status
[Is this already happening? Is it a risk not yet exploited? Has it been contained?
One sentence: "This vulnerability has not been exploited — we discovered it proactively"
or "This incident occurred on [date] and was contained by [date]."]

### What we are asking for
[The explicit ask. Be direct.]
- **Option A — Remediate now**: [cost, timeline, what it achieves]
- **Option B — Accept risk**: [what we are accepting, under what conditions, for how long]
- **Recommended course**: [your recommendation and why]

---

## Risk Register Entry *(optional — include if the user wants a one-liner for a register)*

| Finding | Severity | Likelihood | Impact | Status | Owner | Due |
|---|---|---|---|---|---|---|
| [finding name] | Critical/High/Medium/Low | High/Med/Low | [business impact] | Open/In Progress/Accepted | [team] | [date] |

---

## Technical Appendix *(for security team reference — not for board)*

### Technical details
[Original technical description, CVE IDs, CVSS scores, affected components]

### Remediation steps
[Technical remediation — patching, config change, code fix]

### Detection indicators
[Log signatures, IOCs, detection rules if an incident]
```

---

## Audience calibration

Adjust the Executive Brief based on who will read it:

**Board / CDA** — Focus on regulatory exposure, financial risk, and strategic implications.
Minimize operational detail. The ask must be binary: approve or reject.

**CEO / General Management** — Balance operational and financial. Include timeline impact.
Keep it to one page.

**CFO** — Lead with financial exposure (fine ranges, breach cost estimates, remediation
cost). Include ROI framing: "remediating now costs X, the potential fine is Y."

**Legal counsel** — Emphasize regulatory obligations (GDPR art.32, NIS2 art.21), breach
notification timelines, and liability implications. Include the standard reference.

**Investor / M&A context** — Frame around due diligence risk. Is this a known issue with
a remediation plan (acceptable) or an undisclosed risk (problematic)?

If the user specifies the audience, calibrate accordingly. If unspecified, default to
"board / general management" framing.

---

## Financial exposure estimation

When the user wants a financial framing and doesn't have numbers:

**GDPR fine range**: up to 4% of global annual turnover or €20M (whichever is higher)
for serious violations. For Italian SMEs, provide a realistic range based on typical
enforcement — not the maximum theoretical fine.

**NIS2 penalties**: up to €10M or 2% of global turnover for essential entities.

**Breach cost estimation**: use industry benchmarks — IBM Cost of a Data Breach Report
provides per-record and per-incident ranges. Note that these are estimates, not
guarantees, and flag this clearly.

**Downtime cost**: if the user can provide revenue figures, calculate: hourly revenue ×
estimated downtime hours. If not, use "significant operational disruption" rather than
fabricating a number.

Never invent specific figures. Provide ranges and cite their source.

---

## Common translation patterns

**CVE with critical CVSS → executive language**:

Technical: "CVE-2024-12345, CVSS 9.8, unauthenticated remote code execution in web
application framework, publicly available exploit."

Executive: "A critical weakness was discovered in software our web application depends
on. An attacker on the internet — with no account or credentials — could take full
control of our server, access all data stored on it, and potentially spread to connected
systems. A ready-made tool to exploit this is publicly available, meaning even unskilled
attackers could use it. We have to apply a vendor-provided fix before this
becomes an active threat to us."

---

**Pentest finding → board language**:

Technical: "Insufficient authorization controls allow horizontal privilege escalation.
Authenticated users can access other users' records by modifying the `user_id` parameter
in API requests."

Executive: "During a security test, we found that a logged-in customer could access
another customer's account and data by making a minor change to how they interact with
our system. This means any of our customers could view — and potentially modify — another
customer's information. No evidence this has occurred in production, but the risk is real
and affects every customer account."

---

## Edge cases

- **Incident already public**: Acknowledge this in the brief and focus on what is known,
  what is contained, and what the communication plan is.
- **Finding from a third-party vendor**: Note that the risk depends on the vendor's
  remediation timeline, which is outside direct control. Recommend contractual escalation.
- **Multiple findings in one report**: Group by business impact area (data risk, operational
  risk, compliance risk) rather than by technical category. Boards understand business
  domains, not vulnerability classes.
- **User wants to downplay a critical finding**: Decline. Offer to frame it accurately but
  constructively — "here's the risk and here's what we're doing about it" is better than
  hiding severity.
- **No CVSS score available**: Ask for the technical description and derive the business
  severity yourself based on impact analysis.
