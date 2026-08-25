---
name: invariant-audit
description: >-
  Adversarially sweep a repo's standing invariants (billing/idempotency, PII,
  published contracts, deploy order) across every execution path a diff
  touches — retry, redelivery, timer, error, concurrency, rollout — not just
  the happy path. Use before merging changes that touch money, external calls,
  PII, published contracts, or workflow/state-machine definitions. Skip for
  docs-only diffs and refactors that add no execution paths.
---

# Invariant audit

Acceptance criteria verify designed paths; invariants must hold on paths
nobody designed. The audit is a matrix — invariant × path — with evidence per
cell.

## Inputs

- The repo's invariant catalog (`INVARIANTS.md` or equivalent). If absent,
  derive candidates from the diff's blast surface — what costs money, what is
  PII, what is a published contract, what must be idempotent — propose the
  file, and audit against the candidates.
- The diff's **path inventory**: happy path; retry/redelivery; timeout/timer;
  error/exception; concurrent or duplicate delivery; partial rollout (old
  config with new code, and the reverse).

## Method

1. For each invariant, walk each path and ask: can this path violate it?
2. Fill the matrix. Every cell needs evidence — a code citation, a test, or
   check output. "Surely fine" is an empty cell.
3. An unswept cell is a finding, not a footnote.

| Invariant | happy | retry | timer | error | concurrent | rollout |
|-----------|-------|-------|-------|-------|------------|---------|

## Classic cells (each shipped past multi-model review once)

- Billed call re-executed by job redelivery after a failed completion ack.
- Retry of a non-idempotent start command → second billed instance.
- Metric counts successful parses, not attempts → reconciliation blind to
  exactly the error window you audit.
- PII escaping through an upstream error message wrapped into logged errors.
- Required config key plus a lagging config repo → total outage on rollout.

## Provenance

Distilled from the terminus ANI retrospective (PRs 359/360, 2026-08): the
seven costliest human-review findings were invariant violations on
non-designed paths, while the invariants themselves existed as happy-path
acceptance criteria.
