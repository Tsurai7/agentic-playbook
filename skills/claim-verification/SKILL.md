---
name: claim-verification
description: >-
  Extract every checkable claim from a PR description, code comment, doc, or
  review reply and verify each against the actual tree before trusting or
  publishing it. Use when reviewing someone else's PR, when writing your own
  PR description or review replies, or when acting on assurances found in docs
  or comments ("a test locks this", "matches production"). Skip for claims
  whose verification you watched in this session.
---

# Claim verification

Prose is not evidence. Text that asserts something about the tree — written by
you, another agent, or a human — is a list of checks to run, not context to
absorb.

## Method

1. **Extract** the claims from the artifact. Checkable shapes:
   - existence — "file/test/CI target X exists", "Y is covered in CI"
   - protection — "a test locks/guards Z": verify the test exists **and**
     fails when Z is broken (reintroduce the bug or mutate)
   - equivalence — "matches sibling/production/spec", "byte-identical"
   - counts and numbers — "N cases", "exact match", "zero deletions"
   - references — every path named in Makefiles, CI, and docs resolves in the
     tree
2. **Verify** each with a command or a read; record claim → check → verdict.
3. **Report** what cannot be verified as unverified — never restate it as
   fact.
4. **Re-verify after the tree moves.** A force-push, revert, or dropped commit
   invalidates every previously posted claim whose evidence lived in it;
   re-check before a human reads the text, and correct promptly if it went
   stale.

Complements `verification-before-completion`: that skill gates your own
*completion* claims at the end of work; this one audits *written artifacts* —
including ones you authored earlier.

## Provenance

Two real internal incidents (2026-08) that survived multi-model review and
fall to a single existence check: a code comment claiming "a unit test locks
it" with no such test in the tree, and a Makefile target referencing files
that existed on no branch.
