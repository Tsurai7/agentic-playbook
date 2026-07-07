# Delegation protocol (for installed subagent roles)

Applies when the config ships pinned subagent roles (e.g. rendered to
`~/.claude/agents/`). Each role carries a pinned tier and a body with the scope
guard, AC discipline, status protocol, and environment notes — so a delegation
prompt only needs the task. The Thinker → Worker → Verifier division of labor
this mechanizes is the same role taxonomy Sakana's Fugu / TRINITY router routes
over per turn (a learned policy emits a role *and* a model each step).

| Role | Tier | Hand it |
|------|------|---------|
| `implementer` | mid | a plan file with hard AC (code changes) |
| `doc-writer` | cheap | an explicit item list (mechanical docs) |
| `verifier` | mid | an AC list + gate commands (read-only check) |
| `researcher` | mid + web | a question or doc to refresh, citations required |

These delegation mechanics were proven out in two live multi-agent delegation
waves (June–July 2026):

1. **Plan files, not chat specs.** Each delegation gets a written plan with hard
   acceptance criteria and an explicit file scope; plans in the same wave never
   share files, so agents can run in parallel without conflicts.
2. **AC is the definition of done.** An agent that cannot meet an AC stops and
   reports the blocker; it does not improvise around it.
3. **Verify per wave.** The orchestrator (or the `verifier` role) runs the repo
   gates after each wave, before the next starts.
4. **Expect deaths.** Agents die mid-run (API errors); relaunch with a precise
   done/remaining map derived from the working tree, not from memory.
5. **Diff-check cheap-tier claims.** Reports from the cheap tier get compared
   against the actual diff before acceptance — measured failure mode: overstated
   docs claims.
6. **Statuses are structured.** `DONE | DONE_WITH_CONCERNS | BLOCKED |
   NEEDS_CONTEXT`, with per-AC evidence, so the orchestrator parses instead of
   re-reading transcripts.

Claims discipline: the roles mechanize delegation; any token-savings number is a
hypothesis until a side-by-side measurement lands.
