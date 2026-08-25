---
name: test-adequacy-review
description: >-
  Judge whether the tests in a diff can actually catch what they claim to
  guard: can each test fail for its named reason, are all trigger paths
  exercised, are barriers observable rather than sleeps, do fixtures share
  contracts with production. Use when asked whether tests are adequate/any
  good, or as the test lens of a multi-lens review. Skip for writing new
  tests (that is implementation work) and for reviewing non-test code.
---

# Test adequacy review

A green suite proves nothing about the assertions that cannot fire. This lens
judges the tests; it does not write them — but every finding names the missing
or corrected test concretely.

## Method

1. **Name vs power.** For each test: state the reason it exists (its name and
   comments claim one), then describe the concrete code change that should
   make it fail. If no such change exists — because the guarded path is not
   reachable from the test's setup, or the assertion holds vacuously — that is
   the top finding class: a test that cannot fail for its named reason.
   (Mutation thought-experiment; run a real mutation when cheap.)
2. **Trigger surface.** Enumerate every path that can reach the guarded
   behavior (all call sites, all gateway branches, all event orders). Which
   does the suite exercise? An untested trigger on a money or safety path is
   a finding even when the tested trigger is identical-looking code.
3. **Barriers and time.** Every wait must be tied to an observable signal.
   `sleep(N)` as a synchronization barrier, assertions racing a timer, and
   "must finish before X fires" enforced by nothing are findings — they pass
   on fast machines and lie on slow ones.
4. **Fixture honesty.** A test helper that hand-duplicates a production
   payload, contract, or constant will drift green: the test keeps passing
   while production moves. Shared structs/constants between test and prod are
   the fix; duplication is the finding.
5. **Isolation and ordering.** Global resets (shared stub state, scenario
   resets) that couple suites, and tests correct only under sequential
   execution, are findings with a deferred fuse.

Evidence rule: quote the test lines that make each finding true; name the
concrete input, timing, or mutation that demonstrates it.

## Rules

- Run in a fresh context with only the diff and the test files — not the
  author's reasoning, not other lenses' output.
- Never rerank against other lenses; adequacy of tests and correctness of
  code are separate verdicts.
- Findings go to the findings-ledger.

## Provenance

Every finding class above shipped past multi-model review at least once in an
internal retrospective (2026-08): a feature-off test that could not fail for
its named reason, a second trigger branch exercised by zero tests, a
3-second sleep as a barrier, tests racing a short fallback timer, and a
helper duplicating the server's start payload. Meta's mutation-guided test generation (FSE 2025)
grounds the mutation discipline.
