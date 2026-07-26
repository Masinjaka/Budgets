import type { SupabaseClient } from "npm:@supabase/supabase-js@2.57.4";
import { ApiError } from "./errors.ts";
import type { ModelResult } from "./types.ts";

type RatesRow = {
  base: string;
  rates: unknown;
};

export async function normalizeResultToMga(
  admin: SupabaseClient,
  result: ModelResult,
): Promise<ModelResult> {
  const currencies = new Set([
    ...result.extraction.transactions.map((item) => item.currency_code),
    ...result.extraction.transfers.map((item) => item.currency_code),
  ].map(normalizeCode));
  currencies.delete("MGA");
  if (currencies.size === 0) return result;

  const { data, error } = await admin.from("exchange_rates")
    .select("base,rates")
    .order("fetched_at", { ascending: false })
    .limit(1)
    .maybeSingle();
  if (error || !data) throw rateUnavailable();
  const rates = data as RatesRow;
  for (const currency of currencies) rateFor(currency, rates);

  return {
    ...result,
    extraction: {
      ...result.extraction,
      transactions: result.extraction.transactions.map((item) => ({
        ...item,
        amount: convertAmountToMga(item.amount, item.currency_code, rates),
        currency_code: "MGA",
      })),
      transfers: result.extraction.transfers.map((item) => ({
        ...item,
        amount: convertAmountToMga(item.amount, item.currency_code, rates),
        currency_code: "MGA",
      })),
    },
  };
}

export function convertAmountToMga(
  amount: number,
  sourceCurrency: string,
  row: RatesRow,
): number {
  const converted = Math.round(
    amount / rateFor(sourceCurrency, row) * rateFor("MGA", row),
  );
  if (!Number.isSafeInteger(converted) || converted <= 0) {
    throw new ApiError(
      "invalid_converted_amount",
      "This amount is too small or too large to store in Ariary.",
      400,
    );
  }
  return converted;
}

function rateFor(currency: string, row: RatesRow): number {
  const code = normalizeCode(currency);
  if (code === normalizeCode(row.base)) return 1;
  const raw = ratesRecord(row.rates)[code];
  const value = typeof raw === "number" ? raw : Number(raw);
  if (!Number.isFinite(value) || value <= 0) {
    throw rateUnavailable(code);
  }
  return value;
}

function ratesRecord(value: unknown): Record<string, unknown> {
  if (typeof value === "string") {
    try {
      return ratesRecord(JSON.parse(value));
    } catch (_) {
      return {};
    }
  }
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {};
}

function normalizeCode(value: string): string {
  return value.trim().toUpperCase().slice(0, 3);
}

function rateUnavailable(currency?: string): ApiError {
  return new ApiError(
    "exchange_rate_unavailable",
    currency
      ? `The exchange rate for ${currency} is currently unavailable.`
      : "Exchange rates are currently unavailable. Please try again later.",
    503,
  );
}
