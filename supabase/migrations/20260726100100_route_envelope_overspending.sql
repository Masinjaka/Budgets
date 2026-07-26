begin;

create or replace function public.route_expense_funds(
  p_transaction_id uuid,
  p_wallet_id uuid,
  p_use_all_wallets boolean
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_tx public."transaction"%rowtype;
  v_envelope public.envelopes%rowtype;
  v_wallet public.wallets%rowtype;
  v_envelope_used bigint := 0;
  v_required bigint;
  v_remaining bigint;
  v_debit bigint;
  v_available bigint;
begin
  select * into v_tx from public."transaction"
  where id = p_transaction_id for update;
  if v_tx.id is null then raise exception 'transaction_not_found'; end if;
  if v_tx.transaction_type <> 'expense' then return; end if;

  select * into v_envelope from public.envelopes
  where user_id = v_tx.user_id
    and category_id = v_tx.category_id
    and period_month = v_tx.ledger_month
  limit 1 for update;
  if v_envelope.id is not null then
    v_envelope_used := least(v_envelope.remaining_amount, v_tx.amount);
  end if;
  v_required := v_tx.amount - v_envelope_used;

  if v_required > 0 and p_use_all_wallets then
    perform 1 from public.wallets
    where user_id = v_tx.user_id order by id for update;
    select coalesce(sum(balance), 0)::bigint into v_available
    from public.wallets where user_id = v_tx.user_id;
    if v_available < v_required then
      raise exception 'insufficient_funds:%:%', v_required, v_available;
    end if;
    v_remaining := v_required;
    for v_wallet in
      select * from public.wallets
      where user_id = v_tx.user_id and balance > 0
      order by is_default desc, created_at, id
      for update
    loop
      exit when v_remaining = 0;
      v_debit := least(v_wallet.balance, v_remaining);
      update public.wallets set balance = balance - v_debit, updated_at = now()
      where id = v_wallet.id;
      insert into public.transaction_wallet_debits(
        transaction_id, wallet_id, user_id, amount
      ) values (v_tx.id, v_wallet.id, v_tx.user_id, v_debit);
      v_remaining := v_remaining - v_debit;
    end loop;
  elsif v_required > 0 then
    select * into v_wallet from public.wallets
    where user_id = v_tx.user_id
      and (id = p_wallet_id or (p_wallet_id is null and is_default))
    order by (id = p_wallet_id) desc
    limit 1 for update;
    if v_wallet.id is null then raise exception 'wallet_not_found'; end if;
    if v_wallet.balance < v_required then
      select coalesce(sum(balance), 0)::bigint into v_available
      from public.wallets where user_id = v_tx.user_id;
      if v_available >= v_required then
        raise exception 'wallet_consent_required:%:%',
          v_required, v_available;
      end if;
      raise exception 'insufficient_funds:%:%', v_required, v_available;
    end if;
    update public.wallets set balance = balance - v_required, updated_at = now()
    where id = v_wallet.id;
    insert into public.transaction_wallet_debits(
      transaction_id, wallet_id, user_id, amount
    ) values (v_tx.id, v_wallet.id, v_tx.user_id, v_required);
  end if;

  if v_envelope.id is not null then
    update public.envelopes
    set remaining_amount = remaining_amount - v_envelope_used,
        overspent_amount = overspent_amount + v_required,
        updated_at = now()
    where id = v_envelope.id;
    if v_required > 0 then
      insert into public.finance_notifications(
        user_id, notification_type, envelope_id, transaction_id,
        envelope_name, amount, period_month
      ) values (
        v_tx.user_id, 'envelope_overspent', v_envelope.id, v_tx.id,
        v_envelope.name, v_required, v_envelope.period_month
      ) on conflict (transaction_id, notification_type) do nothing;
    end if;
  end if;
  update public."transaction"
  set envelope_id = v_envelope.id,
      envelope_amount_used = v_envelope_used,
      source_wallet_id = case
        when p_use_all_wallets then null
        when v_required > 0 then v_wallet.id
      end
  where id = v_tx.id;
end;
$$;

revoke all on function public.route_expense_funds(uuid, uuid, boolean)
  from public, anon, authenticated;

commit;
