---
name: findings-ledger
description: >-
  Track every review finding to an explicit, recorded disposition so nothing is
  lost in conversational triage. Use when triaging code-review or audit
  findings (agent or human), before merging a branch that received review
  feedback, or when deferring or rejecting a finding. Skip when a review
  produced zero findings.
---

# Findings ledger

**A finding may only leave the conversation through the ledger.** Verbal
triage ("agreed, will fix", "accepted, known risk") is how confirmed findings
ship to production.

## The ledger

One file per branch or PR — `REVIEW-LEDGER.md` unless the repo says otherwise
— with append-only rows:

| ID | Finding (1 line + source) | Disposition | Evidence |
|----|---------------------------|-------------|----------|

Exactly four dispositions:

- **fixed** — commit hash plus the check that proves the fix
- **deferred** — ticket/issue link, never a prose promise
- **refuted** — the code or output that disproves the finding
- **accepted-risk** — one-line rationale, named human who accepted it

## Rules

1. Record findings at intake, before fixing anything — the fix session is
   where findings get lost.
2. Every disposition cites evidence; `verification-before-completion` applies
   to the "fixed" rows.
3. Never end a session with findings outside the ledger; the ledger is the
   handoff to the next session.
4. Merge gate: no rows without a disposition. Accepted-risk is a valid answer;
   silence is not.
5. A dropped fix (revert, force-push, "delete that commit") reopens every row
   whose evidence pointed at it — re-check the ledger before any reply or PR
   text cites those rows.

## Provenance

Distilled from the terminus ANI retrospective (PRs 359/360, 2026-08): roughly
a third of a staff reviewer's comments were re-discoveries of findings agent
reviews had already reported and lost in conversational triage.
