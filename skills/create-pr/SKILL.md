---
name: create-pr
description: >-
  Create or update GitHub pull requests using gh. Use when the user asks for a PR,
  or to open/update a pull request after branch work is ready.
---

# Create pull request

Use **`gh`** for all GitHub PR tasks. The PR describes **all commits** on the
branch since it diverged from base — not only the latest.

## Before creating

Run in parallel:

- `git status` — untracked files
- `git diff` — staged and unstaged
- Branch tracking vs remote (`git status` / `git branch -vv`)
- `git log` and `git diff [base]...HEAD` — full branch history since diverging from base

## Create PR

1. Push if needed: `git push -u origin HEAD` (requires network permission)
2. Create:

```bash
gh pr create --title "title" --body "$(cat <<'EOF'
## Summary
- ...

## Test plan
- [ ] ...

EOF
)"
```

3. Return the PR URL to the user.

## Rules

- **NEVER** update git config
- Push only the current branch; **never** force-push
- Use HEREDOC for body formatting
- Complete sentences in title and summary
