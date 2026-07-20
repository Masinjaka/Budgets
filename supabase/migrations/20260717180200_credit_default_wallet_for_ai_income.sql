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
  v_default_wallet public.wallets%rowtype;
  v_income_total bigint := 0;
  v_income_currency text;
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

  if exists (
    select 1
    from jsonb_array_elements(p_transactions) item
    where item->>'transaction_type' = 'income'
  ) then
    select * into v_default_wallet
    from public.wallets
    where user_id = p_user_id and is_default
    for update;

    if v_default_wallet.id is null then
      insert into public.wallets(user_id, name, is_default)
      values (p_user_id, 'Main wallet', true)
      returning * into v_default_wallet;
    end if;

    select
      coalesce(sum(round((item->>'amount')::numeric)), 0)::bigint,
      min(upper(left(coalesce(
        nullif(item->>'currency_code', ''), 'MGA'
      ), 3)))
    into v_income_total, v_income_currency
    from jsonb_array_elements(p_transactions) item
    where item->>'transaction_type' = 'income';

    if v_income_currency <> v_default_wallet.currency_code
        or exists (
          select 1
          from jsonb_array_elements(p_transactions) item
          where item->>'transaction_type' = 'income'
            and upper(left(coalesce(
              nullif(item->>'currency_code', ''), 'MGA'
            ), 3)) <> v_default_wallet.currency_code
        ) then
      raise exception 'wallet_currency_mismatch';
    end if;

    update public.wallets
    set balance = balance + v_income_total, updated_at = now()
    where id = v_default_wallet.id;
  end if;

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
