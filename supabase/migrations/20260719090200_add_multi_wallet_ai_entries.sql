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
  p_period_month date default current_date,
  p_use_all_wallets boolean default false
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
  v_available bigint := 0;
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
    category_expenses.amount - category_expenses.envelope_balance, 0
  )), 0)::bigint into v_required
  from (
    select
      sum(tx.amount)::bigint as amount,
      coalesce(max(envelope.remaining_amount), 0)::bigint
        as envelope_balance
    from public."transaction" tx
    left join public.envelopes envelope
      on envelope.user_id = tx.user_id
      and envelope.category_id = tx.category_id
      and envelope.period_month = tx.ledger_month
    where tx.ai_request_id = p_request_id
      and tx.user_id = p_user_id
      and tx.transaction_type = 'expense'
    group by tx.category_id, tx.ledger_month
  ) category_expenses;

  if v_required > 0 then
    perform 1 from public.wallets
    where user_id = p_user_id order by id for update;
    select coalesce(sum(balance), 0)::bigint into v_available
    from public.wallets where user_id = p_user_id;
    if p_use_all_wallets then
      if v_available < v_required then
        raise exception 'insufficient_funds:%:%',
          v_required, v_available;
      end if;
    else
      select * into v_wallet from public.wallets
      where user_id = p_user_id
        and (
          id = p_expense_wallet_id
          or (p_expense_wallet_id is null and is_default)
        )
      order by (id = p_expense_wallet_id) desc
      limit 1;
      if v_wallet.id is null then raise exception 'wallet_not_found'; end if;
      if v_wallet.balance < v_required then
        if v_available >= v_required then
          raise exception 'wallet_consent_required:%:%',
            v_required, v_available;
        end if;
        raise exception 'insufficient_funds:%:%',
          v_required, v_available;
      end if;
    end if;
  end if;

  perform public.credit_ai_income_to_default_wallet(
    p_request_id, p_user_id
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
      p_expense_wallet_id,
      p_use_all_wallets
    );
  end loop;

  v_transfer_entries := public.commit_ai_wallet_transfers(
    p_request_id, p_user_id, p_transfers
  );
  return jsonb_set(
    v_result,
    '{entries}',
    coalesce(v_result->'entries', '[]'::jsonb) || v_transfer_entries
  );
end;
$$;

revoke all on function public.complete_finance_request(
  uuid, uuid, jsonb, jsonb, jsonb, jsonb,
  integer, integer, uuid, date, boolean
) from public, anon, authenticated;
grant execute on function public.complete_finance_request(
  uuid, uuid, jsonb, jsonb, jsonb, jsonb,
  integer, integer, uuid, date, boolean
) to service_role;

commit;
