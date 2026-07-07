# Coding principles

Always follow when writing code:

1. **Minimize scope** — Simplest correct diff. No unrelated changes, especially for question-only or review-only tasks. Remove only what your change orphaned. Test: every changed line traces to the request.
2. **Avoid over-engineering** — No one-line helpers that should be inline. No error handling for states the types or callers already exclude. Test: would a senior engineer call this overcomplicated? If yes, simplify.
3. **Use existing conventions** — Match naming, types, abstractions, imports, documentation level. Reuse and extend rather than reimplement.
4. **Comments** — Code should be self-explanatory. Comments only for non-obvious business logic or deep technical details.
5. **Useful tests only** — Add tests when requested or when they cover real behavior that could break. Never a test that asserts a constant, a mock, or the framework itself.
