begin;

create or replace function public.complete_finance_request(
  p_request_id uuid,
  p_user_id uuid,
  p_provider_response jsonb,
  p_transactions jsonb,
  p_transfers jsonb default '[]',
  p_categories jsonb default '[]',
  p_input_tokens integer default null,
  p_output_tokens integer default null,
  p_expense_wallet_id uuid default null,
  p_period_month date default current_date
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_result jsonb;
  v_transfer_entries jsonb;
  v_transaction record;
  v_wallet public.wallets%rowtype;
  v_required bigint := 0;
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

  update public."transaction"
  set ledger_month = date_trunc('month', p_period_month)::date
  where ai_request_id = p_request_id and user_id = p_user_id;

  select coalesce(sum(greatest(
    tx.amount - coalesce(envelope.remaining_amount, 0),
    0
  )), 0)::bigint
  into v_required
  from public."transaction" tx
  left join public.envelopes envelope
    on envelope.user_id = tx.user_id
    and envelope.category_id = tx.category_id
    and envelope.period_month = tx.ledger_month
  where tx.ai_request_id = p_request_id
    and tx.user_id = p_user_id
    and tx.transaction_type = 'expense';

  if v_required > 0 then
    select * into v_wallet
    from public.wallets
    where user_id = p_user_id
      and (
        id = p_expense_wallet_id
        or (p_expense_wallet_id is null and is_default)
      )
    order by (id = p_expense_wallet_id) desc
    limit 1 for update;
    if v_wallet.id is null then raise exception 'wallet_not_found'; end if;
    if v_wallet.balance < v_required then
      raise exception 'wallet_selection_required:%', v_required;
    end if;
  end if;

  perform public.credit_ai_income_to_default_wallet(
    p_request_id,
    p_user_id
  );
  for v_transaction in
    select id from public."transaction"
    where ai_request_id = p_request_id
      and user_id = p_user_id
      and transaction_type = 'expense'
    order by id
  loop
    perform public.route_expense_funds(
      v_transaction.id,
      p_expense_wallet_id
    );
  end loop;

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

commit;
