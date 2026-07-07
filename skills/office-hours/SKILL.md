---
name: office-hours
description: Pressure-test an idea before building it - premise challenge, status quo, evidence of value, narrowest wedge, risk, cost of keeping. Use when asked to vet/scope a proposal, decide whether something is worth adding ("стоит ли внедрять X"), or before writing an implementation plan for a new capability. Skip for bug fixes with an obvious cause and for work already scoped by an accepted plan.
---

# Office hours

Pressure-test an idea before building it: six forcing questions, then a
verdict.

## The six forcing questions

1. **Q1 Premise challenge** — restate the ask in your own words; is it the right problem?
   Reframe before answering if not.
2. **Q2 Status quo** — what already addresses this (the real competitor is rarely
   "nothing")? What is genuinely missing?
3. **Q3 Evidence of value** — who benefits and what measurable number moves?
4. **Q4 Narrowest wedge** — the smallest version shippable now; name what is explicitly
   out of scope.
5. **Q5 Risk & verification** — blast radius; which existing test/gate proves nothing
   broke, or what new one must ship with the change?
6. **Q6 Cost of keeping** — ongoing token/maintenance cost; what would make us remove it?

## Smart routing (don't run all six every time)

| Change type | Run |
|---|---|
| Pure infra/tooling | premise + Q2 + Q4 (+ Q5 when hooks/CI are touched) |
| New user-facing capability or skill | Q1 + Q3 + Q4 + Q6 |
| Recurring-cost change (always-on prefix, hooks on hot paths) | Q2 + Q4 + Q6 |
| "Should we adopt X?" decisions | all six |

## Capture convention

If the target repo keeps design docs, write the session to
`docs/design/<topic>-office-hours.md` with an explicit **Verdict** section;
otherwise deliver the verdict in the response. End every vet with a verdict +
the narrowest wedge, never with an open-ended options list.

## Provenance

Adapted from the gstack `office-hours` skill by Garry Tan
([garrytan/gstack](https://github.com/garrytan/gstack), MIT; upstream
`office-hours/SKILL.md` v2.0.0). A deliberate adaptation, not a reconstruction:
upstream's four product-stage questions were replaced with engineering-relevant
ones (premise challenge, evidence of value, risk & verification, cost of
keeping). This file is the single source of truth going forward.
