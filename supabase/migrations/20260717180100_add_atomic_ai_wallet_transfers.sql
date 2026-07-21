begin;

create or replace function public.commit_ai_wallet_transfers(
  p_request_id uuid,
  p_user_id uuid,
  p_transfers jsonb
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_item jsonb;
  v_from public.wallets%rowtype;
  v_to public.wallets%rowtype;
  v_amount bigint;
  v_occurred_at timestamptz;
  v_transfer_id uuid;
  v_entries jsonb := '[]'::jsonb;
begin
  if jsonb_typeof(p_transfers) <> 'array'
      or jsonb_array_length(p_transfers) > 10 then
    raise exception 'invalid_transfer_result';
  end if;

  if not exists (
    select 1 from public.ai_requests
    where id = p_request_id and user_id = p_user_id
  ) then
    raise exception 'invalid_ai_request';
  end if;

  perform 1
  from public.wallets
  where user_id = p_user_id
  order by id
  for update;

  for v_item in select value from jsonb_array_elements(p_transfers)
  loop
    v_amount := round((v_item->>'amount')::numeric)::bigint;
    if v_amount <= 0 then raise exception 'invalid_transfer_amount'; end if;

    select * into v_from
    from public.wallets
    where user_id = p_user_id
      and lower(name) = lower(trim(v_item->>'from_wallet_name'))
    limit 1;

    select * into v_to
    from public.wallets
    where user_id = p_user_id
      and lower(name) = lower(trim(v_item->>'to_wallet_name'))
    limit 1;

    if v_from.id is null or v_to.id is null then
      raise exception 'wallet_not_found';
    end if;
    if v_from.id = v_to.id then raise exception 'same_wallet_transfer'; end if;
    if v_from.currency_code <> v_to.currency_code then
      raise exception 'wallet_currency_mismatch';
    end if;
    if v_from.balance < v_amount then
      raise exception 'insufficient_wallet_balance';
    end if;

    v_occurred_at := least(
      coalesce((v_item->>'occurred_at')::timestamptz, now()),
      now()
    );

    update public.wallets
    set balance = balance - v_amount, updated_at = now()
    where id = v_from.id;

    update public.wallets
    set balance = balance + v_amount, updated_at = now()
    where id = v_to.id;

    insert into public.wallet_transfers(
      user_id,
      from_wallet_id,
      to_wallet_id,
      amount,
      currency_code,
      description,
      occurred_at,
      ai_request_id
    ) values (
      p_user_id,
      v_from.id,
      v_to.id,
      v_amount,
      v_from.currency_code,
      left(coalesce(v_item->>'description', ''), 500),
      v_occurred_at,
      p_request_id
    ) returning id into v_transfer_id;

    v_entries := v_entries || jsonb_build_array(jsonb_build_object(
      'id', v_transfer_id,
      'entry_type', 'transfer',
      'title', 'Moved from ' || v_from.name || ' to ' || v_to.name,
      'description', coalesce(v_item->>'description', ''),
      'amount', v_amount,
      'date', v_occurred_at,
      'transaction_type', 'transfer',
      'currency_code', v_from.currency_code,
      'category', jsonb_build_object(
        'name', 'Transfer',
        'icon_key', 'transfer',
        'emoji', '↔'
      )
    ));
  end loop;

  return v_entries;
end;
$$;

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

revoke all on function public.commit_ai_wallet_transfers(
  uuid, uuid, jsonb
) from public, anon, authenticated;
grant execute on function public.commit_ai_wallet_transfers(
  uuid, uuid, jsonb
) to service_role;

revoke all on function public.complete_finance_request(
  uuid, uuid, jsonb, jsonb, jsonb, jsonb, integer, integer
) from public, anon, authenticated;
grant execute on function public.complete_finance_request(
  uuid, uuid, jsonb, jsonb, jsonb, jsonb, integer, integer
) to service_role;

commit;
