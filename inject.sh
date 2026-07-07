#!/usr/bin/env bash
set -euo pipefail

# One-command install into a local Claude Code.
#
# - Symlinks skills/* into ~/.claude/skills/ (skips anything it does not own,
#   so existing skills and other managers are never overwritten).
# - Writes a managed always-on block with @-imports into ~/.claude/CLAUDE.md.
#
# Re-running is safe (idempotent). ./eject.sh reverses everything exactly.
# Override the target with CLAUDE_DIR=/path (used by tests).

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_DIR/skills"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
BEGIN_MARK="<!-- BEGIN agentic-principles (managed) -->"
END_MARK="<!-- END agentic-principles (managed) -->"

mkdir -p "$SKILLS_DIR"

linked=0
skipped=0
for src in "$REPO_DIR"/skills/*/; do
  src="${src%/}"
  name="$(basename "$src")"
  dest="$SKILLS_DIR/$name"
  if [ -L "$dest" ]; then
    case "$(readlink "$dest")" in
      "$REPO_DIR"/*)
        ln -sfn "$src" "$dest"
        linked=$((linked + 1))
        ;;
      *)
        echo "SKIP $name — symlink owned by something else ($(readlink "$dest"))"
        skipped=$((skipped + 1))
        ;;
    esac
  elif [ -e "$dest" ]; then
    echo "SKIP $name — already exists in $SKILLS_DIR (not managed by this repo)"
    skipped=$((skipped + 1))
  else
    ln -s "$src" "$dest"
    linked=$((linked + 1))
  fi
done

touch "$CLAUDE_MD"
if grep -qF "$BEGIN_MARK" "$CLAUDE_MD"; then
  tmp="$(mktemp)"
  awk -v b="$BEGIN_MARK" -v e="$END_MARK" \
    '$0==b{inblk=1} !inblk{print} $0==e{inblk=0}' "$CLAUDE_MD" >"$tmp"
  mv "$tmp" "$CLAUDE_MD"
fi
printf '\n%s\n' "$BEGIN_MARK
@$REPO_DIR/principles/honesty.md
@$REPO_DIR/principles/karpathy-guidelines.md
@$REPO_DIR/user-rules/coding-principles.md
@$REPO_DIR/user-rules/communication.md
$END_MARK" >>"$CLAUDE_MD"

echo "Skills: $linked linked, $skipped skipped."
echo "Always-on block written to $CLAUDE_MD."
echo "Restart Claude Code to pick up the changes. Undo with ./eject.sh."
