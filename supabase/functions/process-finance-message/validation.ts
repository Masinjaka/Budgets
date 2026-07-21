import { ApiError } from "./errors.ts";
import type {
  ExtractedCategory,
  ExtractedTransfer,
  ExtractedTransaction,
  ExtractionResult,
} from "./types.ts";

const types = new Set(["expense", "income"]);

export function validateExtraction(value: unknown): ExtractionResult {
  if (!isRecord(value)) throw invalid();
  const transactions = value.transactions;
  const categories = value.categories_to_create;
  const transfers = value.transfers;
  if (
    !Array.isArray(transactions) ||
    !Array.isArray(categories) ||
    !Array.isArray(transfers) ||
    transactions.length > 10 ||
    categories.length > 10 ||
    transfers.length > 10
  ) {
    throw invalid();
  }
  return {
    transactions: transactions.map(validateTransaction),
    transfers: transfers.map(validateTransfer),
    categories_to_create: categories.map(validateCategory),
    message: cleanString(value.message, 500),
  };
}

function validateTransfer(value: unknown): ExtractedTransfer {
  if (!isRecord(value)) throw invalid();
  const amount = value.amount;
  const occurredAt = cleanString(value.occurred_at, 50);
  if (
    typeof amount !== "number" ||
    !Number.isFinite(amount) ||
    amount <= 0 ||
    !Number.isFinite(Date.parse(occurredAt))
  ) {
    throw invalid();
  }
  const from = cleanString(value.from_wallet_name, 80);
  const to = cleanString(value.to_wallet_name, 80);
  if (from.toLowerCase() === to.toLowerCase()) throw invalid();
  return {
    from_wallet_name: from,
    to_wallet_name: to,
    amount,
    occurred_at: occurredAt,
    currency_code: cleanCurrency(value.currency_code),
    description: optionalString(value.description, 500),
  };
}

function validateTransaction(value: unknown): ExtractedTransaction {
  if (!isRecord(value)) throw invalid();
  const amount = value.amount;
  const type = value.transaction_type;
  const occurredAt = cleanString(value.occurred_at, 50);
  const date = Date.parse(occurredAt);
  if (
    typeof amount !== "number" ||
    !Number.isFinite(amount) ||
    amount <= 0 ||
    typeof type !== "string" ||
    !types.has(type) ||
    !Number.isFinite(date)
  ) {
    throw invalid();
  }
  return {
    title: cleanString(value.title, 120),
    description: cleanString(value.description, 500),
    amount,
    transaction_type: type as "expense" | "income",
    category_name: cleanString(value.category_name, 80),
    occurred_at: occurredAt,
    currency_code: cleanCurrency(value.currency_code),
  };
}

function validateCategory(value: unknown): ExtractedCategory {
  if (!isRecord(value)) throw invalid();
  const type = value.transaction_type;
  if (typeof type !== "string" || !types.has(type)) throw invalid();
  return {
    name: cleanString(value.name, 80),
    transaction_type: type as "expense" | "income",
    emoji: cleanString(value.emoji, 16),
    color: cleanColor(value.color),
  };
}

function cleanString(value: unknown, max: number): string {
  if (typeof value !== "string") throw invalid();
  const clean = value.trim();
  if (!clean || clean.length > max) throw invalid();
  return clean;
}

function optionalString(value: unknown, max: number): string {
  if (value == null) return "";
  if (typeof value !== "string" || value.length > max) throw invalid();
  return value.trim();
}

function cleanCurrency(value: unknown): string {
  const code = cleanString(value, 3).toUpperCase();
  if (!/^[A-Z]{3}$/.test(code)) throw invalid();
  return code;
}

function cleanColor(value: unknown): string {
  const color = cleanString(value, 8).toUpperCase();
  if (!/^[0-9A-F]{8}$/.test(color)) throw invalid();
  return color;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function invalid(): ApiError {
  return new ApiError(
    "invalid_model_response",
    "The AI returned an invalid finance entry. Please try rephrasing.",
    502,
  );
}
