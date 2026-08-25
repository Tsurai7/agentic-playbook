---
name: review-ratchet
description: >-
  Convert every human review finding or incident into a permanent automatic
  check so the error class cannot recur. Use after receiving human code-review
  feedback, after a retrospective, or when the same finding class appears a
  second time. Skip while findings are still being triaged (findings-ledger
  comes first).
---

# Review ratchet

Fixing the instance keeps quality flat; encoding the check is what compounds.
The harness only tightens.

## Method

Classify each finding and act:

| Could a check have caught it? | Action |
|-------------------------------|--------|
| Deterministic (parseable artifact, existence, naming, structure, cross-file consistency) | Write the check now: test, linter rule, CI script |
| Statistical (races, flaky timing) | Race detector / repeat-run gate on the changed packages |
| Judgment (design, altitude, semantics) | Add to the repo's invariant catalog → swept by `invariant-audit` |
| Not encodable | Record in the retro note; watch for recurrence |

## Rules

1. One finding class → one check, written before the PR closes — or an
   immediate follow-up with a ticket, never "later".
2. Checks only accumulate. Removing one is a written decision with a
   rationale, never a cleanup: "delete that commit" aimed at a guard test is
   how a guarded invariant silently becomes unguarded.
3. Prefer the narrowest check that kills the class — a gateway linter beats a
   style-guide paragraph.

## Provenance

Ratchet principle from harness-engineering practice, validated in an internal
production retrospective (2026-08): the one blocker-class bug (a workflow
gateway whose outgoing flows were all conditional with no default) was found
by a reviewer *scripting a repo-wide sweep* — writing exactly the ratchet
check the pipeline lacked.
