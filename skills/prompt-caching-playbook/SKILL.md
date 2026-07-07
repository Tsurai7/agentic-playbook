---
name: prompt-caching-playbook
description: Maximize prompt-cache hit rate and cut token cost on LLM/agentic systems (Anthropic, OpenAI, Gemini, vLLM). Use when designing, auditing, or debugging the prompt/message structure of an LLM system, or when asked about cache hit rate, cache_control, prompt_cache_key, context caching, cache TTL, KV-cache, prefix matching, static-prefix/dynamic-suffix, "why is my LLM bill so high", "почему API LLM дорого", "как уменьшить токены", or reusing prompt prefixes across requests.
---

# Prompt Caching Playbook for Production LLM/Agentic Systems

A practical lens + ordered playbook for structuring prompts and message arrays so the provider can reuse the KV-cache across requests. Get token cost down 5–50× on input and TTFT down 13–85% without touching the model.

This skill covers **Anthropic Claude, OpenAI GPT/o-series, Google Gemini, and self-hosted vLLM**. The structural rules are the same across all four; only syntax differs.

> **Freshness.** The **structural** rules (prefix→suffix ordering, breakpoint placement, anti-patterns) are stable. The **numbers** — pricing, token thresholds, TTLs, model IDs, and the arxiv reference — are point-in-time, captured 2026-05 and **not independently re-verified here**. Treat every specific figure as indicative: verify against the live provider docs in [Sources](#sources) before quoting it to a user. When in doubt, give the structural advice and tell the user to check current pricing/limits.

## How to apply

1. **Diagnose first.** Look at the user's existing prompt structure or system architecture before suggesting changes. Static-vs-dynamic content placement and tool definition stability are the two highest-leverage variables — check those before discussing TTL or breakpoint count.
2. **Apply the universal rule.** Static prefix → dynamic suffix. Order across all providers: tools → system → conversation history → new user message. Anything that changes per request must live **after** the last cache breakpoint.
3. **Name what NOT to do.** The anti-patterns list in §4 below catches ~80% of real production cache misses. Surface them proactively whenever the user describes their prompt structure.
4. **Quantify the win.** Every recommendation should come with an estimated cost/latency saving anchored in real numbers from the worked examples in `references/production-ops.md` or the provider table in §3, so the user can prioritize.
5. **Recommend a monitoring loop.** Cache hit rate must be logged per-request and dashboarded per-session, per-tenant (logging schema and alerts: `references/production-ops.md`). Without observability, regressions are invisible until the next billing cycle.

## TL;DR — the rules that matter

1. **Static prefix → dynamic suffix.** Order: tools → system static → system dynamic → long context / RAG → conversation history → new user message. Cache breakpoint goes after the last *stable* block.
2. **Multi-turn:** previous user and assistant messages stay in place (append-only). New user message appended at the end. Cache breakpoint slides forward each turn.
3. **Tool definitions are part of the cached prefix.** Reorder tools = full cache invalidation. Add/remove an MCP tool mid-session = full invalidation (system + all history).
4. **Min thresholds:** 1024 tokens (Anthropic Sonnet/Opus, OpenAI, some Gemini models), 2048 tokens (Anthropic Haiku, Gemini 2.5), 4096 tokens (newer Gemini models). Below threshold = silent no-cache.
5. **Cache hit pricing:** ~10% of base input (Anthropic, Google) or ~50% (OpenAI). Cache write costs: 1.25× base on Anthropic for 5min TTL, 2× for 1h TTL; OpenAI and Google charge nothing extra for writes.
6. **TTL choice:** 5 min default refreshes on every hit — fine for active sessions. 1 hour (Anthropic) or 24h (OpenAI) for spaced-out workloads (review agents, batch jobs).
7. **Anti-patterns that kill the cache:** timestamps/UUIDs at start of system prompt, live `git status` in every prompt, middleware injecting trace IDs, reordering tools, switching models mid-session, aggressive history reformatting, putting tool *results* inside the cached prefix.

## Decision tree — what to do for the user's stack

```
Is the user designing a new system?
├── YES → §1 (canonical structure) + §3 (provider-specific syntax) + monitoring (references/production-ops.md)
└── NO, debugging existing system:
    ├── "Cache hit rate is low / unstable"
    │   → §4 (anti-patterns checklist) — walk through one by one
    ├── "Bill is too high"
    │   → cost math (references/production-ops.md) → §1 → §4
    ├── "Hit rate was good, now it's not"
    │   → check for recent changes: tools added? middleware deployed? model switched?
    │   → §4 #4, #5, #6, #7
    ├── "Migrating providers"
    │   → §3 (per-provider mechanics) + §2 (multi-turn nuances per provider)
    ├── Multi-tenant SaaS concerns
    │   → §5 (cache isolation)
    └── "What's the right TTL"
        → §3 TTL subsection — depends on inter-request gap
```

For deep mechanics on any specific provider, read `references/anthropic.md`, `references/openai.md`, `references/gemini.md`, or `references/self-hosted.md`. For full benchmark numbers and the academic findings, see `references/benchmarks.md`. For analysis of OSS agents (OpenCode, Aider, Cline, OpenHands, Codex CLI, Claude Code), see `references/oss-agents.md`.

---

## 1. The canonical structure

All major providers use **prefix matching by exact byte equality**. The KV-cache stores attention Key/Value tensors for the prefix; on hit, the model skips re-processing those tokens and resumes forward pass only from the first un-cached byte. Any byte change in the prefix invalidates everything after it.

The mandatory ordering across **Anthropic, OpenAI, Google, and vLLM**:

```
[1] Tool definitions          ← most stable, cached first (part of prefix)
[2] System prompt — static    ← role, style, conventions, AGENTS.md/rules
[3] System prompt — dynamic   ← timestamp, cwd, user_location (END of system!)
[4] Long context / RAG        ← documents, codebase chunks (if reused)
[5] Conversation history      ← user/assistant turns, append-only
[6] New user message          ← always last
```

**Cache breakpoint** (where the provider should stop hashing the prefix and start treating content as variable) goes after the **last stable block**. In Anthropic terms — that's where `cache_control` is placed. In OpenAI/Google — the system decides automatically based on the prefix matcher.

### Canonical system prompt template

```text
# === BLOCK A: ROLE (stable forever) ===
You are an expert software engineering agent. Your role is...
[2000–4000 tokens of stable instructions]

# === BLOCK B: TOOL USAGE GUIDELINES (stable per agent version) ===
When calling tools, you must...
[1000–3000 tokens]

# === BLOCK C: PROJECT CONVENTIONS (AGENTS.md / .cursorrules / etc.) ===
[variable per project but stable within a project]

# === BLOCK D: STYLE / OUTPUT FORMAT ===
[stable]

# === [CACHE BREAKPOINT HERE] ===

# === BLOCK E: DYNAMIC ENVIRONMENT (after breakpoint, NOT cached) ===
<env>
date: 2026-05-14T10:30:00Z
cwd: /home/user/projects/foo
git_branch: feature/auth-v2
</env>
```

---

## 2. Multi-turn behavior — how the breakpoint moves

The most common confusion: "do I keep the previous user message in the array?" Yes — the previous user and assistant messages stay in place. Append-only.

Per-turn shape:

```
Turn 1: [tools] [system] [user_1]
Turn 2: [tools] [system] [user_1] [assistant_1] [user_2]
Turn 3: [tools] [system] [user_1] [assistant_1] [user_2] [assistant_2] [user_3]
```

The cache breakpoint **slides forward** each turn:
- Turn 2: prefix `[tools][system][user_1][assistant_1]` is cached (3 of 4 blocks reused from turn 1).
- Turn 3: prefix `[tools][system][user_1][assistant_1][user_2][assistant_2]` is cached.

**Provider mechanics:**
- **Anthropic** — top-level `cache_control: {"type":"ephemeral"}` automatically applies the breakpoint to the last cacheable block and advances it. Or place explicit `cache_control` on the last user message manually (up to 4 breakpoints).
- **OpenAI** — fully automatic, no markers. The provider hashes the prefix on every request and routes to a machine that has it cached.
- **Google Gemini** — implicit caching is automatic. Explicit Context Caching API is incompatible with tool use in the same request (limitation as of early 2026).

### Compaction / history truncation

When context grows past the limit, agents must compact. **Compaction is the #1 cache-killer in long sessions** because the summarized prefix breaks byte equality.

Two strategies:
1. **Make the summary itself stable.** Compact once, then the summarized prefix becomes the new stable prefix. Subsequent turns build on top of it. Hit rate recovers after one cold turn.
2. **Pruning, not summarizing.** Drop oldest tool outputs while keeping the message structure intact. Some agents (OpenHands, OpenCode) protect the most recent N tokens and mark older tool outputs as "compacted" without rewriting them.

---

## 3. Provider-specific mechanics

Compressed cheat sheet. For full mechanics, read the relevant reference file.

> Thresholds, costs, TTLs, and model IDs below are point-in-time (2026-05) — confirm against live docs before quoting (see the Freshness note at the top).

| | **Anthropic** | **OpenAI** | **Google Gemini** | **Self-hosted (vLLM)** |
|---|---|---|---|---|
| Activation | Explicit `cache_control` or top-level auto | Automatic | Implicit auto + explicit Context Caching API | `--enable-prefix-caching` (on by default v0.5+) |
| Min prefix | 1024 (Sonnet/Opus); 2048+ (Haiku, newer Opus/Haiku) | 1024, then +128 increments | 1024–4096 depending on model | None (any prefix) |
| Cache hit cost | 0.1× base | ~0.5× (some models ~0.25×) | ~0.1× on newer Flash/Pro families | Free (your GPU) |
| Cache write cost | 1.25× (5min) / 2× (1h) | Free | Free for implicit; storage fee for explicit | Free |
| TTL | 5min (default) or 1h (Opus 4.5+, Sonnet 4.5+, Haiku 4.5+) | ~5–10 min or 24h via `prompt_cache_retention` | 5min implicit / configurable explicit (default 60min) | LRU eviction by GPU memory |
| Multi-tenant key | Workspace (Bedrock/Foundry) or org-level | `prompt_cache_key` parameter | Auto by content hash | `cache_salt` parameter |
| Response field | `cache_read_input_tokens`, `cache_creation_input_tokens` | `prompt_tokens_details.cached_tokens` | `usage_metadata.cached_content_token_count` | varies |
| Max breakpoints | 4 explicit | N/A (auto) | N/A (auto) | N/A |
| Hierarchy | Tools → System → Messages (changing higher invalidates lower) | Same effective behavior | Same | Same |

### TTL decision guide

- **Active conversational agent (>1 req per 5min):** default 5min on Anthropic, default in-memory on OpenAI. The TTL refreshes on every hit.
- **Code review agent / sporadic queries (every 5–60min):** Anthropic 1h, OpenAI 24h.
- **Batch eval / nightly jobs:** Anthropic 1h, OpenAI 24h. The 2× write multiplier on Anthropic is recouped after ~3 reads.
- **RAG over stable docs:** Anthropic 1h for the document context, 5min for conversation history (mix is allowed — 1h must come *before* 5min in the request).

For deep provider-specific details (4-breakpoint placement on Anthropic, `prompt_cache_key` granularity on OpenAI, Context Caching API on Google, vLLM prefix caching tuning), see the reference files.

---

## 4. Anti-patterns checklist (the cache-killers)

Walk through this list when debugging low hit rate.

| # | Anti-pattern | Effect |
|---|---|---|
| 1 | Timestamp / current date in **start** of system prompt | 0% hit rate; every request is full reprocess |
| 2 | Session ID / request UUID anywhere in system | Same |
| 3 | Live `git status` / file listing in every prompt | Cache invalidates on every file edit |
| 4 | Middleware injecting trace ID / analytics token into system | Invisible mutator — hardest to find |
| 5 | Reorder of tool definitions between requests | Full invalidation of tools+system+messages |
| 6 | Adding/removing a tool mid-session (MCP, plugin) | Same |
| 7 | Switching model mid-session | Cache is per-model — cold start on new |
| 8 | Aggressive summarization/compaction every N turns | Each rewrite breaks byte equality |
| 9 | Reformatting history (case, whitespace, JSON re-serialization) | Two-letter change = thousands of tokens missed (empirically) |
| 10 | Streaming response with no usage telemetry | You lose visibility into cache stats |
| 11 | Anthropic routed through OpenRouter without sticky routing | Hit rate stays flat regardless of session length |
| 12 | Tool *results* placed inside the cached prefix | Dynamic content invalidates the prefix |
| 13 | Mixing explicit Context Cache with tool use on Google models | Documented API incompatibility |
| 14 | OpenAI: too-narrow `prompt_cache_key` (RPM per key < ~15) | Overflow routes to cold machines |
| 15 | `cache_control` breakpoint placed on a block that *changes* | Pay for write every time, never read |

The most expensive failure mode in practice is **#4 (middleware)**. Observability layers (Sentry, LangSmith, Helicone, custom analytics) often inject trace IDs into the system prompt. They work "correctly" and silently cost 10× more on input — discovered only when looking at the next bill.

---

## 5. Multi-tenant cache isolation

**Cross-tenant data leakage via cache is not a real risk** on any of the three major providers. Cache hashes exact content; a different tenant's prefix won't match. You do **not** need to add per-tenant salt to the prefix — that would kill the global cross-tenant cache and lose all the savings.

What you *might* need depending on compliance:

- **Anthropic** — cache entries isolated between organizations and between workspaces (on Bedrock and Microsoft Foundry). Direct Anthropic API: org-level only.
- **OpenAI** — granulate `prompt_cache_key` per tenant segment, not per user. Aim for >10 RPM per key. Per-user keys with low traffic suffer from overflow.
- **Google** — implicit caching is content-hashed and per-project. No per-tenant config needed.
- **Self-hosted vLLM** — use `cache_salt` parameter to isolate per-tenant on shared GPU.

ZDR (zero data retention) compatibility: all three major providers state cache lives in RAM/VRAM only, not written to disk, with short TTL. Anthropic's docs explicitly note "raw text of prompts is not stored — only KV representations and cryptographic hashes in memory."

---

## Reference files

For deeper mechanics on specific topics, load the corresponding file from `references/`:

- `references/production-ops.md` — monitoring: logging schema, dashboard panels, alert thresholds; cost-math worked examples; production code templates (Anthropic/OpenAI/Google); the 14-point audit checklist for existing systems.
- `references/anthropic.md` — full Anthropic mechanics: 4-breakpoint placement, automatic vs explicit modes, 1h vs 5min TTL break-even math, hierarchy of invalidation, response usage parsing, Bedrock/Vertex caveats.
- `references/openai.md` — `prompt_cache_key` routing, 15 RPM rule, `prompt_cache_retention`, what's cached (messages, images, tools, structured output schema).
- `references/gemini.md` — implicit vs explicit Context Caching API, known incompatibility with tools, min thresholds per model family, storage billing.
- `references/self-hosted.md` — vLLM prefix caching tuning, `cache_salt`, SGLang, TGI.
- `references/oss-agents.md` — reverse-engineered cache strategies of OpenCode (the reference implementation), Aider, Cline/Roo Code, Continue, OpenHands, OpenAI Codex CLI, and what's known about Claude Code and Cursor.
- `references/benchmarks.md` — production hit-rate numbers from various agents, the *Don't Break the Cache* arxiv paper findings (41–80% cost savings, 13–31% TTFT improvement), and the methodology behind them.

## Sources

Official:
- Anthropic Prompt Caching docs (`platform.claude.com/docs/en/build-with-claude/prompt-caching`).
- Anthropic blog "Prompt caching with Claude" (Dec 2024).
- Google Vertex AI Context Caching docs.
- Google AI Studio docs (`ai.google.dev/gemini-api/docs/caching`).
- OpenAI Prompt Caching guide + Cookbook "Prompt Caching 101 / 201".
- Azure OpenAI Foundry docs — `prompt_cache_retention`.

Academic:
- Lumer et al., *Don't Break the Cache: An Evaluation of Prompt Caching for Long-Horizon Agentic Tasks*, arxiv 2601.06007 (v2, Jan 2026) — 41–80% cost, 13–31% TTFT.

Production analysis:
- Anthropic engineering threads on Claude Code (cache hit rate ~92% in production, SEV-level alerting).
- LMCache blog (Dec 2025) — trace analysis of Claude Code.
- Claude Code Camp empirical experiments (Feb 2026) — two-letter change breaking cache.
- Veritas Supera analysis — 99.5% hit rate on 61-hour long session.

Open-source code:
- sst/opencode `packages/opencode/src/provider/transform.ts` (`applyCaching()`) — reference 2-system + last-2-message caching for Anthropic.
- aider-AI/aider `--cache-prompts` flag.
- cline/cline RFC discussions (#9892, #5092).
- OpenHands `codeact_agent.py` + Issue #6858.
- openai/codex (Rust) — Responses API caching.
