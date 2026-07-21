begin;

create table public.wallet_income_credits (
  transaction_id uuid primary key
    references public."transaction"(id) on delete cascade,
  wallet_id uuid not null references public.wallets(id),
  user_id uuid not null references auth.users(id) on delete cascade,
  amount bigint not null check (amount > 0),
  currency_code text not null check (currency_code ~ '^[A-Z]{3}$'),
  created_at timestamptz not null default now()
);

create index wallet_income_credits_user_idx
on public.wallet_income_credits(user_id);

alter table public.wallet_income_credits enable row level security;

create policy "Users can view their income wallet credits"
on public.wallet_income_credits for select to authenticated
using ((select auth.uid()) = user_id);

with new_credits as (
  insert into public.wallet_income_credits(
    transaction_id,
    wallet_id,
    user_id,
    amount,
    currency_code
  )
  select
    t.id,
    w.id,
    t.user_id,
    t.amount,
    t.currency_code
  from public."transaction" t
  join public.wallets w
    on w.user_id = t.user_id and w.is_default
  where t.transaction_type = 'income'
    and t.amount > 0
    and t.currency_code = w.currency_code
  on conflict (transaction_id) do nothing
  returning wallet_id, amount
),
credit_totals as (
  select wallet_id, sum(amount)::bigint as amount
  from new_credits
  group by wallet_id
)
update public.wallets w
set balance = w.balance + totals.amount,
    updated_at = now()
from credit_totals totals
where w.id = totals.wallet_id;

create or replace function public.credit_ai_income_to_default_wallet(
  p_request_id uuid,
  p_user_id uuid
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_wallet public.wallets%rowtype;
  v_credit_total bigint;
begin
  if not exists (
    select 1
    from public."transaction"
    where ai_request_id = p_request_id
      and user_id = p_user_id
      and transaction_type = 'income'
  ) then
    return;
  end if;

  select * into v_wallet
  from public.wallets
  where user_id = p_user_id and is_default
  for update;

  if v_wallet.id is null then
    insert into public.wallets(user_id, name, is_default)
    values (p_user_id, 'Main wallet', true)
    returning * into v_wallet;
  end if;

  if exists (
    select 1
    from public."transaction"
    where ai_request_id = p_request_id
      and user_id = p_user_id
      and transaction_type = 'income'
      and currency_code <> v_wallet.currency_code
  ) then
    raise exception 'wallet_currency_mismatch';
  end if;

  with new_credits as (
    insert into public.wallet_income_credits(
      transaction_id,
      wallet_id,
      user_id,
      amount,
      currency_code
    )
    select id, v_wallet.id, p_user_id, amount, currency_code
    from public."transaction"
    where ai_request_id = p_request_id
      and user_id = p_user_id
      and transaction_type = 'income'
    on conflict (transaction_id) do nothing
    returning amount
  )
  select coalesce(sum(amount), 0)::bigint
  into v_credit_total
  from new_credits;

  update public.wallets
  set balance = balance + v_credit_total, updated_at = now()
  where id = v_wallet.id and v_credit_total > 0;
end;
$$;

revoke all on function public.credit_ai_income_to_default_wallet(
  uuid, uuid
) from public, anon, authenticated;
grant execute on function public.credit_ai_income_to_default_wallet(
  uuid, uuid
) to service_role;

commit;
