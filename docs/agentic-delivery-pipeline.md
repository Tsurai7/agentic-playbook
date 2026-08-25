# Agentic delivery pipeline

The end-to-end process this repo's skills plug into: from receiving product
requirements to sending a pull request to review. Skills are the *how*; this
document is the *when*. Distilled from an internal production retrospective
(2026-08) and the sources in
[review-effectiveness-research.md](review-effectiveness-research.md).

## The goal and the two principles

**Goal:** the PR passes an independent, severity-gated review (highest effort,
fresh context, Critical/High-only reporting) with **zero Critical/High
findings**. Everything below is a means to that number.

**Principle 1 — the harness outweighs the model.** In the motivating
retrospective, the same model family that had already reviewed the code
in-session found ~30 additional real defects when run with a different
harness: fresh context, whole-PR scope, higher effort, a severity gate, and
scriptable read-only tools. When review quality disappoints, fix the harness
before switching models.

**Principle 2 — everything that can be a verifier becomes a verifier.** A
deterministic check catches its class every time and instantly; a reviewer
catches it sometimes and expensively. Each stage below pushes work from the
probabilistic column into the deterministic one, and
[review-ratchet](../skills/review-ratchet/SKILL.md) makes the push permanent.

**Context boundaries (always):** author, reviewer, critic, and test-writer are
different fresh contexts. A reviewer never sees the author's reasoning — only
the spec, the invariants, and the code. A findings ledger
([findings-ledger](../skills/findings-ledger/SKILL.md)) is open from stage 0
to merge; anything found, deferred, or assumed becomes a row when discovered,
not later.

## Stage map

```
0 Requirements → 1 Design → 2 Plan-contract → 3 Implementation → 4 Self-review → 5 Package → PR
        ▲ human gate   ▲ human gate                                  ▲ main gate
```

## Stage 0 — Requirements intake

Input: a ticket, product requirements, a thread. Output: an agreed,
numbered requirement list.

- Pressure-test the ask before designing (office-hours): is this the right
  problem, who benefits and what number moves, what is the narrowest wedge,
  what does keeping it cost.
- Rewrite requirements as **numbered, individually testable statements**
  ("when X, the system shall Y"; "the system shall never Z"). An ambiguous
  requirement is a future critical: ambiguity gives the generator and the
  reviewer *correlated* blind spots.
- Run [claim-verification](../skills/claim-verification/SKILL.md) on the
  requirements themselves: do the named fields, systems, volumes, and
  contracts actually exist? Requirements lie too.
- Unknowns become a batch of questions, each tagged with the decision it
  blocks; answers land in the ticket, not in chat.

**Gate 0→1 (human):** requirements agreed; every unknown answered or recorded
as an accepted risk with a name on it.

## Stage 1 — Design

Input: the requirement list. Output: an approved design doc with numbered
invariants.

- Reconnaissance first: structural code navigation (blast radius, callers), a
  **sibling inventory** (which existing unit is this most like — it becomes
  the reference for stages 3–4), and production data checks.
- The design doc carries four mandatory sections: **alternatives and
  decisions** (with "why not"); **invariants** — which entries of the repo's
  standing catalog the change touches and which new ones it introduces
  (money, PII, idempotency, published contracts); **rollout** — deployment
  ordering across repos, in-code defaults so missing config cannot take a
  service down, flag gating; **observability** — which metrics prove the
  feature works and their exact semantics (a counter counts attempts, not
  successful parses).
- Every acceptance criterion names its verification (which test or check
  proves it); a criterion without one is not accepted.
- Review the plan (plan-review: scope challenge first), then an independent
  design review in a fresh context.

**Gate 1→2 (human):** design approved; invariants numbered; every criterion
verifiable; rollout requires no cross-repo ordering.

## Stage 2 — Plan as contract

Input: the design. Output: a machine-checkable work plan.

- A feature list where **every item carries a pass/fail check runnable as a
  command**. No check, no item — this is what prevents premature "done".
- The test plan is first-class: requirement → test mapping; **fault-specific
  mutants** for failure paths (remove the idempotency guard, deliver the job
  twice, fail the completion — the suite must fail on each); which ratchet
  checks ship in the same PR as the feature.
- Route mechanical items to cheap models; keep design-sensitive ones on the
  strong tier (model-orchestration).

**Gate 2→3:** every plan item machine-checkable; the test plan covers every
requirement and every invariant path; the plan is committed as a file.

## Stage 3 — Implementation

Input: the plan. Output: a branch with every plan item green.

- **One feature, one loop, fresh context** — memory is the plan file, a
  progress file, and git, not a long conversation. A short clean run beats a
  long cluttered one.
- **Red/green with separated contexts:** a different context writes the test;
  the red run is recorded before the fix; implementation proceeds to green.
  "A test guards X" requires having seen it fail when X is broken
  (verification-before-completion).
- **Sibling protocol at write time:** implement a new unit as a diff against
  the named sibling; justify every divergence (transport, timestamps, error
  handling, mappings, logging) as it is written.
- **No aspirational claims:** no comment or doc may say "a test locks this"
  before that test exists and has failed. A claim you write is a check you
  run.
- Everything deferred becomes a ledger row immediately. After each item:
  build, lint, tests, race detector on changed packages.

**Gate 3→4:** all plan checks green; the branch freezes — from here, only
review-driven fixes.

## Stage 4 — Self-review of the frozen state

Input: the frozen final diff. Output: zero Critical/High and a clean ledger.
The order is fixed: cheap deterministic before expensive probabilistic.

1. **Deterministic gates:** build, lint, full tests, repeated race-detector
   runs on changed packages, a mutation smoke test over the diff, the repo's
   ratchet checks, referenced-files-exist.
2. [invariant-audit](../skills/invariant-audit/SKILL.md): the invariant ×
   path matrix (happy / retry / redelivery / timer / error / concurrent /
   rollout) with evidence per cell; an empty cell is a finding.
3. [staff-review](../skills/staff-review/SKILL.md) of the whole diff: fresh
   context, ideally a different model lineage, high effort, input = spec +
   invariants + code only.
4. **Lens dispatch** (from staff-review): parallel fresh contexts for
   [spec-fidelity-review](../skills/spec-fidelity-review/SKILL.md) and
   [test-adequacy-review](../skills/test-adequacy-review/SKILL.md); reports
   stay per-lens, never merged or reranked across lenses.
5. **Critic pass** per finding: AGREE / DISAGREE with a code citation;
   survivors go to the ledger; fixes trigger a **delta re-review** — fixes
   are the main source of new blockers.
6. **A local replica of the target review gate:** the same severity-gated,
   highest-effort review prompt the CI (or the human reviewer) will apply,
   run on the final state. Rehearse the exam with the examiner.
7. [claim-verification](../skills/claim-verification/SKILL.md) over the PR
   artifacts — description, code comments, docs — against the tree at HEAD.

**Gate 4→5 (the main gate):** local gate replica reports zero Critical/High;
no ledger row without a disposition (fixed@commit / deferred→ticket /
refuted+evidence / accepted-risk+name); no empty cells in the invariant
matrix.

## Stage 5 — Package and send

- The PR description carries: intent and requirement mapping; the invariant
  audit summary; an **evidence block** (verification commands and their
  output, re-runnable by the reviewer); deliberate limitations; deploy notes.
  **Never compress safety-relevant sections away** before review.
- Commit and open the PR through the usual safety rails (git-safety,
  create-pr).
- After any force-push or revert: re-run claim-verification over everything
  already published; the ledger reopens every row whose evidence pointed at a
  dropped commit.

**After review (coda):** every reviewer finding goes to the ledger, then
through review-ratchet — "could a check have caught this?" — and the checkable
ones become permanent gates before the PR closes. The pipeline's metric:
Critical/High findings per PR at the independent gate, trending to zero.

## Cross-cutting rules

| Rule | Statement | Owes its place to |
|---|---|---|
| Context boundaries | Author ≠ reviewer ≠ critic ≠ test-writer; reviewers never see author reasoning | Self-review by the authoring lineage shipped a false "a test locks it" claim |
| Effort policy | Mechanical work low/medium; design and review high+; the final gate at maximum | Confidence-filtered mid-effort review drops exactly the tail a second reviewer then finds |
| Ledger always open | Findings leave only through a disposition | A third of second-pass findings were re-discoveries lost in triage |
| Verifier over prompt | Anything deterministically checkable goes to CI; gates only accumulate | The one blocker-class bug was found by a scripted sweep, not by reading |
| Claims are checks | Any written statement about the tree is a list of checks to run — on your own text first | Phantom guard tests; build targets referencing files on no branch |
| Silence is not cleanliness | An empty review is weak evidence (agentic reviewer recall is 3–10%) | A gate's strength is its strictness, not its quietness |

**Human touchpoints:** gate 0 (requirements), gate 1 (design), every
accepted-risk disposition, and the decision to send. Everything else is
agent work between deterministic gates.
