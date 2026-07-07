# agentic-playbook

Portable, toolset-agnostic guidance for coding agents: always-on principles,
user rules, and triggered skills. Built for Claude Code; the content is plain
markdown, so any `AGENTS.md` consumer can adopt it. Depends on nothing beyond
standard tools (`git`, `gh`).

This repository originated as the portable layer of a private agent-config
repo and is now the source of truth for that layer.

## Layout

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
  - [plan-review](skills/plan-review/SKILL.md) — engineering review of an
    implementation plan before any code is written.
  - [systematic-debugging](skills/systematic-debugging/SKILL.md) — root-cause
    debugging discipline.
  - [verification-before-completion](skills/verification-before-completion/SKILL.md)
    — evidence before claiming done.
  - [staff-review](skills/staff-review/SKILL.md) — staff-level code review
    method: intent first, calibrated confidence, verified findings.
  - [answer-shapes](skills/answer-shapes/SKILL.md) — output skeletons for
    common coding deliverables.
  - [model-orchestration](skills/model-orchestration/SKILL.md) — route sub-tasks
    to the cheapest capable model tier.
  - [prompt-caching-playbook](skills/prompt-caching-playbook/SKILL.md) —
    maximize prompt-cache hit rate across providers.
  - [git-safety](skills/git-safety/SKILL.md) — safe commit workflow.
  - [create-pr](skills/create-pr/SKILL.md) — pull requests via `gh`.
- `docs/` — background research the skills are grounded in:
  - [ai-native-agentic-engineering.md](docs/ai-native-agentic-engineering.md) —
    how Anthropic, OpenAI, Google, and Cursor do model orchestration and token
    efficiency; cited and dated.
  - [ai-for-software-engineering.md](docs/ai-for-software-engineering.md) — a
    practitioner's playbook for getting real value out of coding agents.
  - [ai-in-daily-life.md](docs/ai-in-daily-life.md) — a practical guide to AI
    assistants outside of coding.

## How to consume

**Claude Code** — one command each way:

```bash
./inject.sh   # symlink skills + add a managed always-on block to ~/.claude/CLAUDE.md
./eject.sh    # exact reverse; touches nothing it does not own
```

Step-by-step details and Windows instructions: [SETUP.md](SETUP.md).

**Anything else** — the principle and skill files are plain markdown; include
them in whatever always-on layer your harness has.

## License

MIT — see [LICENSE](LICENSE). Third-party attributions (adapted material) are
noted in the Provenance section of each affected file.
