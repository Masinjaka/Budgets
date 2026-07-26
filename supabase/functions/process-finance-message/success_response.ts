import type { ModelResult } from "./types.ts";
import { jsonResponse } from "./response.ts";

export function financeSuccessResponse(
  committed: Record<string, unknown>,
  modelResult: ModelResult,
  reservation: Record<string, unknown>,
): Response {
  return jsonResponse({
    entries: committed.entries ?? [],
    wallets: committed.wallets,
    total_funds: committed.total_funds,
    message: modelResult.extraction.message,
    remaining: reservation.remaining,
    plan: reservation.plan ?? "free",
    unlimited: reservation.unlimited ?? false,
    model: {
      provider: modelResult.provider,
      name: modelResult.model,
      billing_tier: modelResult.billingTier,
    },
    notice: modelResult.billingTier === "paid"
      ? "This request used a paid AI provider tier."
      : null,
  });
}
