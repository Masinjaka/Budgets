import { providerError } from "./errors.ts";
import {
  asNumber,
  asRecord,
  fetchWithRetry,
  invalidProviderResponse,
  readJson,
  requiredProviderEnv,
} from "./provider_http.ts";
import type { ActiveModel } from "./providers.ts";
import { extractionSchema, type ModelMedia, type ModelResult } from "./types.ts";
import { validateExtraction } from "./validation.ts";

export async function callGemini(
  active: ActiveModel,
  system: string,
  user: string,
  media: ModelMedia[],
): Promise<ModelResult> {
  const apiKey = requiredProviderEnv("GEMINI_API_KEY");
  const parts = [
    ...media.map((item) => ({
      inlineData: { mimeType: item.mimeType, data: item.base64 },
    })),
    { text: user },
  ];
  const response = await fetchWithRetry(
    `https://generativelanguage.googleapis.com/v1beta/models/${
      encodeURIComponent(active.model)
    }:generateContent`,
    {
      method: "POST",
      headers: {
        "content-type": "application/json",
        "x-goog-api-key": apiKey,
      },
      body: JSON.stringify({
        systemInstruction: { parts: [{ text: system }] },
        contents: [{ role: "user", parts }],
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
    throw providerError(
      active.provider,
      active.model,
      active.billingTier,
      response.status,
      raw,
    );
  }
  const usage = asRecord(raw.usageMetadata);
  return {
    extraction: validateExtraction(JSON.parse(geminiText(raw))),
    raw,
    inputTokens: asNumber(usage.promptTokenCount),
    outputTokens: asNumber(usage.candidatesTokenCount),
    ...active,
  };
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
