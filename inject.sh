#!/usr/bin/env bash
set -euo pipefail

# One-command install into a local Claude Code.
#
# - Symlinks skills/* into ~/.claude/skills/ (skips anything it does not own,
#   so existing skills and other managers are never overwritten).
# - Writes a managed always-on block with @-imports into ~/.claude/CLAUDE.md.
#
# Re-running is safe (idempotent). ./eject.sh reverses everything exactly.
# Override the target with CLAUDE_DIR=/path (override for sandboxed runs).

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="${CLAUDE_DIR:-$HOME/.claude}"
SKILLS_DIR="$CLAUDE_DIR/skills"
CLAUDE_MD="$CLAUDE_DIR/CLAUDE.md"
BEGIN_MARK="<!-- BEGIN agentic-playbook (managed) -->"
END_MARK="<!-- END agentic-playbook (managed) -->"

mkdir -p "$SKILLS_DIR"

linked=0
skipped=0
for src in "$REPO_DIR"/skills/*/; do
  src="${src%/}"
  name="$(basename "$src")"
  dest="$SKILLS_DIR/$name"
  if [ -L "$dest" ] && [ ! -e "$dest" ]; then
    # A dangling link is not a working skill for anyone — safe to take over
    # (happens when a previous clone of this repo was moved or deleted).
    echo "RELINK $name — replacing dangling symlink ($(readlink "$dest"))"
    ln -sfn "$src" "$dest"
    linked=$((linked + 1))
  elif [ -L "$dest" ]; then
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
  # Drop the old block plus the one separator blank line the append below adds,
  # so re-runs keep CLAUDE.md byte-for-byte stable instead of accumulating blanks.
  tmp="$(mktemp)"
  awk -v b="$BEGIN_MARK" -v e="$END_MARK" '
    $0==b { inblk=1; if (n > 0 && buf[n-1] == "") n--; next }
    $0==e { inblk=0; next }
    !inblk { buf[n++] = $0 }
    END { for (i = 0; i < n; i++) print buf[i] }
  ' "$CLAUDE_MD" >"$tmp"
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
