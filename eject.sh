#!/usr/bin/env bash
set -euo pipefail

# One-command uninstall: exact reverse of ./inject.sh.
#
# - Removes only symlinks in ~/.claude/skills/ that point into this repo.
# - Removes only the managed block from ~/.claude/CLAUDE.md.
#
# Real skill directories, foreign symlinks, and the rest of CLAUDE.md are
# never touched. Override the target with CLAUDE_DIR=/path (used by tests).

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_DIR/skills"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
BEGIN_MARK="<!-- BEGIN agentic-playbook (managed) -->"
END_MARK="<!-- END agentic-playbook (managed) -->"

removed=0
if [ -d "$SKILLS_DIR" ]; then
  for dest in "$SKILLS_DIR"/*; do
    [ -L "$dest" ] || continue
    case "$(readlink "$dest")" in
      "$REPO_DIR"/*)
        rm "$dest"
        echo "removed skill link $(basename "$dest")"
        removed=$((removed + 1))
        ;;
    esac
  done
fi

if [ -f "$CLAUDE_MD" ] && grep -qF "$BEGIN_MARK" "$CLAUDE_MD"; then
  tmp="$(mktemp)"
  awk -v b="$BEGIN_MARK" -v e="$END_MARK" \
    '$0==b{inblk=1} !inblk{print} $0==e{inblk=0}' "$CLAUDE_MD" >"$tmp"
  mv "$tmp" "$CLAUDE_MD"
  echo "managed block removed from $CLAUDE_MD"
fi

echo "Ejected: $removed skill link(s) removed. Nothing else touched."
