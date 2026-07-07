# Production operations: monitoring, cost math, code templates, audit

Moved out of SKILL.md — load this file when the user needs the logging schema,
dollar-figure examples, copy-paste client code, or a systematic audit of an
existing stack.

> **Freshness.** Dollar figures, thresholds, and model IDs are point-in-time
> (2026-05) and not independently re-verified — see the Freshness note in
> SKILL.md. Recompute with current per-model pricing before quoting.

## Monitoring — what to log

Every LLM call should log:

```python
log_entry = {
    "request_id": uuid,
    "session_id": session.id,
    "tenant_id": tenant.id,
    "model": model_name,
    "provider": provider_name,
    # Token accounting (parse from provider's usage object)
    "input_tokens_new": ...,         # cache miss portion
    "cache_read_tokens": ...,
    "cache_write_tokens": ...,       # 0 on OpenAI/Google implicit
    "output_tokens": ...,
    # Derived
    "hit_rate": cache_read / max(1, cache_read + cache_write + new_input),
    "cost_usd": calculate_cost(...),
    # Latency
    "ttft_ms": ...,
    "total_latency_ms": ...,
    # Diagnostics (catch silent prefix mutations)
    "system_prompt_hash": sha256(system_prompt)[:12],
    "tools_hash": sha256(tools_json)[:12],
    "first_256_token_hash": ...,     # detect prefix drift
}
```

Dashboard panels that matter:
1. **Hit rate over time per session.** Should rise to 80%+ after turn 2–3. If it falls within a session, something is mutating the prefix mid-conversation.
2. **Hit rate per tenant/segment.** Outliers reveal poorly-structured per-tenant prefixes.
3. **Unique `system_prompt_hash` count per day.** If you logically have "v1" but see 50 distinct hashes, an invisible mutator (analytics injector, trace ID middleware, plugin) is corrupting the prefix.
4. **Cost split: new input / cache read / cache write / output.** Ratio of write to read should drop fast in active sessions.

Alert thresholds:
- Hit rate < 70% sustained for >5min on an agentic workload → investigate.
- `cached_tokens` field is 0 for >10 consecutive requests on a long-prefix workload → check for prefix mutation or known provider bugs (Gemini-with-tools edge cases, OpenRouter sticky-routing issues).

---

## Cost math — worked examples

> Dollar figures use illustrative 2026-05 rates to show the *shape* of the savings, not a quote. Always recompute with current per-model pricing.

### Example A: 10K-token system prompt, 1M requests/month, Claude Sonnet-class model
Base input $3/M, cache write 5min $3.75/M, cache read $0.30/M.

| Scenario | Hit rate | Monthly input cost |
|---|---|---|
| No caching | 0% | **$30,000** |
| Naive caching (bad structure) | 30% | ~$8,775 |
| Good structure | 80% | ~$990 |
| Best-practice multi-breakpoint | 92% | ~$576 |

**52× difference between "no cache" and "92% hit rate."** Output cost unchanged.

### Example B: 50-turn agent session, 20K system prompt
- No caching: ~$3.50–4.50/session
- Caching system only: ~$0.50–0.70/session
- Multi-breakpoint sliding: ~$0.19/session

10K sessions/day → $35K/mo vs $5K/mo vs $1.9K/mo input.

### Example C: Cheap-tier model (e.g., Flash-class), 10K system, 1M req/mo
Base $0.50/M, cache hit $0.05/M (90% off).

| Hit rate | Monthly cost |
|---|---|
| 0% | $5,000 |
| 80% | $1,400 |

For high-volume workloads, the cheap-tier + good caching combo lands input cost at ~$1.5K/month per million requests. Output billed separately.

---

## Production code templates

### Anthropic-style (explicit cache_control)

```python
import anthropic
client = anthropic.Anthropic()

STATIC_SYSTEM = open("prompts/system.md").read()
TOOLS = load_tool_definitions()  # stable order, frozen per release

def call_agent(history, new_user_msg, dynamic_env):
    # Mark last tool to cache the whole tools array
    tools = TOOLS.copy()
    tools[-1] = {**tools[-1], "cache_control": {"type": "ephemeral"}}

    # System: static cached, dynamic appended without cache_control
    system = [
        {"type": "text", "text": STATIC_SYSTEM,
         "cache_control": {"type": "ephemeral", "ttl": "1h"}},
        {"type": "text",
         "text": f"<env>\ndate: {dynamic_env['date']}\ncwd: {dynamic_env['cwd']}\n</env>"},
    ]

    # Messages: history + new user with sliding breakpoint
    messages = history + [{
        "role": "user",
        "content": [{
            "type": "text", "text": new_user_msg,
            "cache_control": {"type": "ephemeral"},  # sliding BP
        }],
    }]

    response = client.messages.create(
        model="claude-sonnet-4-6",
        max_tokens=4096,
        tools=tools, system=system, messages=messages,
    )

    u = response.usage
    hit_rate = u.cache_read_input_tokens / max(
        1, u.cache_read_input_tokens + u.cache_creation_input_tokens + u.input_tokens
    )
    return response, hit_rate
```

### OpenAI-style (automatic + cache key)

```python
from openai import OpenAI
client = OpenAI()

def call_agent(segment: str, messages: list):
    response = client.chat.completions.create(
        model="gpt-4o",
        messages=messages,
        # Granulate per segment, not per user — keep RPM/key above ~15
        prompt_cache_key=f"agent-prod-v1-{segment}",
    )
    cached = response.usage.prompt_tokens_details.cached_tokens or 0
    total = response.usage.prompt_tokens
    return response, cached / total
```

### Google-style (implicit, with tools — watch for known caveats)

```python
# Pseudocode — actual SDK varies; the structural rule is what matters.
def call_with_implicit(system: str, history: list, new_msg: str, tools=None):
    """For agents with tools: implicit caching only. Some provider+model
    combinations have known issues activating implicit cache when tools
    are present — monitor cached_content_token_count in production."""
    response = generate_content(
        model=MODEL,
        system_instruction=system,            # stable, at start
        contents=history + [new_msg],
        tools=tools or [],
        # Ensure system + history >= model's min threshold (1024–4096 tokens)
    )
    cached = response.usage_metadata.cached_content_token_count or 0
    return response, cached
```

---

## Audit checklist for existing systems

Walk through this when reviewing a user's existing agent/LLM stack:

1. [ ] Every LLM call logs `cache_read`, `cache_write`, `new_input` token counts.
2. [ ] System prompt is hashed on send — metric "unique system_prompt_hash per day" exists.
3. [ ] Tool definitions: one shared list, fixed order, versioned with the release.
4. [ ] Timestamp / date / cwd / random_id are **out of the start** of system prompt.
5. [ ] Conversation history is append-only — never reformatted between turns.
6. [ ] Compaction triggers only on overflow, and the summarized prefix is itself stable across subsequent turns.
7. [ ] Model is **not switched** mid-session.
8. [ ] Anthropic: `cache_control` present on at least one block (or top-level auto).
9. [ ] OpenAI: `prompt_cache_key` set, granular enough but >10 RPM/key.
10. [ ] Google: `cached_content_token_count > 0` verified in production traces (especially with tools).
11. [ ] Dashboard shows hit rate per session, p50/p95 TTFT, cost split.
12. [ ] Alert configured for hit_rate < threshold (e.g., 70% for agents).
13. [ ] Middleware/plugins audited for injection into system prompt.
14. [ ] If using LiteLLM/OpenRouter/proxy — sticky routing verified, otherwise prefer direct provider for cache-heavy workloads.
