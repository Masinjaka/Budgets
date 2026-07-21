begin;

alter table public."transaction"
  add column source_wallet_id uuid references public.wallets(id),
  add column envelope_id uuid references public.envelopes(id);
create index transaction_source_wallet_idx
  on public."transaction"(source_wallet_id);
create index transaction_envelope_idx
  on public."transaction"(envelope_id);

create or replace function public.route_expense_funds(
  p_transaction_id uuid,
  p_wallet_id uuid default null
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_tx public."transaction"%rowtype;
  v_envelope public.envelopes%rowtype;
  v_wallet public.wallets%rowtype;
  v_required bigint;
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
    v_required := greatest(v_tx.amount - v_envelope.remaining_amount, 0);
  else
    v_required := v_tx.amount;
  end if;

  if v_required > 0 then
    select * into v_wallet from public.wallets
    where user_id = v_tx.user_id
      and (id = p_wallet_id or (p_wallet_id is null and is_default))
    order by (id = p_wallet_id) desc
    limit 1 for update;
    if v_wallet.id is null then raise exception 'wallet_not_found'; end if;
    if v_wallet.balance < v_required then
      raise exception 'wallet_selection_required:%', v_required;
    end if;
    update public.wallets
    set balance = balance - v_required, updated_at = now()
    where id = v_wallet.id;
  end if;

  if v_envelope.id is not null then
    update public.envelopes
    set amount = amount + v_required,
        remaining_amount = remaining_amount + v_required - v_tx.amount,
        updated_at = now()
    where id = v_envelope.id;
    update public."transaction"
    set envelope_id = v_envelope.id,
        source_wallet_id = case when v_required > 0 then v_wallet.id end
    where id = v_tx.id;
  else
    update public."transaction"
    set source_wallet_id = v_wallet.id
    where id = v_tx.id;
  end if;
end;
$$;

create or replace function public.delete_funded_envelope(p_envelope_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_envelope public.envelopes%rowtype;
begin
  if v_user_id is null then raise exception 'unauthorized'; end if;
  select * into v_envelope from public.envelopes
  where id = p_envelope_id and user_id = v_user_id for update;
  if v_envelope.id is null then raise exception 'envelope_not_found'; end if;
  if v_envelope.remaining_amount > 0 then
    update public.wallets
    set balance = balance + v_envelope.remaining_amount, updated_at = now()
    where id = v_envelope.funding_wallet_id and user_id = v_user_id;
  end if;
  delete from public.envelopes where id = v_envelope.id;
end;
$$;

revoke all on function public.route_expense_funds(uuid, uuid)
  from public, anon, authenticated;
revoke all on function public.delete_funded_envelope(uuid)
  from public, anon;
grant execute on function public.delete_funded_envelope(uuid)
  to authenticated;
revoke insert, update, delete on public.envelopes from authenticated;

commit;
