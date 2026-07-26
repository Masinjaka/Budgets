export class ApiError extends Error {
  readonly code: string;
  readonly status: number;
  readonly details?: Record<string, unknown>;

  constructor(
    code: string,
    message: string,
    status = 500,
    details?: Record<string, unknown>,
  ) {
    super(message);
    this.code = code;
    this.status = status;
    this.details = details;
  }
}

export class ProviderError extends ApiError {
  readonly provider: string;
  readonly model: string;
  readonly billingTier: string;

  constructor(
    code: string,
    message: string,
    status: number,
    provider: string,
    model: string,
    billingTier: string,
    details?: Record<string, unknown>,
  ) {
    super(code, message, status, details);
    this.provider = provider;
    this.model = model;
    this.billingTier = billingTier;
  }
}

export function providerError(
  provider: string,
  model: string,
  billingTier: string,
  status: number,
  body: Record<string, unknown>,
): ProviderError {
  const raw = JSON.stringify(body).toLowerCase();
  if (status === 429) {
    return new ProviderError(
      "provider_quota_exceeded",
      `${provider} quota or spending limit has been exceeded.`,
      429,
      provider,
      model,
      billingTier,
      body,
    );
  }
  if (
    status === 402 ||
    (status === 400 &&
      (raw.includes("billing") || raw.includes("free tier")))
  ) {
    return new ProviderError(
      "billing_required",
      `The selected ${provider} model requires billing for this account or region.`,
      402,
      provider,
      model,
      billingTier,
      body,
    );
  }
  if (status === 401 || status === 403) {
    return new ProviderError(
      "provider_auth_error",
      `${provider} rejected the configured API key.`,
      502,
      provider,
      model,
      billingTier,
      body,
    );
  }
  if (status === 404) {
    return new ProviderError(
      "model_unavailable",
      `The selected model ${model} is unavailable.`,
      502,
      provider,
      model,
      billingTier,
      body,
    );
  }
  return new ProviderError(
    "provider_error",
    `${provider} could not process this request.`,
    status >= 500 ? 503 : 502,
    provider,
    model,
    billingTier,
    body,
  );
}
