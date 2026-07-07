---
name: staff-review
description: >-
  Staff-level code review method for a diff or branch: review against stated
  intent, confidence-calibrated findings, verify every finding against the code
  before reporting, fix-first protocol. Use when asked to review code like a
  senior/staff engineer, or when review findings must be high-precision. This is
  the review method — it complements harness-native review commands (e.g.
  /code-review), not replaces them. Skip for reviewing plans (plan-review) or
  vetting ideas (office-hours).
---

# Staff review

## Intent first, quality second

Before judging the code, check **did they build what was requested — nothing
more, nothing less?** Read the stated intent (PR description, commits, plan
file) and compare against the diff. Open with `Scope: CLEAN / DRIFT / MISSING
— Intent: <1 line> — Delivered: <1 line>`, listing out-of-scope changes and
unaddressed requirements. Informational — it frames the review, not blocks it.

## Look beyond the diff

A new enum value, status, tier, or constant is the one class of change a
within-diff review cannot judge: grep for the files handling sibling values and
read them — the bug lives where the new value is *not* handled.

## Confidence calibration

Every finding carries a confidence score, and the score decides its fate:

| Confidence | Meaning | Fate |
|---|---|---|
| 9–10 | Verified by reading the specific code | Report |
| 7–8 | Strong pattern match | Report |
| 5–6 | Could be a false positive | Report with an explicit caveat |
| 3–4 | Suspicious but unproven | Appendix only |
| 1–2 | Speculation | Only if severity would be critical |

Finding format: `[SEVERITY] (confidence: N/10) file:line — problem — suggested fix`.

## The verification gate (before emitting)

A finding enters the report only if you can **quote the motivating line(s)** —
the verbatim code that makes it a bug. Can't quote it? Demote to confidence ≤5;
never inflate to dodge the gate. For framework-generated symbols (ORM columns,
decorators, migrations), quote the construct that generates them — a failed
grep for the literal name proves nothing.

## Fix-first, then adversarial pass

Every finding gets an action: mechanical and safe → fix it; behavioral or risky
→ ask, showing the proposed fix. Before the verdict, adversarially try to
refute each of your own findings — and remember risk is not proportional to
diff size: a 5-line auth change can be critical. Deliver the verdict per the
`answer-shapes` code-review shape.

## Provenance

Distilled from the gstack `/review` skill by Garry Tan
([garrytan/gstack](https://github.com/garrytan/gstack), MIT) — method only,
none of the runtime (specialist dispatch, Greptile/Codex, learnings database).
