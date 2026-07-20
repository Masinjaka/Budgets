import { ApiError, providerError } from "./errors.ts";
import { extractionSchema, type ModelResult } from "./types.ts";
import { validateExtraction } from "./validation.ts";

export async function callModel(
  system: string,
  user: string,
): Promise<ModelResult> {
  const provider = (Deno.env.get("AI_PROVIDER") ?? "gemini").toLowerCase();
  if (provider === "gemini") return callGemini(system, user);
  if (provider === "qwen") return callQwen(system, user);
  throw new ApiError(
    "provider_not_configured",
    `Unsupported AI provider: ${provider}`,
    503,
  );
}

export function activeModel(): {
  provider: string;
  model: string;
  billingTier: string;
} {
  const provider = (Deno.env.get("AI_PROVIDER") ?? "gemini").toLowerCase();
  if (provider === "qwen") {
    return {
      provider,
      model: Deno.env.get("QWEN_MODEL") ?? "qwen-flash",
      billingTier: Deno.env.get("QWEN_BILLING_TIER") ?? "unknown",
    };
  }
  return {
    provider: "gemini",
    model: Deno.env.get("GEMINI_MODEL") ?? "gemini-2.5-flash-lite",
    billingTier: Deno.env.get("GEMINI_BILLING_TIER") ?? "unknown",
  };
}

async function callGemini(
  system: string,
  user: string,
): Promise<ModelResult> {
  const { provider, model, billingTier } = activeModel();
  const apiKey = requiredEnv("GEMINI_API_KEY");
  const response = await fetchWithRetry(
    `https://generativelanguage.googleapis.com/v1beta/models/${
      encodeURIComponent(model)
    }:generateContent`,
    {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-goog-api-key": apiKey,
      },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: system }] },
        contents: [{ role: "user", parts: [{ text: user }] }],
        generationConfig: {
          temperature: 0.1,
          maxOutputTokens: 2048,
          responseMimeType: "application/json",
          responseJsonSchema: extractionSchema,
        },
      }),
    },
  );
  const raw = await readJson(response);
  if (!response.ok) {
    throw providerError(provider, model, billingTier, response.status, raw);
  }
  const text = geminiText(raw);
  const usage = asRecord(raw.usageMetadata);
  return {
    extraction: validateExtraction(JSON.parse(text)),
    raw,
    inputTokens: asNumber(usage.promptTokenCount),
    outputTokens: asNumber(usage.candidatesTokenCount),
    provider,
    model,
    billingTier,
  };
}

async function callQwen(
  system: string,
  user: string,
): Promise<ModelResult> {
  const { provider, model, billingTier } = activeModel();
  const apiKey = requiredEnv("QWEN_API_KEY");
  const configuredUrl = requiredEnv("QWEN_BASE_URL");
  const baseUrl = configuredUrl.endsWith("/")
    ? configuredUrl.slice(0, -1)
    : configuredUrl;
  const response = await fetchWithRetry(`${baseUrl}/chat/completions`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${apiKey}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model,
      messages: [
        { role: "system", content: `${system}\nReturn valid JSON.` },
        { role: "user", content: user },
      ],
      response_format: { type: "json_object" },
      enable_thinking: false,
      temperature: 0.1,
      max_completion_tokens: 2048,
    }),
  });
  const raw = await readJson(response);
  if (!response.ok) {
    throw providerError(provider, model, billingTier, response.status, raw);
  }
  const choices = Array.isArray(raw.choices) ? raw.choices : [];
  const first = asRecord(choices[0]);
  const message = asRecord(first.message);
  if (typeof message.content !== "string") throw invalidProviderResponse();
  const usage = asRecord(raw.usage);
  return {
    extraction: validateExtraction(JSON.parse(message.content)),
    raw,
    inputTokens: asNumber(usage.prompt_tokens),
    outputTokens: asNumber(usage.completion_tokens),
    provider,
    model,
    billingTier,
  };
}

async function fetchWithRetry(
  url: string,
  init: RequestInit,
): Promise<Response> {
  let response = await fetch(url, init);
  if (response.status >= 500) {
    await new Promise((resolve) => setTimeout(resolve, 250));
    response = await fetch(url, init);
  }
  return response;
}

async function readJson(response: Response): Promise<Record<string, unknown>> {
  const text = await response.text();
  try {
    return asRecord(JSON.parse(text));
  } catch (_) {
    return { raw_error: text.slice(0, 1000) };
  }
}

function geminiText(raw: Record<string, unknown>): string {
  const candidates = Array.isArray(raw.candidates) ? raw.candidates : [];
  const candidate = asRecord(candidates[0]);
  const content = asRecord(candidate.content);
  const parts = Array.isArray(content.parts) ? content.parts : [];
  const part = asRecord(parts[0]);
  if (typeof part.text !== "string") throw invalidProviderResponse();
  return part.text;
}

function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new ApiError(
      "provider_not_configured",
      `${name} is not configured on the Edge Function.`,
      503,
    );
  }
  return value;
}

function asRecord(value: unknown): Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {};
}

function asNumber(value: unknown): number | undefined {
  return typeof value === "number" ? value : undefined;
}

function invalidProviderResponse(): ApiError {
  return new ApiError(
    "invalid_model_response",
    "The AI provider returned an unreadable response.",
    502,
  );
}
