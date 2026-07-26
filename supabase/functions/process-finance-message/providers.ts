import { ApiError } from "./errors.ts";
import { callGemini } from "./gemini_provider.ts";
import { callQwen } from "./qwen_provider.ts";
import type { ModelMedia, ModelResult } from "./types.ts";

export async function callModel(
  system: string,
  user: string,
  media: ModelMedia[] = [],
): Promise<ModelResult> {
  const model = activeModel();
  if (model.provider === "gemini") return callGemini(model, system, user, media);
  if (model.provider === "qwen") return callQwen(model, system, user, media);
  throw new ApiError(
    "provider_not_configured",
    `Unsupported AI provider: ${model.provider}`,
    503,
  );
}

export type ActiveModel = {
  provider: string;
  model: string;
  billingTier: string;
};

export function activeModel(): ActiveModel {
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
