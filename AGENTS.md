# Agent instructions (portable)

Use this file as a project `AGENTS.md`, or inline it into a global always-on
layer (`~/.claude/CLAUDE.md`, Cursor rules). Everything referenced here lives in
this repository and requires no toolset beyond `git`, `gh`, and an agent
harness.

## Global defaults

1. **Git commits** — Only when the user explicitly asks; follow skill
   `git-safety`.
2. **Pull requests** — Use `gh` per skill `create-pr`.
3. **Done means verified** — Before claiming success, run checks per skill
   `verification-before-completion`.
4. **Right-size tooling** — For a trivial single-fact lookup (one symbol, one
   file, a literal string), use the single lightest tool that answers it and
   stop. Treat multi-step, structural, or high-blast-radius work (3+ coupled
   files, "who calls / what breaks" questions, ambiguous scope) as heavy; when
   in doubt, escalate — heavier tooling earns its cost on hard tasks.

## Principles (always-on)

`principles/*.md` and `user-rules/*.md` are always-on behavioral guidance —
inline them into the harness's always-on layer so they apply every turn. See
[principles/README.md](principles/README.md) for the principle-vs-skill
boundary.

## Skills (invoke or auto-discover)

Skills live in `skills/<name>/SKILL.md`; each frontmatter description is its
trigger and is injected by the provider — do not restate them here.
