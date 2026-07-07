# agentic-principles

Portable, toolset-agnostic guidance for coding agents: always-on principles,
user rules, and triggered skills. Everything here works with any agent harness
(Claude Code, Cursor, or a plain `AGENTS.md` consumer) and depends on nothing
beyond standard tools (`git`, `gh`).

This repository originated as the portable layer of a private agent-config
repo and is now the source of truth for that layer.

## Layout

- [AGENTS.md](AGENTS.md) — entry document tying principles, rules, and skills
  together. Use as-is for a project `AGENTS.md` or a global `CLAUDE.md`.
- [principles/](principles/README.md) — always-on behavioral guidance, loaded
  every turn:
  - [honesty.md](principles/honesty.md) — back claims with evidence, separate
    fact from inference, report outcomes faithfully, no hidden actions.
  - [karpathy-guidelines.md](principles/karpathy-guidelines.md) — think before
    coding, simplicity first, surgical changes, goal-driven execution.
- [user-rules/](user-rules/coding-principles.md) — always-on rules:
  - [coding-principles.md](user-rules/coding-principles.md) — minimal scope, no
    over-engineering, existing conventions, comments, useful tests only.
  - [communication.md](user-rules/communication.md) — how to write responses,
    code citations, commit and PR descriptions.
- `skills/` — triggered guidance, loaded on description match:
  - [office-hours](skills/office-hours/SKILL.md) — pressure-test an idea before
    building it.
  - [systematic-debugging](skills/systematic-debugging/SKILL.md) — root-cause
    debugging discipline.
  - [verification-before-completion](skills/verification-before-completion/SKILL.md)
    — evidence before claiming done.
  - [answer-shapes](skills/answer-shapes/SKILL.md) — output skeletons for
    common coding deliverables.
  - [model-orchestration](skills/model-orchestration/SKILL.md) — route sub-tasks
    to the cheapest capable model tier.
  - [prompt-caching-playbook](skills/prompt-caching-playbook/SKILL.md) —
    maximize prompt-cache hit rate across providers.
  - [git-safety](skills/git-safety/SKILL.md) — safe commit workflow.
  - [create-pr](skills/create-pr/SKILL.md) — pull requests via `gh`.

## How to consume

**Claude Code** — copy or symlink `skills/*` into `~/.claude/skills/` (or a
project's `.claude/skills/`), and inline `principles/*.md` +
`user-rules/*.md` into `~/.claude/CLAUDE.md` or the project `CLAUDE.md`.

**Cursor** — render each principle and user rule as an `alwaysApply: true`
rule in `~/.cursor/rules/`; skills map to description-triggered rules.

**Anything else** — [AGENTS.md](AGENTS.md) and the principle files are plain
markdown; include them in whatever always-on layer your harness has.

## What does not belong here

Skills bound to a specific local toolset — MCP servers, personal CLIs, local
pipelines — stay in the consuming config repo. The test for inclusion: a skill
lands here only if it works on a machine with nothing but `git`, `gh`, and an
agent harness installed.

## License

MIT — see [LICENSE](LICENSE). Third-party attributions (adapted material) are
listed there and in the Provenance section of the affected files.
