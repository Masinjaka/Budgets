begin;

create or replace function public.update_finance_entry(
  p_transaction_id uuid,
  p_title text,
  p_description text,
  p_amount bigint,
  p_occurred_at timestamptz,
  p_transaction_type text,
  p_category_id uuid default null,
  p_source_wallet_id uuid default null,
  p_period_month date default current_date,
  p_use_all_wallets boolean default false
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_tx public."transaction"%rowtype;
  v_category public.categories%rowtype;
  v_wallet public.wallets%rowtype;
  v_name text;
  v_occurred_at timestamptz;
  v_debits jsonb;
  v_source_wallet_id uuid;
  v_use_all_wallets boolean;
begin
  if v_user_id is null then raise exception 'unauthorized'; end if;
  if p_amount <= 0 then raise exception 'invalid_transaction_amount'; end if;
  if p_transaction_type not in ('expense', 'income') then
    raise exception 'invalid_transaction_type';
  end if;
  select * into v_tx from public."transaction"
  where id = p_transaction_id and user_id = v_user_id for update;
  if v_tx.id is null then raise exception 'transaction_not_found'; end if;
  v_source_wallet_id := coalesce(p_source_wallet_id, v_tx.source_wallet_id);
  v_use_all_wallets := p_use_all_wallets or (
    v_tx.source_wallet_id is null and exists (
      select 1 from public.transaction_wallet_debits
      where transaction_id = v_tx.id and user_id = v_user_id
    )
  );

  if p_category_id is not null then
    select * into v_category from public.categories
    where id = p_category_id and user_id = v_user_id
      and coalesce(transaction_type, 'expense') = p_transaction_type;
  end if;
  if v_category.id is null then
    v_name := case when p_transaction_type = 'income'
      then 'Other income' else 'Other' end;
    insert into public.categories(
      user_id, name, emoji, color, icon_key, transaction_type
    ) values (
      v_user_id, v_name,
      case when p_transaction_type = 'income' then '💰' else '🧾' end,
      case when p_transaction_type = 'income'
        then 'FF8BC34A' else 'FF9E9E9E' end,
      case when p_transaction_type = 'income' then 'income' else 'other' end,
      p_transaction_type
    ) on conflict (
      user_id, lower(name), coalesce(transaction_type, 'expense')
    ) do update set name = excluded.name returning * into v_category;
  end if;

  perform public.reverse_finance_entry_funds(p_transaction_id, v_user_id);
  v_occurred_at := least(coalesce(p_occurred_at, v_tx.date), now());
  update public."transaction"
  set title = left(coalesce(nullif(trim(p_title), ''), v_category.name), 120),
      description = left(coalesce(p_description, ''), 500),
      amount = p_amount,
      date = v_occurred_at,
      category_id = v_category.id,
      transaction_type = p_transaction_type,
      ledger_month = date_trunc('month', p_period_month)::date
  where id = p_transaction_id and user_id = v_user_id;

  if p_transaction_type = 'income' then
    select * into v_wallet from public.wallets
    where user_id = v_user_id and is_default for update;
    if v_wallet.id is null then
      insert into public.wallets(user_id, name, is_default)
      values (v_user_id, 'Main wallet', true) returning * into v_wallet;
    end if;
    insert into public.wallet_income_credits(
      transaction_id, wallet_id, user_id, amount, currency_code
    ) values (
      p_transaction_id, v_wallet.id, v_user_id,
      p_amount, v_wallet.currency_code
    );
    update public.wallets
    set balance = balance + p_amount, updated_at = now()
    where id = v_wallet.id;
  else
    select * into v_wallet from public.wallets
    where user_id = v_user_id and is_default;
    perform public.route_expense_funds(
      p_transaction_id, v_source_wallet_id, v_use_all_wallets
    );
  end if;
  update public."transaction"
  set currency_code = v_wallet.currency_code
  where id = p_transaction_id and user_id = v_user_id;
  select coalesce(jsonb_agg(jsonb_build_object(
    'wallet_id', wallet_id
  )), '[]'::jsonb) into v_debits
  from public.transaction_wallet_debits
  where transaction_id = p_transaction_id and user_id = v_user_id;
  select * into v_tx from public."transaction"
  where id = p_transaction_id and user_id = v_user_id;

  return jsonb_build_object(
    'id', v_tx.id,
    'title', v_tx.title,
    'description', v_tx.description,
    'amount', v_tx.amount,
    'date', v_tx.date,
    'transaction_type', v_tx.transaction_type,
    'currency_code', v_tx.currency_code,
    'source_wallet_id', v_tx.source_wallet_id,
    'transaction_wallet_debits', v_debits,
    'category', jsonb_build_object(
      'id', v_category.id,
      'name', v_category.name,
      'icon_key', v_category.icon_key,
      'emoji', v_category.emoji
    )
  );
end;
$$;

create or replace function public.delete_finance_entry(
  p_transaction_id uuid
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then raise exception 'unauthorized'; end if;
  perform public.reverse_finance_entry_funds(p_transaction_id, v_user_id);
  delete from public."transaction"
  where id = p_transaction_id and user_id = v_user_id;
end;
$$;

revoke all on function public.update_finance_entry(
  uuid, text, text, bigint, timestamptz, text, uuid, uuid, date, boolean
) from public, anon;
grant execute on function public.update_finance_entry(
  uuid, text, text, bigint, timestamptz, text, uuid, uuid, date, boolean
) to authenticated;
revoke all on function public.delete_finance_entry(uuid) from public, anon;
grant execute on function public.delete_finance_entry(uuid) to authenticated;

commit;
