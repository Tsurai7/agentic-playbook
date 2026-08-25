---
name: spec-fidelity-review
description: >-
  Review a diff against what was asked — ticket, acceptance criteria, PDR/ADR,
  product requirements, PR description — instead of against the code. Use when
  asked whether a change matches its spec/ticket/requirements, or as the
  spec-fidelity lens of a multi-lens review. Skip when no spec source exists
  (report that instead of inventing one) and for code-quality review
  (staff-review) or invariant sweeps (invariant-audit).
---

# Spec fidelity review

This lens never reads the code for quality — it reads it for **conformance**.
Code that follows every standard but implements the wrong thing passes every
other lens and fails this one.

## Sources

Assemble the requirement set first, citing where each item comes from: ticket
acceptance criteria, PDR/ADR decisions, product requirement docs, and claims
in the PR description. If none exist, stop and report "no spec available" —
this lens without a spec is a hallucination generator.

## Method

1. **Forward pass — requirement → evidence.** For each requirement: implemented?
   where (file:line)? Quote the implementing code. Missing or partial = finding.
2. **Reverse pass — behavior → authorization.** For each behavior change in
   the diff: which requirement asks for it? Unauthorized behavior = scope
   creep finding.
3. **Quantifier pass.** The classic silent violation is a changed cardinality,
   scope, or actor, not a missing feature: "once per attempt" becoming "once
   per transaction", "only on no-match" becoming "on every check", per-user
   becoming per-account. Compare the spec's quantifiers (per what? when? who?)
   against what the code actually keys on.
4. **Staleness pass.** Spec statements the diff invalidates (a PDR describing
   an architecture this change replaces, a doc describing a removed call
   site) are findings too — the spec is part of the deliverable.
5. **Quote the spec line for every finding.** A conformance finding without
   the requirement text it violates is an opinion.

## Rules

- Run in a fresh context with only the spec sources and the diff — not the
  author's reasoning, not other lenses' output.
- Never rerank against other lenses' findings; conformance and quality are
  deliberately separate verdicts.
- Findings go to the findings-ledger like any other review output.

## Provenance

Lens separation motivated by perspective-based reading (Basili et al., NASA
SEL: distinct perspectives find near-disjoint defect sets) and validated
locally: in an internal retrospective (2026-08) the code/platform reviewer
and the requirements reviewer overlapped on almost nothing, and the two
costliest late findings — a billed check whose contract said once per attempt
silently becoming once per transaction, and an alert firing on every check
where the requirement said only on mismatches — are exactly passes 3 and 1.
Mechanics adapted from the two-axis review in mattpocock/skills (parallel
sub-agents, never merge across axes, quote the spec line).
