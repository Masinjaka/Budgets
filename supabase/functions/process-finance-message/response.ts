import { ApiError, ProviderError } from "./errors.ts";

export const corsHeaders = {
  "access-control-allow-origin": "*",
  "access-control-allow-headers": "authorization, apikey, content-type",
};

export function quotaError(value: Record<string, unknown>): ApiError {
  if (value.code === "daily_limit_exceeded") {
    return new ApiError(
      "daily_limit_exceeded",
      "You have used all 20 AI requests for today. Try again tomorrow.",
      429,
      { remaining: 0 },
    );
  }
  const retry = typeof value.retry_after_seconds === "number"
    ? value.retry_after_seconds
    : 3;
  return new ApiError(
    "rate_limited",
    `Please wait ${retry} seconds before trying again.`,
    429,
    { retry_after_seconds: retry },
  );
}

export function normalizeError(value: unknown): ApiError {
  if (value instanceof ApiError) return value;
  if (value instanceof SyntaxError) {
    return new ApiError(
      "invalid_model_response",
      "The AI returned invalid JSON. Please try again.",
      502,
    );
  }
  return new ApiError(
    "internal_error",
    "Something went wrong while processing the message.",
    500,
  );
}

export function errorResponse(error: ApiError): Response {
  const provider = error instanceof ProviderError
    ? {
      provider: error.provider,
      name: error.model,
      billing_tier: error.billingTier,
    }
    : null;
  return jsonResponse(
    {
      error: {
        code: error.code,
        message: error.message,
        model: provider,
        details: error.details ?? null,
      },
    },
    error.status,
  );
}

export function jsonResponse(value: unknown, status = 200): Response {
  return new Response(JSON.stringify(value), {
    status,
    headers: { ...corsHeaders, "content-type": "application/json" },
  });
}

export function requiredEnv(name: string): string {
  const value = Deno.env.get(name);
  if (!value) {
    throw new ApiError(
      "server_not_configured",
      `${name} is not configured on the Edge Function.`,
      503,
    );
  }
  return value;
}
