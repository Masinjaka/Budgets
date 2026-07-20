import type { SupabaseClient } from "npm:@supabase/supabase-js@2.57.4";
import { ApiError } from "./errors.ts";
import type { AiContext, ModelResult } from "./types.ts";

export async function reserveRequest(
  admin: SupabaseClient,
  userId: string,
  provider: string,
  model: string,
  prompt: string,
): Promise<Record<string, unknown>> {
  const { data, error } = await admin.rpc("reserve_ai_request", {
    p_user_id: userId,
    p_provider: provider,
    p_model: model,
    p_prompt: prompt,
    p_daily_limit: 20,
    p_min_interval_seconds: 3,
  });
  if (error) throw new ApiError("database_error", error.message, 500);
  return asRecord(data);
}

export async function loadContext(
  admin: SupabaseClient,
  userId: string,
  requestId: string,
): Promise<AiContext> {
  const [categories, presets, profile, history, wallets] = await Promise.all([
    admin.from("categories")
      .select("name,emoji,color,icon_key,transaction_type")
      .eq("user_id", userId)
      .limit(100),
    admin.from("category_presets")
      .select("name,emoji,color,icon_key,transaction_type,aliases")
      .limit(100),
    admin.from("user")
      .select("currency_code")
      .eq("user_id", userId)
      .maybeSingle(),
    admin.from("ai_chat_messages")
      .select("role,content,created_at")
      .eq("user_id", userId)
      .neq("request_id", requestId)
      .order("created_at", { ascending: false })
      .limit(6),
    admin.from("wallets")
      .select("name,balance,currency_code")
      .eq("user_id", userId)
      .order("created_at"),
  ]);
  const error = categories.error ?? presets.error ?? profile.error ??
    history.error ?? wallets.error;
  if (error) throw new ApiError("database_error", error.message, 500);
  return {
    currencyCode: profile.data?.currency_code ?? "MGA",
    categories: categories.data ?? [],
    presets: presets.data ?? [],
    history: [...(history.data ?? [])].reverse(),
    wallets: wallets.data ?? [],
  };
}

export async function completeRequest(
  admin: SupabaseClient,
  userId: string,
  requestId: string,
  result: ModelResult,
  expenseWalletId?: string,
  periodMonth?: string,
  useAllWallets = false,
): Promise<Record<string, unknown>> {
  const extraction = result.extraction;
  const { data, error } = await admin.rpc("complete_finance_request", {
    p_request_id: requestId,
    p_user_id: userId,
    p_provider_response: extraction,
    p_transactions: extraction.transactions,
    p_transfers: extraction.transfers,
    p_categories: extraction.categories_to_create,
    p_input_tokens: result.inputTokens,
    p_output_tokens: result.outputTokens,
    p_expense_wallet_id: expenseWalletId ?? null,
    p_period_month: periodMonth ?? new Date().toISOString().slice(0, 10),
    p_use_all_wallets: useAllWallets,
  });
  if (error) {
    throw financeCommitError(error.message, requestId, result.extraction);
  }
  return asRecord(data);
}

export async function failRequest(
  admin: SupabaseClient,
  userId: string,
  requestId: string,
  error: ApiError,
): Promise<void> {
  await admin.rpc("fail_ai_request", {
    p_request_id: requestId,
    p_user_id: userId,
    p_error_code: error.code,
    p_message: error.message,
    p_provider_response: error.details ?? null,
  });
}

export async function quotaSnapshot(
  admin: SupabaseClient,
  userId: string,
): Promise<Record<string, unknown>> {
  const [plan, requests] = await Promise.all([
    admin.from("account_plans")
      .select("tier,status,current_period_end")
      .eq("user_id", userId)
      .maybeSingle(),
    admin.from("ai_requests")
      .select("id", { count: "exact", head: true })
      .eq("user_id", userId)
      .gte("created_at", new Date().toISOString().slice(0, 10)),
  ]);
  const activePro = plan.data?.tier === "pro" &&
    plan.data?.status === "active" &&
    (!plan.data.current_period_end ||
      Date.parse(plan.data.current_period_end) > Date.now());
  return {
    plan: activePro ? "pro" : "free",
    unlimited: activePro,
    remaining: activePro ? null : Math.max(0, 20 - (requests.count ?? 0)),
  };
}

function asRecord(value: unknown): Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {};
}

function financeCommitError(
  message: string,
  requestId: string,
  extraction: ModelResult["extraction"],
): ApiError {
  const errors: Record<string, string> = {
    wallet_not_found: "One of those wallets could not be found.",
    same_wallet_transfer: "Choose two different wallets for a transfer.",
    wallet_currency_mismatch: "Transfers require wallets in the same currency.",
    insufficient_wallet_balance: "The source wallet has insufficient funds.",
    invalid_transfer_amount: "Enter a valid transfer amount.",
  };
  const fundingError = fundingCommitError(message, requestId, extraction);
  if (fundingError) return fundingError;
  const code = Object.keys(errors).find((value) => message.includes(value));
  return code
    ? new ApiError(code, errors[code], 400)
    : new ApiError("database_error", message, 500);
}

function fundingCommitError(
  message: string,
  requestId: string,
  extraction: ModelResult["extraction"],
): ApiError | undefined {
  const match = message.match(
    /(wallet_consent_required|wallet_selection_required|insufficient_funds):(\d+)(?::(\d+))?/,
  );
  if (!match) return undefined;
  const requiredAmount = Number(match[2]) || 0;
  const availableAmount = Number(match[3]) || 0;
  const details = {
    request_id: requestId,
    extraction,
    required_amount: requiredAmount,
    available_amount: availableAmount,
  };
  if (match[1] === "insufficient_funds") {
    return new ApiError(
      "insufficient_funds",
      "Your wallets do not have enough money for this expense.",
      400,
      details,
    );
  }
  if (match[1] === "wallet_selection_required") {
    return new ApiError(
      "wallet_selection_required",
      "Choose another wallet to complete this expense.",
      409,
      details,
    );
  }
  return new ApiError(
    "wallet_consent_required",
    "No single wallet can cover this expense. Use funds from all wallets?",
    409,
    details,
  );
}
