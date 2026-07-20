import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2.57.4";
import {
  completeRequest,
  failRequest,
  loadContext,
  quotaSnapshot,
  reserveRequest,
} from "./database.ts";
import { ApiError } from "./errors.ts";
import { activeModel, callModel } from "./providers.ts";
import { buildPrompts } from "./prompt.ts";
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
      const committed = await completeRequest(
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
    const reservation = await reserveRequest(
      admin,
      userId,
      model.provider,
      model.model,
      body.message,
    );
    if (reservation.allowed !== true) {
      throw quotaError(reservation);
    }
    requestId = reservation.request_id as string;

    const context = await loadContext(admin, userId, requestId);
    const prompts = buildPrompts(
      body.message,
      context,
      new Date().toISOString(),
      body.timezone,
      body.targetDate,
    );
    const modelResult = anchorTransactionsToDate(
      await callModel(prompts.system, prompts.user),
      body.targetDate,
      body.timezoneOffsetMinutes,
    );
    const committed = await completeRequest(
      admin,
      userId,
      requestId,
      modelResult,
      undefined,
      body.targetDate,
      false,
    );
    return jsonResponse({
      entries: committed.entries ?? [],
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
  } catch (caught) {
    const error = normalizeError(caught);
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
