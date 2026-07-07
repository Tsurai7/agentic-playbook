# Setup

How to apply this repository to a local Claude Code installation. Everything is
plain markdown: skills are auto-discovered from `~/.claude/skills/`, always-on
principles and user rules are imported into `~/.claude/CLAUDE.md`.

## macOS / Linux

Install with one command:

```bash
git clone https://github.com/Tsurai7/agentic-principles.git ~/agentic-principles
~/agentic-principles/inject.sh
```

`inject.sh` symlinks `skills/*` into `~/.claude/skills/` and appends a managed
`@`-import block (principles + user rules) to `~/.claude/CLAUDE.md`. It never
overwrites anything it does not own: an existing skill directory, or a symlink
pointing somewhere else, is skipped with a warning. Re-running it is safe —
already-managed links are refreshed and the block is replaced in place.

Remove with one command:

```bash
~/agentic-principles/eject.sh
```

`eject.sh` is the exact reverse: it removes only the symlinks that point into
the clone and only the managed block. The rest of your skills and `CLAUDE.md`
are untouched.

Restart Claude Code after either command. Verify after install: in a new
session the eight skills appear in the available-skills list, and `/memory`
shows the imported principle files.

Note: if another config manager already installed skills with the same names
(as real directories), `inject.sh` reports them as skipped — that is expected;
remove the old copies first if you want this clone to own them.

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
  principles pick up the changes automatically; re-run `inject.sh` only when
  the skill list itself changed.
- Windows (copied skills): `git pull`, then re-run the copy step from item 2.

## Per-project instead of global

The same layout works inside a single repository: put skills in
`.claude/skills/` and the `@` imports in the project's `CLAUDE.md`. Use this
when a team repo should carry the guidance, rather than one machine.
