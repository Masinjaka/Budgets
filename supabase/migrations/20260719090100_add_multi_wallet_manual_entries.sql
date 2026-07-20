begin;

create or replace function public.create_manual_finance_entry(
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
  v_category public.categories%rowtype;
  v_wallet public.wallets%rowtype;
  v_transaction_id uuid;
  v_occurred_at timestamptz;
  v_default_name text;
begin
  if v_user_id is null then raise exception 'unauthorized'; end if;
  if p_amount <= 0 then raise exception 'invalid_transaction_amount'; end if;
  if p_transaction_type not in ('expense', 'income') then
    raise exception 'invalid_transaction_type';
  end if;

  if p_category_id is not null then
    select * into v_category from public.categories
    where id = p_category_id and user_id = v_user_id
      and coalesce(transaction_type, 'expense') = p_transaction_type;
  end if;
  if v_category.id is null then
    v_default_name := case when p_transaction_type = 'income'
      then 'Other income' else 'Other' end;
    insert into public.categories(
      user_id, name, emoji, color, icon_key, transaction_type
    ) values (
      v_user_id, v_default_name,
      case when p_transaction_type = 'income' then '💰' else '🧾' end,
      case when p_transaction_type = 'income'
        then 'FF8BC34A' else 'FF9E9E9E' end,
      case when p_transaction_type = 'income' then 'income' else 'other' end,
      p_transaction_type
    ) on conflict (
      user_id, lower(name), coalesce(transaction_type, 'expense')
    ) do update set name = excluded.name returning * into v_category;
  end if;

  select * into v_wallet from public.wallets
  where user_id = v_user_id and is_default for update;
  if v_wallet.id is null then
    insert into public.wallets(user_id, name, is_default)
    values (v_user_id, 'Main wallet', true) returning * into v_wallet;
  end if;

  v_occurred_at := least(coalesce(p_occurred_at, now()), now());
  insert into public."transaction"(
    user_id, title, description, amount, date, category_id,
    transaction_type, currency_code, ledger_month
  ) values (
    v_user_id,
    left(coalesce(nullif(trim(p_title), ''), v_category.name), 120),
    left(coalesce(p_description, ''), 500),
    p_amount, v_occurred_at, v_category.id, p_transaction_type,
    v_wallet.currency_code, date_trunc('month', p_period_month)::date
  ) returning id into v_transaction_id;

  if p_transaction_type = 'income' then
    insert into public.wallet_income_credits(
      transaction_id, wallet_id, user_id, amount, currency_code
    ) values (
      v_transaction_id, v_wallet.id, v_user_id,
      p_amount, v_wallet.currency_code
    );
    update public.wallets set balance = balance + p_amount, updated_at = now()
    where id = v_wallet.id;
  else
    perform public.route_expense_funds(
      v_transaction_id, p_source_wallet_id, p_use_all_wallets
    );
  end if;

  return jsonb_build_object(
    'id', v_transaction_id,
    'title', coalesce(nullif(trim(p_title), ''), v_category.name),
    'description', coalesce(p_description, ''),
    'amount', p_amount,
    'date', v_occurred_at,
    'transaction_type', p_transaction_type,
    'currency_code', v_wallet.currency_code,
    'category', jsonb_build_object(
      'id', v_category.id,
      'name', v_category.name,
      'icon_key', v_category.icon_key,
      'emoji', v_category.emoji
    )
  );
end;
$$;

revoke all on function public.create_manual_finance_entry(
  text, text, bigint, timestamptz, text, uuid, uuid, date, boolean
) from public, anon;
grant execute on function public.create_manual_finance_entry(
  text, text, bigint, timestamptz, text, uuid, uuid, date, boolean
) to authenticated;
revoke execute on function public.create_manual_finance_entry(
  text, text, bigint, timestamptz, text, uuid, uuid, date
) from authenticated;

commit;
