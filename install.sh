#!/usr/bin/env bash
#
# install.sh — installs this repo's Claude Agent Skills locally.
#
# Usage:
#   ./install.sh                  # install all skills (personal, all projects)
#   ./install.sh security-by-design security-translator  # install only selected skills
#   ./install.sh --project        # install in the current project instead of globally
#   ./install.sh --force          # overwrite without asking for confirmation
#   ./install.sh --skill-path skill  # look for skills under <repo>/skill instead of the repo root
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$HOME/.claude/skills"
SKILL_PATH="$REPO_DIR"
FORCE=0
SELECTED=()

while [ "$#" -gt 0 ]; do
  arg="$1"
  case "$arg" in
    --project)
      TARGET_DIR="$(pwd)/.claude/skills"
      ;;
    --force)
      FORCE=1
      ;;
    --skill-path)
      if [ "$#" -lt 2 ]; then
        echo "--skill-path requires a value." >&2
        exit 1
      fi
      shift
      case "$1" in
        /*) SKILL_PATH="$1" ;;
        *)  SKILL_PATH="$REPO_DIR/$1" ;;
      esac
      ;;
    --skill-path=*)
      value="${arg#--skill-path=}"
      case "$value" in
        /*) SKILL_PATH="$value" ;;
        *)  SKILL_PATH="$REPO_DIR/$value" ;;
      esac
      ;;
    -h|--help)
      grep '^#' "$0" | sed 's/^# \{0,1\}//'
      exit 0
      ;;
    *)
      SELECTED+=("$arg")
      ;;
  esac
  shift
done

if [ ! -d "$SKILL_PATH" ]; then
  echo "Skill path not found: $SKILL_PATH" >&2
  exit 1
fi

mkdir -p "$TARGET_DIR"

# Find the skill folders under SKILL_PATH: any top-level directory that
# contains a SKILL.md, excluding "technical" folders of the repo itself.
# (while-read loop instead of mapfile: compatible with bash 3.2 too,
#  the version preinstalled on macOS)
ALL_SKILLS=()
while IFS= read -r skill_name; do
  ALL_SKILLS+=("$skill_name")
done < <(
  find "$SKILL_PATH" -maxdepth 2 -type f -name "SKILL.md" \
    | xargs -n1 dirname \
    | xargs -n1 basename \
    | sort
)

if [ "${#ALL_SKILLS[@]}" -eq 0 ]; then
  echo "No skills found in $SKILL_PATH (no folder with SKILL.md)." >&2
  exit 1
fi

if [ "${#SELECTED[@]}" -gt 0 ]; then
  SKILLS_TO_INSTALL=("${SELECTED[@]}")
else
  SKILLS_TO_INSTALL=("${ALL_SKILLS[@]}")
fi

echo "Destination: $TARGET_DIR"
echo ""

INSTALLED=0
SKIPPED=0

for skill in "${SKILLS_TO_INSTALL[@]}"; do
  SRC="$SKILL_PATH/$skill"

  if [ ! -f "$SRC/SKILL.md" ]; then
    echo "⚠️  '$skill' is not a valid skill (missing SKILL.md), skipping." >&2
    continue
  fi

  DEST="$TARGET_DIR/$skill"

  if [ -e "$DEST" ] && [ "$FORCE" -ne 1 ]; then
    read -r -p "'$skill' already exists in $TARGET_DIR. Overwrite? [y/N] " reply
    case "$reply" in
      [yY]*) ;;
      *)
        echo "  → skipped"
        SKIPPED=$((SKIPPED + 1))
        continue
        ;;
    esac
  fi

  rm -rf "$DEST"
  cp -r "$SRC" "$DEST"
  echo "✓ $skill installed"
  INSTALLED=$((INSTALLED + 1))
done

echo ""
echo "Done: $INSTALLED installed, $SKIPPED skipped."
echo "Verify in Claude Code with: /skills"