import type { SupabaseClient } from "npm:@supabase/supabase-js@2.57.4";
import { ApiError } from "./errors.ts";
import type { ModelMedia } from "./types.ts";

const maxTotalBytes = 12 * 1024 * 1024;
const supportedTypes = new Set([
  "image/jpeg",
  "image/png",
  "application/pdf",
]);

export type ReceiptRecord = {
  id: string;
  storagePaths: string[];
  mimeTypes: string[];
};

export async function loadReceiptMedia(
  admin: SupabaseClient,
  userId: string,
  receiptId: string,
): Promise<{ receipt: ReceiptRecord; media: ModelMedia[] }> {
  const { data, error } = await admin.from("receipt_scans")
    .select("id,storage_paths,mime_types")
    .eq("id", receiptId)
    .eq("user_id", userId)
    .maybeSingle();
  if (error) throw new ApiError("database_error", error.message, 500);
  if (!data) throw new ApiError("receipt_not_found", "Receipt not found.", 404);
  const receipt = {
    id: String(data.id),
    storagePaths: stringArray(data.storage_paths),
    mimeTypes: stringArray(data.mime_types),
  };
  if (
    receipt.storagePaths.length === 0 ||
    receipt.storagePaths.length !== receipt.mimeTypes.length ||
    receipt.mimeTypes.some((type) => !supportedTypes.has(type))
  ) {
    throw new ApiError("invalid_receipt", "This receipt cannot be read.", 400);
  }
  let totalBytes = 0;
  const media: ModelMedia[] = [];
  for (let index = 0; index < receipt.storagePaths.length; index++) {
    const { data: file, error: downloadError } = await admin.storage
      .from("receipts").download(receipt.storagePaths[index]);
    if (downloadError) {
      throw new ApiError("receipt_download_failed", downloadError.message, 500);
    }
    totalBytes += file.size;
    if (totalBytes > maxTotalBytes) {
      throw new ApiError(
        "receipt_too_large",
        "This receipt is too large to process. Use fewer or smaller pages.",
        413,
      );
    }
    media.push({
      mimeType: receipt.mimeTypes[index],
      base64: bytesToBase64(new Uint8Array(await file.arrayBuffer())),
    });
  }
  return { receipt, media };
}

function bytesToBase64(bytes: Uint8Array): string {
  let binary = "";
  const chunkSize = 0x8000;
  for (let start = 0; start < bytes.length; start += chunkSize) {
    binary += String.fromCharCode(...bytes.subarray(start, start + chunkSize));
  }
  return btoa(binary);
}

function stringArray(value: unknown): string[] {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === "string")
    : [];
}
