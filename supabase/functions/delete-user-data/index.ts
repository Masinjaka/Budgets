import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";
import { errorResponse, jsonResponse } from "./responses.ts";
import { deleteUserFiles } from "./storage.ts";

type DeleteAction = "data" | "account";

Deno.serve(async (request) => {
  if (request.method !== "POST") {
    return errorResponse(405, "method_not_allowed", "POST is required.");
  }

  const authorization = request.headers.get("authorization");
  if (!authorization?.startsWith("Bearer ")) {
    return errorResponse(401, "unauthorized", "Please sign in again.");
  }

  const url = Deno.env.get("SUPABASE_URL");
  const serviceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  if (!url || !serviceKey) {
    return errorResponse(500, "configuration_error", "Service unavailable.");
  }

  const admin = createClient(url, serviceKey, {
    auth: { autoRefreshToken: false, persistSession: false },
  });
  const token = authorization.slice("Bearer ".length);
  const { data: authData, error: authError } =
    await admin.auth.getUser(token);
  const user = authData.user;
  if (authError || !user) {
    return errorResponse(401, "unauthorized", "Please sign in again.");
  }

  let body: Record<string, unknown>;
  try {
    body = await request.json();
  } catch (_) {
    return errorResponse(400, "invalid_request", "Invalid request.");
  }

  const action = body.action as DeleteAction;
  const confirmation = String(body.confirmation ?? "").trim();
  const confirmed = action === "data"
    ? ["SUPPRIMER", "DELETE"].includes(confirmation.toUpperCase())
    : action === "account" &&
      confirmation.toLowerCase() === (user.email ?? "").toLowerCase();
  if (!confirmed) {
    return errorResponse(
      400,
      "confirmation_mismatch",
      "The confirmation does not match.",
    );
  }

  try {
    await deleteUserFiles(admin, user.id);
    const { error: receiptError } = await admin.from("receipt_scans")
      .delete().eq("user_id", user.id);
    if (receiptError && receiptError.code !== "42P01") throw receiptError;
    const { error: cleanupError } = await admin.rpc(
      "cleanup_user_app_data",
      {
        p_user_id: user.id,
        p_recreate_profile: action === "data",
      },
    );
    if (cleanupError) throw cleanupError;

    if (action === "account") {
      const { error } = await admin.auth.admin.deleteUser(user.id, false);
      if (error) throw error;
    } else {
      const { error } = await admin.auth.admin.updateUserById(user.id, {
        user_metadata: {},
      });
      if (error) throw error;
    }
    return jsonResponse(200, { deleted: true, action });
  } catch (error) {
    console.error("delete-user-data failed", error);
    return errorResponse(
      500,
      "deletion_failed",
      "Your data could not be deleted. Please try again.",
    );
  }
});
