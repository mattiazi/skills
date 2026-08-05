# CLAUDE.md

Repository of Claude Agent Skills. Each top-level directory containing a `SKILL.md` is one skill; `install.sh` copies skills into `~/.claude/skills` (or `./.claude/skills` with `--project`).

## Rules

- **Always keep `README.md` in sync**: whenever a skill is added, removed, or its purpose changes, update the skill table in `README.md` in the same change.
- Each skill lives in its own directory named after the skill, with a `SKILL.md` whose frontmatter has `name` (matching the directory) and `description`.
- Supporting files (templates, references) live inside the skill's directory and are referenced with paths relative to it.
- Skills may mention each other, but only conditionally ("if the X skill is available…") — installs can be partial, never assume another skill is present.
- `install.sh` must stay compatible with bash 3.2 (macOS default): no `mapfile`, no bash-4-only features. Check syntax with `bash -n install.sh`.
