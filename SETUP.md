# Setup

How to apply this repository to a local Claude Code installation. Everything is
plain markdown: skills are auto-discovered from `~/.claude/skills/`, always-on
principles and user rules are imported into `~/.claude/CLAUDE.md`.

## macOS / Linux

1. Clone the repository:

```bash
git clone https://github.com/Tsurai7/agentic-principles.git ~/agentic-principles
```

2. Link the skills. Symlinks are preferred over copies — a `git pull` in the
   clone updates them with no extra step:

```bash
mkdir -p ~/.claude/skills
for s in ~/agentic-principles/skills/*/; do
  ln -sfn "$s" ~/.claude/skills/"$(basename "$s")"
done
```

3. Import the always-on layer. Append these lines to `~/.claude/CLAUDE.md`
   (create the file if it does not exist):

```markdown
@~/agentic-principles/principles/honesty.md
@~/agentic-principles/principles/karpathy-guidelines.md
@~/agentic-principles/user-rules/coding-principles.md
@~/agentic-principles/user-rules/communication.md
```

Claude Code inlines `@path` imports at session start, so the principles stay
in sync with the clone.

4. Verify: start a new Claude Code session; the eight skills should appear in
   the available-skills list, and `/memory` should show the imported files.

## Windows

Claude Code runs natively (PowerShell) or under WSL. Under WSL, follow the
macOS/Linux steps inside the distro.

Native (PowerShell):

1. Clone the repository:

```powershell
git clone https://github.com/Tsurai7/agentic-principles.git "$env:USERPROFILE\agentic-principles"
```

2. Copy the skills. Copying is the simplest reliable option — directory
   symlinks on Windows require Developer Mode or an elevated shell:

```powershell
New-Item -ItemType Directory -Force "$env:USERPROFILE\.claude\skills" | Out-Null
Get-ChildItem "$env:USERPROFILE\agentic-principles\skills" -Directory |
  ForEach-Object { Copy-Item $_.FullName "$env:USERPROFILE\.claude\skills\$($_.Name)" -Recurse -Force }
```

3. Import the always-on layer. Append to `%USERPROFILE%\.claude\CLAUDE.md`,
   using absolute Windows paths:

```markdown
@C:\Users\<you>\agentic-principles\principles\honesty.md
@C:\Users\<you>\agentic-principles\principles\karpathy-guidelines.md
@C:\Users\<you>\agentic-principles\user-rules\coding-principles.md
@C:\Users\<you>\agentic-principles\user-rules\communication.md
```

4. Verify the same way: new session, skills listed, `/memory` shows the
   imports.

## Updating

- macOS/Linux: `git pull` in the clone — symlinked skills and `@`-imported
  principles pick up the changes automatically.
- Windows (copied skills): `git pull`, then re-run the copy step from item 2.

## Per-project instead of global

The same layout works inside a single repository: put skills in
`.claude/skills/` and the `@` imports in the project's `CLAUDE.md`. Use this
when a team repo should carry the guidance, rather than one machine.
