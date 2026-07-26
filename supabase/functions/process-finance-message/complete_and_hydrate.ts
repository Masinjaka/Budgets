import type { SupabaseClient } from "npm:@supabase/supabase-js@2.57.4";
import { normalizeResultToMga } from "./currency_normalization.ts";
import { completeRequest } from "./database.ts";
import type { ModelResult } from "./types.ts";

export async function completeAndHydrate(
  admin: SupabaseClient,
  userId: string,
  requestId: string,
  result: ModelResult,
  expenseWalletId?: string,
  periodMonth?: string,
  useAllWallets = false,
): Promise<Record<string, unknown>> {
  const normalized = await normalizeResultToMga(admin, result);
  const committed = await completeRequest(
    admin,
    userId,
    requestId,
    normalized,
    expenseWalletId,
    periodMonth,
    useAllWallets,
  );
  const entries = Array.isArray(committed.entries) ? committed.entries : [];
  const ids = entries.flatMap((entry) => {
    const id = record(entry).id;
    return typeof id === "string" ? [id] : [];
  });
  if (ids.length === 0) return committed;
  const { data, error } = await admin.from("transaction")
    .select("id,envelope_amount_used,envelope:envelopes(name)")
    .eq("user_id", userId)
    .in("id", ids);
  if (error) return committed;
  const funding = new Map(
    (data ?? []).map((row) => [String(row.id), record(row)]),
  );
  return {
    ...committed,
    entries: entries.map((entry) => withEnvelope(entry, funding)),
  };
}

function withEnvelope(
  entry: unknown,
  funding: Map<string, Record<string, unknown>>,
): Record<string, unknown> {
  const value = record(entry);
  const source = funding.get(String(value.id));
  const used = Number(source?.envelope_amount_used ?? 0);
  const envelope = record(source?.envelope);
  return used > 0 && typeof envelope.name === "string"
    ? { ...value, envelope_amount_used: used, envelope_name: envelope.name }
    : value;
}

function record(value: unknown): Record<string, unknown> {
  return typeof value === "object" && value !== null && !Array.isArray(value)
    ? value as Record<string, unknown>
    : {};
}
