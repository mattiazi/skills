---
name: threat-actor-sim
description: >
  Simulate a specific threat actor attacking your architecture, codebase, or system from
  the adversary's perspective — with realistic TTPs, motivation, and target selection
  logic. Use this skill when the user wants adversarial red team thinking: "attack my
  architecture as a ransomware gang", "how would APT29 approach my system", "play the
  attacker against my design", "red team my setup", "think like an attacker looking at
  my stack", "what would a nation-state do with this access", "simulate a threat actor
  against my CLAUDE.md", "boss fight my architecture". Also triggers when the user asks
  "what's the worst case" or "what am I not seeing" about their security posture.
  Do NOT use for generating actual exploit code, malware, or attack tooling — this skill
  produces adversarial *reasoning*, not operational attack capability.
---

# Threat Actor Simulator

Generic threat modeling asks "what could go wrong?" This skill asks a sharper question:
"what would *this specific attacker* do, in what order, and why?"

Threat actors have different goals, resources, patience, and methods. A ransomware gang
behaves very differently from a nation-state APT or an opportunistic script kiddie. By
simulating a specific actor, you surface threats that generic STRIDE analysis misses —
particularly around attack sequencing, dwell time, and the attacker's economic logic.

This is adversarial red team thinking, not penetration testing. The output is strategic
reasoning about how an attacker would approach your system, not operational attack code.

---

## Threat actor profiles

Choose one based on the user's context or threat model. If the user doesn't specify,
recommend the most realistic one given their system description.

---

### RANSOMWARE GANG (e.g., LockBit-style, RaaS operator)
**Motivation**: Financial. Encrypt data, demand ransom. Secondary: exfiltrate data for
double-extortion.
**Resources**: Moderate. Skilled but not nation-state. Buys initial access from IABs.
**Patience**: Low-medium. Weeks, not months.
**Targets**: Backup systems, domain controllers, file servers, databases. Avoids ICS
(not their expertise). Prefers Windows environments but adapts.
**Typical TTP sequence**:
1. Initial access via phishing, exposed RDP, or purchased credentials
2. Establish persistence (scheduled task, service, registry)
3. Lateral movement (pass-the-hash, Kerberoasting, credential dumping)
4. Locate and disable backups first — this is the priority
5. Exfiltrate data before encryption (double-extortion)
6. Deploy ransomware across as many systems as possible simultaneously

**What they care about most**: Can they get to backups before you notice? Can they
encrypt enough to make recovery painful? How quickly can they exfiltrate data?

---

### NATION-STATE APT (e.g., Russian SVR, Chinese MSS affiliate)
**Motivation**: Intelligence collection, long-term access, potential disruption capability.
Rarely financial.
**Resources**: High. Zero-days, custom tooling, large teams, patience.
**Patience**: Very high. Months to years.
**Targets**: Credentials, internal communications, intellectual property, supply chain
positioning, infrastructure access for future use.
**Typical TTP sequence**:
1. Extensive OSINT and target profiling before first contact
2. Spearphishing targeting specific individuals with tailored lures
3. Establish foothold with custom, low-signature malware
4. Patient credential harvesting — avoid triggering alerts
5. Map internal network slowly over weeks
6. Identify crown jewels — exfiltrate quietly, never noisily
7. Maintain persistent access for months or years before (maybe) being discovered

**What they care about most**: Stealth over speed. Not triggering EDR or SIEM alerts.
Finding the right human to compromise, not just the right vulnerability.

---

### OPPORTUNISTIC ATTACKER / SCRIPT KIDDIE
**Motivation**: Opportunistic. Looking for easy wins — crypto miners, spam bots, data to
sell, bragging rights.
**Resources**: Low. Uses public exploits, commodity tools (Metasploit, Shodan).
**Patience**: Very low. If it takes more than an hour, they move on.
**Targets**: Anything internet-exposed with a known CVE. Misconfigured cloud storage,
default credentials, unpatched public-facing services.
**Typical TTP sequence**:
1. Mass scanning for known vulnerable services (Shodan, Censys, nuclei)
2. Automated exploitation of first viable target
3. Deploy commodity payload (crypto miner, web shell, botnet agent)
4. Move on — rarely does manual post-exploitation

**What they care about most**: Is this target easier than the next one? Default credentials
anywhere? Anything exposed that shouldn't be?

---

### MALICIOUS INSIDER
**Motivation**: Financial (selling data), revenge, ideology, or coercion.
**Resources**: High — legitimate access, knowledge of internal systems, trusted identity.
**Patience**: Variable. Typically acts quickly once motivated.
**Targets**: Whatever they have access to. Customer data, IP, financial records.
**Typical behavior**:
1. Leverages existing access — no exploitation needed
2. Exfiltrates via legitimate channels (email, USB, cloud sync)
3. May attempt to cover tracks by deleting logs

**What they care about most**: Not getting caught. Can they exfiltrate without triggering DLP?
Do they have broader access than their role requires?

---

### SUPPLY CHAIN ATTACKER
**Motivation**: Access to the target's customers through the target. Long-game.
**Resources**: Medium to high. Compromises a vendor or open-source package to reach downstream.
**Patience**: High.
**Targets**: Build pipelines, package registries, update mechanisms, SaaS integrations.
**Typical TTP sequence**:
1. Compromise a dependency (typosquatting, maintainer account takeover, direct PR injection)
2. Wait for downstream target to pull the malicious update
3. Execute payload in the target's environment with the dependency's trust level

**What they care about most**: Does the target pin dependencies? Is the build pipeline
internet-facing? Does the target auto-update?

---

## Simulation workflow

### Step 1 — Establish the attacker

When the user requests a simulation:
1. Confirm the threat actor (or recommend one if not specified)
2. Briefly state the actor's motivation, resources, and patience in 2-3 sentences
3. Note any misalignments: "This actor typically targets Windows environments — your stack
   is primarily Linux, which reduces their native toolset but doesn't eliminate the threat."

### Step 2 — Reconnaissance phase (attacker's view)

Before attacking, the actor observes. Describe what the attacker learns from:
- Public OSINT (LinkedIn, GitHub, job postings, DNS, certificate transparency)
- The system description or CLAUDE.md provided
- Shodan / internet exposure

Output as an **Attacker Recon Summary**: what they know before making first contact.

### Step 3 — Attack narrative

Walk through the attack from the actor's perspective, first-person or third-person, in
sequential steps. For each step:

```
### Phase [N]: [Phase Name]
*Attacker goal: [what they're trying to achieve in this phase]*

[What the attacker does, and why. Reference specific components from the system
description where possible. Flag where existing controls would resist them — and
whether those controls are sufficient.]

**Bottleneck**: [What slows or stops this attacker at this phase]
**Bypass**: [What they would try to get around the bottleneck]
**Detection window**: [When a defender could notice this, if at all]
```

### Step 4 — Crown jewel reach assessment

After the narrative: which assets did the attacker reach? What's the worst-case outcome
for this specific actor against this specific system?

### Step 5 — Defender's leverage points

For each phase in the attack narrative, identify the one control that would have the
highest impact on disrupting the attacker:

```
## Where you have leverage

| Phase | Highest-impact control | Why it matters for this actor |
|---|---|---|
| Initial access | [control] | [reason] |
| Lateral movement | [control] | [reason] |
| Exfiltration | [control] | [reason] |
```

---

## Output format

```
# Threat Actor Simulation: [Actor Type] vs. [System Name]
*Based on: [input material]*

---

## Actor Profile
[3-4 sentences: motivation, resources, patience, typical targets]

## Attacker Recon
*What they know before making first contact:*
[Recon summary from public information and provided system description]

---

## Attack Narrative

### Phase 1: [Name]
[...]

### Phase 2: [Name]
[...]

[continue until crown jewel reach or attacker failure]

---

## Outcome Assessment
**Assets reached**: [list]
**Worst-case scenario**: [one paragraph]
**Time to reach crown jewels**: [estimate — hours / days / weeks]
**Detection likelihood with current controls**: Low / Medium / High

---

## Leverage Points

| Phase | Highest-impact control | Actor-specific reason |
|---|---|---|
[table]

---

## What this actor does NOT care about
[List controls that would not slow this specific actor — important for prioritization]
```

---

## Tone and scope

- Write the attack narrative with specificity. Generic attack paths ("the attacker gains
  access and moves laterally") are less useful than actor-specific reasoning ("a RaaS
  operator at this point would check for Veeam backup services — if found, this is their
  first target before anything else").
- Do NOT produce actual exploit code, shellcode, or working attack tooling. The output is
  adversarial reasoning — the *why* and *what*, not the *how* at implementation level.
- Be honest about control effectiveness. If an existing control is weak or bypassable by
  this actor, say so. The value is in the accurate adversarial view, not reassurance.
- If the system description is too sparse to simulate meaningfully, ask for more detail
  before proceeding. A simulation built on assumptions is less useful than one built on
  the actual system.

---

## Edge cases

- **User specifies an unrealistic actor** (e.g., "simulate APT29 against my personal blog"):
  Gently note the mismatch and recommend the more likely threat actor. Offer to run both
  if they want the contrast.
- **User provides no system description**: Ask for at minimum: what the system does,
  what data it holds, how it's exposed (internet-facing or internal), and what auth
  mechanism is in place. Don't simulate against nothing.
- **User asks for a specific attack type** (e.g., "phishing attack on my company"): Treat
  the attack type as the starting phase and use the most realistic actor for that vector.
- **Combined with repo-threat-model**: This skill provides the attacker's strategic view;
  `repo-threat-model` provides the code-level threat inventory. Together they give both
  the "why would they" and the "where exactly can they."
- **Highly sensitive system** (healthcare, critical infrastructure, defense): Note that
  real nation-state simulation for these environments may require a cleared red team with
  classified threat intelligence — this skill provides a best-effort approximation based
  on public TTPs.
