# Review-effectiveness research: annotated sources

The evidence base behind the review-discipline skills (staff-review lens
dispatch, findings-ledger, invariant-audit, claim-verification,
spec-fidelity-review, test-adequacy-review, review-ratchet). Collected and
verified 2026-08-25.

Legend — verification: ✅ headline numbers checked against the primary source;
⚠️ not independently verified, treat quantitative claims with care.
Priority is calibrated for a staff engineer running agentic delivery on
production backend services: **Must** (read in full), **Skim** (one pass for
the load-bearing result), **Ref** (look up when the topic bites), **Skip**
(safe to ignore unless the niche applies).

## LLM review effectiveness — why "the agent found nothing" proves little

- ✅ **Must** · [AACR-Bench: Evaluating Automatic Code Review with Holistic
  Repository-Level Context](https://arxiv.org/html/2601.19494v1) — 200 PRs,
  1,505 expert-verified comments. LLM reviewers: recall 36–47% at 5–8%
  precision; agentic reviewers: recall 3–10% at 0.08–0.15 comments per patch;
  recall falls as required context widens (diff 33.8% → repo 17.6%). The
  numeric ground for two skill rules: a silent review is weak evidence of
  cleanliness, and cross-artifact invariants need deterministic checkers, not
  reviewer attention.
- ⚠️ **Ref** · [SWR-Bench](https://arxiv.org/abs/2509.01494) — same
  conclusion from a different 1,000-PR benchmark: ACR tools underperform and
  skew toward functional errors over design/consistency issues.
- ⚠️ **Skim** · [Deep Code Review: Recall vs Precision
  (Augment Code)](https://www.augmentcode.com/guides/deep-code-review-recall-vs-precision) —
  practitioner framing of the same trade-off; note the claim that
  LLM-generated verifiers cluster their errors (shared bias), unlike humans.

## Multi-agent and adversarial review structure — why "add another model" fails

- ✅ **Must** · [Adversarial Review: Structured Disagreement for Grounded
  Agentic Code Review](https://arxiv.org/html/2608.18167) — naive multi-agent
  consensus scores F1 0.457, below a single reviewer (0.495); forcing the
  critic to verdict AGREE / DISAGREE-with-code-citation over a frozen artifact
  reaches 0.533 with fewer agents. Source of the critic-pass contract in
  staff-review. Key sentence: "When two LLM agents are asked to agree on a
  joint output, they tend to agree with each other. They do not always find
  the truth."
- ✅ **Skim** · [Cross-Model LLM Code Review](https://arxiv.org/html/2607.21656v1) —
  116 LiveCodeBench tasks: review benefit is asymmetric (+18.1pp one
  direction, −8.6pp the other; harmful reviews are wholesale rewrites). The
  one result to retain: pairing direction beats pairing count.
- ⚠️ **Skip** · [Refute-or-Promote](https://arxiv.org/pdf/2604.19049) —
  kill-mandates and context asymmetry; direction plausible, quantitative
  claims did not survive verification. Read only if building a dedicated
  refuter pipeline.

## Lens separation — the pre-LLM evidence

- ✅ **Must** · [The Empirical Investigation of Perspective-Based Reading
  (Basili et al., NASA SEL)](https://www.cs.umd.edu/~mvz/handouts/emp_pbr.pdf) —
  reviewers reading from distinct perspectives cover a document better than
  the same number reading ad hoc, and the perspectives find near-disjoint
  defect sets. The foundation of the lens-dispatch section; decades older
  than LLMs and still the cleanest statement of why lenses work.
- ✅ **Skim** · [PBR: A Replicated Experiment
  (Springer)](https://link.springer.com/article/10.1007/s10664-006-5967-6) —
  the honest caveat: where two perspectives converged on the same defects,
  the PBR advantage vanished. Hence the rule that an overlapping lens adds
  cost, not coverage.

## Deterministic gates and test quality

- ✅ **Must** · [Meta: LLMs Are the Key to Mutation Testing and Better
  Compliance (ACH)](https://engineering.fb.com/2025/09/30/security/llms-are-the-key-to-mutation-testing-and-better-compliance/) —
  the only industrial-scale evidence for mutation-gated agent tests:
  fault-specific mutants, 73% of generated tests accepted by engineers,
  equivalent-mutant detector at 0.95/0.96 precision/recall. Grounds the
  test-adequacy mutation discipline and the verification-before-completion
  evidence row. Companion: [FSE 2025 industry
  paper](https://conf.researchr.org/details/fse-2025/fse-2025-industry-papers/16/Mutation-Guided-LLM-based-Test-Generation-at-Meta) (⚠️ its exact corpus
  counts were not re-verified).
- ⚠️ **Ref** · [Mutation-Guided Diagnosis of Regression
  Suites](https://arxiv.org/pdf/2604.01518) — LLM-written tests
  systematically lack boundary-killing assertions, so coverage overstates
  their strength.
- ⚠️ **Ref** · [The Specification as Quality Gate](https://arxiv.org/pdf/2603.25773) —
  thesis that ambiguous specs give generator and reviewer *correlated*
  mistakes, so spec clarity controls detection rate. Motivates numbered,
  testable requirements; quantitative side unverified.

## Harness engineering and long-running agents

- ✅ **Must** · [Anthropic: Effective harnesses for long-running
  agents](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) —
  feature lists with per-item pass/fail checks, one feature per session,
  progress files and git as memory, end-to-end verification "as the user".
- **Must** · [Anthropic: Claude Code best
  practices](https://www.anthropic.com/engineering/claude-code-best-practices) —
  the baseline document; if only one thing is read from this list, this.
- **Skim** · [How Boris Uses Claude Code](https://howborisusesclaudecode.com/) —
  dense tip collection from Claude Code's creator; the two keepers: "give
  Claude a way to verify its own work" and separating test-writer from
  implementer contexts.
- **Must** · [amux: Harness Engineering — the ratchet
  principle](https://amux.io/guides/harness-engineering/) — short; the origin
  of review-ratchet's "don't fix the output, add the check; the harness only
  tightens".
- **Skim** · [Simon Willison: Red/green TDD — Agentic Engineering
  Patterns](https://simonwillison.net/guides/agentic-engineering-patterns/red-green-tdd/) —
  canonical statement of enforced-red-first for agents.
- **Skim** · [InfoQ: Agentic Fitness
  Functions](https://www.infoq.com/articles/agentic-fitness-functions-evolutionary-architecture/) —
  architecture tests extended with rubric-scored agent judges; useful shape
  for judgment-heavy invariants.
- **Skim** · [Anthropic 2026 Agentic Coding Trends Report
  (summary)](https://rits.shanghai.nyu.edu/ai/anthropics-2026-agentic-coding-trends-report-from-assistants-to-agent-teams/) —
  for calibration numbers, not method: AI in ~60% of work, full delegation
  0–20%, ~27% of AI work is previously-deprioritized tasks.

## Loop engineering

- **Must** · [ghuntley: everything is a ralph
  loop](https://ghuntley.com/loop/) — the primitive itself: while-loop +
  one prompt file + fresh context per iteration, filesystem and git as
  memory, one task per loop. Read the mechanics, discount the rhetoric.
- **Ref** · [The Ralph Wiggum loop
  (codecentric)](https://www.codecentric.de/en/knowledge-hub/blog/the-ralph-wiggum-loop-autonomous-code-generation-with-a-fresh-context)
  and [snarktank/ralph](https://github.com/snarktank/ralph) — sober write-up
  and a runnable reference implementation.
- **Skim** · [Loop Engineering vs Prompt
  Engineering](https://www.lyzr.ai/blog/loop-engineering-vs-prompt-engineering/) —
  the one durable sentence: loops fail on the stop condition, not the
  prompting. The verifier inside the loop is the whole game.

## Spec-driven development

- ⚠️ **Ref** · [Spec Kit Agents](https://arxiv.org/html/2604.05278v1),
  [Microsoft: Spec-Driven Development](https://developer.microsoft.com/blog/spec-driven-development-ai-native-engineering/),
  [SDD in 2026 (tooling overview)](https://dev.to/krlz/spec-driven-development-in-2026-what-it-is-the-tooling-and-how-teams-actually-use-it-2fk2) —
  the tooling landscape for specs-as-contracts. The principle is already in
  the skills (numbered testable requirements); read these when choosing
  tooling, not for the idea.
- ⚠️ **Ref** · [TDFlow: Agentic Workflows for
  TDD](https://arxiv.org/pdf/2510.23761) — formalizes test-writer/implementer
  separation with mutation validation.

## Skill-authoring craft (repositories worth reading as code)

- **Must** · [mattpocock/skills](https://github.com/mattpocock/skills) — the
  best public skill-writing craft found to date. Read `.agents/invocation.md`
  (user-invoked skills at zero context cost), `writing-for-agents` (context
  load vs cognitive load, the no-op test, leading words), `diagnosing-bugs`
  (red-capable-command gate), and `code-review` (the two-axis parallel
  sub-agent review this repo's lens dispatch adapts).
- **Skim** · [ML-SystemDesign lossless-doc-compress
  (upstream)](https://github.com/ML-SystemDesign/MLSystemDesign/tree/main/skills/lossless-doc-compress) —
  the source of this repo's port; read if curious what the scorecard and
  ML-specific parts looked like before they were dropped.
- **Ref** · [ayghri/i-have-adhd](https://github.com/ayghri/i-have-adhd) — the
  skill content is niche, but the eval harness (blind rubric, blocker class,
  release gates against a baseline) is the pattern this repo's skills still
  lack.
- **Ref** · [AgentOrientedArchitecture/aoa-course](https://github.com/AgentOrientedArchitecture/aoa-course) —
  course materials; two ideas travel: "trust is observed, not asserted" and
  acceptance signals declared inside an agent's capability card.

## How this list was validated

Sources marked ✅ had their headline numbers re-checked against the primary
page on 2026-08-25. The lens-separation and findings-ledger conclusions were
additionally validated against a private production retrospective (two large
workflow-engine PRs, ~33 reviewer findings classified and traced): the
near-disjoint-lens result reproduced, and about a third of second-pass
findings were re-discoveries of earlier agent findings lost in triage —
the single cheapest class to eliminate.
