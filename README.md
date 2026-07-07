# agentic-principles

Portable, toolset-agnostic guidance for coding agents: always-on principles,
user rules, and triggered skills. Built for Claude Code; the content is plain
markdown, so any `AGENTS.md` consumer can adopt it. Depends on nothing beyond
standard tools (`git`, `gh`).

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

**Claude Code** — one command each way:

```bash
./inject.sh   # symlink skills + add a managed always-on block to ~/.claude/CLAUDE.md
./eject.sh    # exact reverse; touches nothing it does not own
```

Step-by-step details and Windows instructions: [SETUP.md](SETUP.md).

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
