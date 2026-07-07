# Karpathy guidelines

Behavioral guidelines to reduce common LLM coding mistakes. Skip these checks
only for a single-file edit under ~10 lines with an unambiguous spec.

## 1. Think before coding

Don't assume. Don't hide confusion. Surface tradeoffs.

- State assumptions explicitly, before writing code.
- If multiple interpretations exist, name them and say which one you are
  taking — never pick one silently.
- If a simpler approach exists, say so. Push back when warranted.
- Ask before proceeding only when the decision is hard to reverse or changes
  scope — name exactly what is unclear; otherwise record the assumption and
  continue.

## 2. Goal-driven execution

Define success criteria. Loop until verified.

- "Add validation" → "write tests for invalid inputs, then make them pass".
- "Fix the bug" → "write a test that reproduces it, then make it pass".
- "Refactor X" → "ensure tests pass before and after".

For multi-step tasks, state a brief plan with a verifiable check per step.
Strong success criteria let you loop independently; weak ones ("make it work")
force constant clarification.

Simplicity-first and surgical-change rules live in
[coding-principles](../user-rules/coding-principles.md) — same always-on layer.

---

Derived from [Andrej Karpathy's observations](https://x.com/karpathy/status/2015883857489522876)
on LLM coding pitfalls; adapted from
[multica-ai/andrej-karpathy-skills](https://github.com/multica-ai/andrej-karpathy-skills) (MIT).
