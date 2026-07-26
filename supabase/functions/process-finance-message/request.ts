import { ApiError } from "./errors.ts";

export type FinanceRequest = {
  kind: "new";
  message: string;
  receiptId?: string;
  outputLanguage: "English" | "French";
  timezone: string;
  targetDate: string;
  timezoneOffsetMinutes: number;
};

export type ResumeRequest = {
  kind: "resume";
  requestId: string;
  extraction: unknown;
  expenseWalletId?: string;
  useAllWallets: boolean;
  targetDate: string;
};

export type CancelRequest = {
  kind: "cancel";
  requestId: string;
};

export async function parseFinanceRequest(
  request: Request,
): Promise<FinanceRequest | ResumeRequest | CancelRequest> {
  let value: unknown;
  try {
    value = await request.json();
  } catch (_) {
    throw invalidRequest();
  }
  if (!isRecord(value)) throw invalidRequest();
  if (typeof value.cancel_request_id === "string") {
    return parseCancelRequest(value);
  }
  if (typeof value.resume_request_id === "string") {
    return parseResumeRequest(value);
  }

  const message = typeof value.message === "string"
    ? value.message.trim()
    : "";
  const receiptId = typeof value.receipt_id === "string"
    ? value.receipt_id
    : undefined;
  const outputLanguage = value.output_language === "fr" ? "French" : "English";
  const timezone = typeof value.timezone === "string"
    ? value.timezone.trim()
    : "UTC";
  const targetDate = typeof value.target_date === "string"
    ? value.target_date
    : "";
  const offset = value.timezone_offset_minutes;
  if (
    (!message && !receiptId) || message.length > 1000 ||
    (receiptId !== undefined && !isUuid(receiptId)) || timezone.length > 80 ||
    !isValidDateKey(targetDate) || typeof offset !== "number" ||
    !Number.isInteger(offset) || offset < -840 || offset > 840
  ) {
    throw invalidRequest();
  }

  const timezoneOffsetMinutes = offset;
  const localToday = new Date(
    Date.now() + timezoneOffsetMinutes * 60_000,
  ).toISOString().slice(0, 10);
  if (targetDate > localToday) {
    throw new ApiError(
      "future_date_not_allowed",
      "Transactions cannot be added to a future date.",
      400,
    );
  }
  return {
    kind: "new",
    message: message || "Extract the receipt transactions.",
    receiptId,
    outputLanguage,
    timezone,
    targetDate,
    timezoneOffsetMinutes,
  };
}

function parseResumeRequest(value: Record<string, unknown>): ResumeRequest {
  const requestId = value.resume_request_id;
  const walletId = value.expense_wallet_id;
  const useAllWallets = value.use_all_wallets === true;
  const targetDate = value.target_date;
  if (
    typeof requestId !== "string" || !isUuid(requestId) ||
    (!useAllWallets &&
      (typeof walletId !== "string" || !isUuid(walletId))) ||
    (walletId !== undefined && walletId !== null &&
      (typeof walletId !== "string" || !isUuid(walletId))) ||
    typeof targetDate !== "string" || !isValidDateKey(targetDate) ||
    !isRecord(value.extraction)
  ) {
    throw invalidRequest();
  }
  return {
    kind: "resume",
    requestId,
    expenseWalletId: typeof walletId === "string" ? walletId : undefined,
    useAllWallets,
    extraction: value.extraction,
    targetDate,
  };
}

function parseCancelRequest(value: Record<string, unknown>): CancelRequest {
  const requestId = value.cancel_request_id;
  if (typeof requestId !== "string" || !isUuid(requestId)) {
    throw invalidRequest();
  }
  return { kind: "cancel", requestId };
}

function isUuid(value: string): boolean {
  return /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
    .test(value);
}

function isValidDateKey(value: string): boolean {
  if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return false;
  const [year, month, day] = value.split("-").map(Number);
  const parsed = new Date(Date.UTC(year, month - 1, day));
  return parsed.getUTCFullYear() === year &&
    parsed.getUTCMonth() === month - 1 &&
    parsed.getUTCDate() === day;
}

function isRecord(value: unknown): value is Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value);
}

function invalidRequest(): ApiError {
  return new ApiError(
    "invalid_request",
    "Enter a valid message and transaction date.",
    400,
  );
}
