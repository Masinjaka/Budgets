import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.4";
import {
  failRequest,
  loadContext,
  quotaSnapshot,
  reserveRequest,
} from "./database.ts";
import { ApiError } from "./errors.ts";
import { activeModel, callModel } from "./providers.ts";
import { buildPrompts, buildReceiptPrompts } from "./prompt.ts";
import {
  markReceiptFailed,
  markReceiptProcessed,
  markReceiptProcessing,
} from "./receipt_database.ts";
import { loadReceiptMedia } from "./receipt_media.ts";
import { financeSuccessResponse } from "./success_response.ts";
import { completeAndHydrate } from "./complete_and_hydrate.ts";
import { parseFinanceRequest } from "./request.ts";
import { anchorTransactionsToDate } from "./transaction_date.ts";
import { validateExtraction } from "./validation.ts";
import type { ModelResult } from "./types.ts";
import {
  corsHeaders,
  errorResponse,
  jsonResponse,
  normalizeError,
  quotaError,
  requiredEnv,
} from "./response.ts";

Deno.serve(async (request: Request) => {
  if (request.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (request.method !== "POST") {
    return errorResponse(
      new ApiError("method_not_allowed", "Use POST for this endpoint.", 405),
    );
  }

  let userId: string | undefined;
  let requestId: string | undefined;
  let receiptId: string | undefined;
  let admin: ReturnType<typeof createClient> | undefined;
  try {
    const body = await parseFinanceRequest(request);
    const authHeader = request.headers.get("authorization") ?? "";
    const token = authHeader.replace(/^Bearer\s+/i, "");
    if (!token) {
      throw new ApiError("unauthorized", "Please sign in to continue.", 401);
    }

    const url = requiredEnv("SUPABASE_URL");
    const anonKey = requiredEnv("SUPABASE_ANON_KEY");
    const serviceKey = requiredEnv("SUPABASE_SERVICE_ROLE_KEY");
    const userClient = createClient(url, anonKey, {
      global: { headers: { Authorization: `Bearer ${token}` } },
      auth: { persistSession: false },
    });
    const authResult = await userClient.auth.getUser(token);
    userId = authResult.data.user?.id;
    if (authResult.error || !userId) {
      throw new ApiError("unauthorized", "Your session has expired.", 401);
    }
    admin = createClient(url, serviceKey, {
      auth: { persistSession: false },
    });

    if (body.kind === "cancel") {
      requestId = body.requestId;
      await failRequest(
        admin,
        userId,
        requestId,
        new ApiError(
          "wallet_funding_declined",
          "Combined wallet funding was declined.",
          400,
        ),
      );
      return jsonResponse({ cancelled: true });
    }

    if (body.kind === "resume") {
      requestId = body.requestId;
      const extraction = validateExtraction(body.extraction);
      const result: ModelResult = {
        extraction,
        raw: extraction,
        provider: "resume",
        model: "validated-extraction",
        billingTier: "n/a",
      };
      const committed = await completeAndHydrate(
        admin,
        userId,
        requestId,
        result,
        body.expenseWalletId,
        body.targetDate,
        body.useAllWallets,
      );
      const quota = await quotaSnapshot(admin, userId);
      return jsonResponse({
        entries: committed.entries ?? [],
        wallets: committed.wallets,
        total_funds: committed.total_funds,
        message: extraction.message,
        ...quota,
        model: {
          provider: result.provider,
          name: result.model,
          billing_tier: result.billingTier,
        },
      });
    }

    const model = activeModel();
    receiptId = body.receiptId;
    const reservation = await reserveRequest(
      admin,
      userId,
      model.provider,
      model.model,
      receiptId ? `[Receipt ${receiptId}]` : body.message,
    );
    if (reservation.allowed !== true) {
      throw quotaError(reservation);
    }
    requestId = reservation.request_id as string;

    const context = await loadContext(admin, userId, requestId);
    const prompts = receiptId
      ? buildReceiptPrompts(
        context,
        new Date().toISOString(),
        body.timezone,
        body.targetDate,
        body.outputLanguage,
      )
      : buildPrompts(
        body.message,
        context,
        new Date().toISOString(),
        body.timezone,
        body.targetDate,
      );
    const media = receiptId
      ? (await loadReceiptMedia(admin, userId, receiptId)).media
      : [];
    if (receiptId) await markReceiptProcessing(admin, userId, receiptId);
    const modelResult = anchorTransactionsToDate(
      await callModel(prompts.system, prompts.user, media),
      body.targetDate,
      body.timezoneOffsetMinutes,
    );
    if (receiptId) {
      await markReceiptProcessed(
        admin,
        userId,
        receiptId,
        modelResult.extraction as unknown as Record<string, unknown>,
      );
    }
    const committed = await completeAndHydrate(
      admin,
      userId,
      requestId,
      modelResult,
      undefined,
      body.targetDate,
      false,
    );
    return financeSuccessResponse(committed, modelResult, reservation);
  } catch (caught) {
    const error = normalizeError(caught);
    if (
      admin && userId && receiptId &&
      error.code !== "wallet_selection_required" &&
      error.code !== "wallet_consent_required"
    ) {
      await markReceiptFailed(admin, userId, receiptId, error.message);
    }
    if (
      admin && userId && requestId &&
      error.code !== "wallet_selection_required" &&
      error.code !== "wallet_consent_required"
    ) {
      await failRequest(admin, userId, requestId, error);
    }
    return errorResponse(error);
  }
});
