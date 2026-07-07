---
name: plan-review
description: >-
  Engineering review of an implementation plan before any code is written:
  scope challenge first, then architecture, code quality, tests, performance.
  Use when asked to review/critique a plan, design doc, or proposed approach,
  or before approving a multi-file implementation plan. Skip for reviewing a
  code diff (staff-review), for deciding whether the idea is worth building at
  all (office-hours), and for single-step plans with an obvious shape.
---

# Plan review

## Confirm the target

Name what is being reviewed (which plan, solving what problem) and the goal it
serves before critiquing. If the idea itself is unvetted, run `office-hours`
first — a plan review sharpens a plan; it cannot justify one.

## Step 0: scope challenge (before any section review)

1. **Reuse first** — what existing code already solves each sub-problem?
   Prefer capturing outputs from existing flows over building parallel ones.
2. **Minimum change set** — flag anything deferrable without blocking the goal.
3. **Complexity smell** — more than ~8 files touched or 2 new
   classes/services: stop and challenge whether fewer moving parts reach the
   same goal. Propose the minimal version; let the owner decide.
4. **Built-in over custom** — for each new pattern or component, check whether
   the framework/runtime ships one before accepting a hand-rolled version.
5. **No silent drops** — deferred work (distribution, ops, migrations) goes in
   an explicit "NOT in scope" list, not out of memory.

Once the scope decision is made, commit to it — do not re-argue scope during
the section reviews below.

## Section review

Work in order, at most ~8 top issues total across sections:
**Architecture → Code quality → Tests → Performance.**
For tests, demand a verifiable check per plan step — a plan step without its
proving command is a wish (see `verification-before-completion`).

## Judgment instincts to apply throughout

- **Blast radius** — worst case, and how many systems/people it touches.
- **Boring by default** — innovation tokens are scarce; proven tech elsewhere.
- **Incremental over big-bang** — strangler fig, canary, refactor-then-change.
- **Reversibility** — flags and staged rollouts make being wrong cheap.
- **Essential vs accidental complexity** — is this solving a real problem or
  one the plan created?

End with a verdict: approve / reduce scope / rework, with the blocking items.

## Provenance

Distilled from the gstack `/plan-eng-review` skill by Garry Tan
([garrytan/gstack](https://github.com/garrytan/gstack), MIT) — method only,
none of the runtime (no brain preflight, design-doc discovery, or interactive
scaffolding carried over).
