# AI finance entry setup

The Flutter application never receives an AI provider key. It invokes the
authenticated Supabase Edge Function `process-finance-message`, which reads
provider credentials from Supabase Edge Function secrets.

## Gemini

Add these secrets in **Supabase Dashboard → Edge Functions → Secrets**:

```text
AI_PROVIDER=gemini
GEMINI_API_KEY=<Google AI Studio key>
GEMINI_MODEL=gemini-2.5-flash-lite
GEMINI_BILLING_TIER=free
```

Set `GEMINI_BILLING_TIER=paid` if billing is enabled. This explicit setting is
used for the user-facing paid-tier notice because provider responses do not
reliably report the account billing tier.

## Qwen

Switch providers without changing or rebuilding Flutter:

```text
AI_PROVIDER=qwen
QWEN_API_KEY=<Qwen API key>
QWEN_BASE_URL=https://dashscope-intl.aliyuncs.com/compatible-mode/v1
QWEN_MODEL=qwen-flash
QWEN_BILLING_TIER=free
```

Use the base URL for the Alibaba Cloud region where the API key was created.

## Controls

- Supabase JWT verification and an additional user-token check are required.
- `reserve_ai_request` atomically enforces 20 attempts per UTC day and a
  three-second minimum interval per user.
- Prompt length is capped at 1,000 characters and each response at 10 entries.
- Requests, assistant responses, errors, model, token counts, and generated
  transactions are stored per user.
- RLS lets users read only their own AI history. Mutation RPCs are granted only
  to `service_role`.
- Provider quota, billing, key, and model errors are mapped to distinct messages
  shown through the app toast.

## Retrieval strategy

The function sends the user's exact category list, the small preset catalog,
and the six most recent messages to the model. This deterministic retrieval is
faster and cheaper than vector search for the current bounded, structured data.
`pgvector` should be added only when unstructured financial knowledge or a much
larger category corpus needs semantic retrieval.
