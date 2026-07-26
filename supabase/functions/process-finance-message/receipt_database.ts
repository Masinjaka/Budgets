import type { SupabaseClient } from "npm:@supabase/supabase-js@2.57.4";

export async function markReceiptProcessing(
  admin: SupabaseClient,
  userId: string,
  receiptId: string,
): Promise<void> {
  await update(admin, userId, receiptId, {
    status: "processing",
    error_message: null,
  });
}

export async function markReceiptProcessed(
  admin: SupabaseClient,
  userId: string,
  receiptId: string,
  extraction: Record<string, unknown>,
): Promise<void> {
  await update(admin, userId, receiptId, {
    status: "processed",
    extracted_data: extraction,
    error_message: null,
    processed_at: new Date().toISOString(),
  });
}

export async function markReceiptFailed(
  admin: SupabaseClient,
  userId: string,
  receiptId: string,
  message: string,
): Promise<void> {
  await update(admin, userId, receiptId, {
    status: "failed",
    error_message: message.slice(0, 500),
    processed_at: new Date().toISOString(),
  });
}

async function update(
  admin: SupabaseClient,
  userId: string,
  receiptId: string,
  values: Record<string, unknown>,
): Promise<void> {
  const { error } = await admin.from("receipt_scans").update(values)
    .eq("id", receiptId).eq("user_id", userId);
  if (error) console.error("Receipt status update failed", error.message);
}
