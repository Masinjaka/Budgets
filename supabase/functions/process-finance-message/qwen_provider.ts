import { ApiError, providerError } from "./errors.ts";
import {
  asNumber,
  asRecord,
  fetchWithRetry,
  invalidProviderResponse,
  readJson,
  requiredProviderEnv,
} from "./provider_http.ts";
import type { ActiveModel } from "./providers.ts";
import type { ModelMedia, ModelResult } from "./types.ts";
import { validateExtraction } from "./validation.ts";

export async function callQwen(
  active: ActiveModel,
  system: string,
  user: string,
  media: ModelMedia[],
): Promise<ModelResult> {
  if (media.some((item) => item.mimeType === "application/pdf")) {
    throw new ApiError(
      "unsupported_receipt_format",
      "The configured Qwen model cannot read PDF receipts. Scan or import images instead.",
      400,
    );
  }
  const baseUrl = requiredProviderEnv("QWEN_BASE_URL").replace(/\/$/, "");
  const content = media.length === 0
    ? user
    : [
      ...media.map((item) => ({
        type: "image_url",
        image_url: { url: `data:${item.mimeType};base64,${item.base64}` },
      })),
      { type: "text", text: user },
    ];
  const response = await fetchWithRetry(`${baseUrl}/chat/completions`, {
    method: "POST",
    headers: {
      authorization: `Bearer ${requiredProviderEnv("QWEN_API_KEY")}`,
      "content-type": "application/json",
    },
    body: JSON.stringify({
      model: active.model,
      messages: [
        { role: "system", content: `${system}\nReturn valid JSON.` },
        { role: "user", content },
      ],
      response_format: { type: "json_object" },
      enable_thinking: false,
      temperature: 0.1,
      max_completion_tokens: 2048,
    }),
  });
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
  const choices = Array.isArray(raw.choices) ? raw.choices : [];
  const message = asRecord(asRecord(choices[0]).message);
  if (typeof message.content !== "string") throw invalidProviderResponse();
  const usage = asRecord(raw.usage);
  return {
    extraction: validateExtraction(JSON.parse(message.content)),
    raw,
    inputTokens: asNumber(usage.prompt_tokens),
    outputTokens: asNumber(usage.completion_tokens),
    ...active,
  };
}
