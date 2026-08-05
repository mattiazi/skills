# skills

A collection of [Claude Agent Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills) — security-focused workflows plus a few general-purpose productivity tools.

## Skills

| Skill | What it does |
|---|---|
| [`repo-threat-model`](repo-threat-model/SKILL.md) | Generates a STRIDE threat model directly from a GitHub repository or codebase — no interviews, no workshops. |
| [`security-by-design`](security-by-design/SKILL.md) | Derives specific, testable security acceptance criteria from an architecture document (CLAUDE.md, ADR, API spec…). |
| [`threat-actor-sim`](threat-actor-sim/SKILL.md) | Simulates a specific threat actor (ransomware gang, APT, insider…) attacking your system, from the adversary's perspective. |
| [`security-translator`](security-translator/SKILL.md) | Translates technical security findings (CVE, CVSS, pentest reports) into decision-ready language for boards and management. |
| [`design-system-builder`](design-system-builder/SKILL.md) | Builds a complete, portable design-system spec — colors, type, tokens, components, voice — usable as a prompt or lifted into a repo. |
| [`project-save-state`](project-save-state/SKILL.md) | Captures the full state of a project into a compact snapshot that restores context in any future Claude conversation. |

The security skills complement each other: `security-by-design` works from design documents, `repo-threat-model` from actual code, `threat-actor-sim` adds the attacker's strategic view on top of either.

## Installation

```bash
git clone https://github.com/mattiazi/skills.git
cd skills
./install.sh
```

Options:

```bash
./install.sh repo-threat-model security-translator  # install only selected skills
./install.sh --project                              # install into ./.claude/skills of the current project
./install.sh --force                                # overwrite existing skills without asking
```

By default skills are installed to `~/.claude/skills` (available in every project). Verify with `/skills` in Claude Code.

## License

[Apache 2.0](LICENSE)
