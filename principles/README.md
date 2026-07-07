# Principles (always-on)

Principles are **always-on behavioral guidance** — they shape every action the
agent takes, without waiting for a trigger to match. Load every `*.md` here
into your agent's always-on layer:

- **Claude Code** — inline into `CLAUDE.md` (global `~/.claude/CLAUDE.md` or
  per-project).
- **Cursor** — render as an `alwaysApply: true` rule in `~/.cursor/rules/`.
- **Other harnesses** — include in `AGENTS.md` or the system prompt.

## Principle vs skill — where does new guidance go?

| | Principle (`principles/`) | Skill (`skills/`) |
|---|---|---|
| Loaded | Always, every turn | On trigger (description match) |
| Use for | Cross-cutting behavioral defaults (how to think, edit, verify) | Situational procedures (`create-pr`, `office-hours`, `systematic-debugging`) |
| Cost | Always in context — keep short | Near-zero until triggered |

Rule of thumb: if it should apply *even when the agent isn't thinking about it*,
it's a principle. If the agent should reach for it *when a specific situation
arises*, it's a skill. Keep principles short — they pay a per-turn context cost.
