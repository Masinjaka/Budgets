begin;

create or replace function public.complete_finance_request(
  p_request_id uuid,
  p_user_id uuid,
  p_provider_response jsonb,
  p_transactions jsonb,
  p_transfers jsonb default '[]',
  p_categories jsonb default '[]',
  p_input_tokens integer default null,
  p_output_tokens integer default null
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_result jsonb;
  v_transfer_entries jsonb;
begin
  v_result := public.complete_ai_request(
    p_request_id,
    p_user_id,
    p_provider_response,
    p_transactions,
    p_categories,
    p_input_tokens,
    p_output_tokens
  );
  perform public.credit_ai_income_to_default_wallet(
    p_request_id,
    p_user_id
  );
  v_transfer_entries := public.commit_ai_wallet_transfers(
    p_request_id,
    p_user_id,
    p_transfers
  );
  return jsonb_set(
    v_result,
    '{entries}',
    coalesce(v_result->'entries', '[]'::jsonb) || v_transfer_entries
  );
end;
$$;

revoke all on function public.complete_finance_request(
  uuid, uuid, jsonb, jsonb, jsonb, jsonb, integer, integer
) from public, anon, authenticated;
grant execute on function public.complete_finance_request(
  uuid, uuid, jsonb, jsonb, jsonb, jsonb, integer, integer
) to service_role;

commit;
