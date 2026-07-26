begin;

create or replace function public.reverse_finance_entry_funds(
  p_transaction_id uuid,
  p_user_id uuid
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_tx public."transaction"%rowtype;
  v_credit public.wallet_income_credits%rowtype;
  v_wallet public.wallets%rowtype;
  v_wallet_debits bigint := 0;
  v_available bigint := 0;
begin
  select * into v_tx from public."transaction"
  where id = p_transaction_id and user_id = p_user_id for update;
  if v_tx.id is null then raise exception 'transaction_not_found'; end if;

  if v_tx.transaction_type = 'income' then
    select * into v_credit from public.wallet_income_credits
    where transaction_id = v_tx.id and user_id = p_user_id;
    if v_credit.transaction_id is not null then
      select * into v_wallet from public.wallets
      where id = v_credit.wallet_id and user_id = p_user_id for update;
      if v_wallet.balance < v_credit.amount then
        select coalesce(sum(balance), 0)::bigint into v_available
        from public.wallets where user_id = p_user_id;
        raise exception 'insufficient_funds:%:%',
          v_credit.amount, v_available;
      end if;
      update public.wallets
      set balance = balance - v_credit.amount, updated_at = now()
      where id = v_credit.wallet_id and user_id = p_user_id;
      delete from public.wallet_income_credits
      where transaction_id = v_tx.id and user_id = p_user_id;
    end if;
  elsif v_tx.transaction_type = 'expense' then
    perform 1 from public.wallets
    where id in (
      select wallet_id from public.transaction_wallet_debits
      where transaction_id = v_tx.id and user_id = p_user_id
    ) order by id for update;
    select coalesce(sum(amount), 0)::bigint into v_wallet_debits
    from public.transaction_wallet_debits
    where transaction_id = v_tx.id and user_id = p_user_id;
    update public.wallets wallet
    set balance = wallet.balance + debit.amount, updated_at = now()
    from (
      select wallet_id, sum(amount)::bigint as amount
      from public.transaction_wallet_debits
      where transaction_id = v_tx.id and user_id = p_user_id
      group by wallet_id
    ) debit
    where wallet.id = debit.wallet_id and wallet.user_id = p_user_id;
    if v_tx.envelope_id is not null then
      perform 1 from public.envelopes
      where id = v_tx.envelope_id and user_id = p_user_id for update;
      update public.envelopes
      set amount = greatest(amount - v_wallet_debits, 0),
          remaining_amount = remaining_amount
            + greatest(v_tx.amount - v_wallet_debits, 0),
          updated_at = now()
      where id = v_tx.envelope_id and user_id = p_user_id;
    end if;
    delete from public.transaction_wallet_debits
    where transaction_id = v_tx.id and user_id = p_user_id;
  end if;

  update public."transaction"
  set source_wallet_id = null,
      envelope_id = null,
      envelope_amount_used = 0
  where id = v_tx.id and user_id = p_user_id;
end;
$$;

revoke all on function public.reverse_finance_entry_funds(uuid, uuid)
  from public, anon, authenticated;

commit;
