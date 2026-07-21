begin;

alter table public.envelopes
  add column period_month date,
  add column remaining_amount bigint not null default 0
    check (remaining_amount >= 0),
  add column funding_wallet_id uuid
    references public.wallets(id) on delete restrict;

update public.envelopes
set period_month = date_trunc('month', created_at)::date
where period_month is null;

with envelope_totals as (
  select user_id, sum(amount)::bigint as total
  from public.envelopes
  group by user_id
),
fundable as (
  select w.id, w.user_id, totals.total
  from public.wallets w
  join envelope_totals totals using (user_id)
  where w.is_default and w.balance >= totals.total
),
debited as (
  update public.wallets w
  set balance = balance - fundable.total,
      updated_at = now()
  from fundable
  where w.id = fundable.id
  returning w.id, w.user_id
)
update public.envelopes e
set remaining_amount = e.amount,
    funding_wallet_id = debited.id
from debited
where e.user_id = debited.user_id;

alter table public.envelopes
  alter column period_month set not null,
  alter column period_month set default date_trunc('month', now())::date;

alter table public.envelopes
  drop constraint if exists envelopes_user_id_category_id_key;
alter table public.envelopes
  add constraint envelopes_user_category_month_key
  unique (user_id, category_id, period_month);

create index envelopes_user_period_idx
  on public.envelopes(user_id, period_month);
create index envelopes_funding_wallet_idx
  on public.envelopes(funding_wallet_id);

alter table public."transaction"
  add column ledger_month date;
update public."transaction"
set ledger_month = date_trunc('month', date)::date
where ledger_month is null;
alter table public."transaction"
  alter column ledger_month set not null,
  alter column ledger_month set default date_trunc('month', now())::date;

create or replace function public.set_default_wallet(p_wallet_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
begin
  if v_user_id is null then raise exception 'unauthorized'; end if;
  if not exists (
    select 1 from public.wallets
    where id = p_wallet_id and user_id = v_user_id
  ) then
    raise exception 'wallet_not_found';
  end if;
  update public.wallets set is_default = false, updated_at = now()
  where user_id = v_user_id and is_default;
  update public.wallets set is_default = true, updated_at = now()
  where id = p_wallet_id and user_id = v_user_id;
end;
$$;

create or replace function public.fund_envelope(
  p_name text,
  p_category_id uuid,
  p_amount bigint,
  p_period_month date,
  p_wallet_id uuid default null
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_user_id uuid := auth.uid();
  v_wallet public.wallets%rowtype;
  v_category public.categories%rowtype;
  v_envelope_id uuid;
  v_month date := date_trunc('month', p_period_month)::date;
begin
  if v_user_id is null then raise exception 'unauthorized'; end if;
  if p_amount <= 0 then raise exception 'invalid_envelope_amount'; end if;
  select * into v_category from public.categories
  where id = p_category_id and user_id = v_user_id
    and transaction_type = 'expense';
  if v_category.id is null then raise exception 'category_not_found'; end if;

  select * into v_wallet from public.wallets
  where user_id = v_user_id
    and (id = p_wallet_id or (p_wallet_id is null and is_default))
  order by (id = p_wallet_id) desc
  limit 1 for update;
  if v_wallet.id is null then raise exception 'wallet_not_found'; end if;
  if v_wallet.balance < p_amount then
    raise exception 'wallet_selection_required:%', p_amount;
  end if;

  update public.wallets
  set balance = balance - p_amount, updated_at = now()
  where id = v_wallet.id;
  insert into public.envelopes(
    user_id, category_id, name, amount, remaining_amount,
    currency_code, period_month, funding_wallet_id
  ) values (
    v_user_id, v_category.id, trim(p_name), p_amount, p_amount,
    v_wallet.currency_code, v_month, v_wallet.id
  ) returning id into v_envelope_id;

  return jsonb_build_object(
    'id', v_envelope_id,
    'name', trim(p_name),
    'category_id', v_category.id,
    'amount', p_amount,
    'remaining_amount', p_amount,
    'currency_code', v_wallet.currency_code,
    'period_month', v_month,
    'category', jsonb_build_object(
      'name', v_category.name,
      'emoji', v_category.emoji,
      'color', v_category.color
    )
  );
end;
$$;

revoke all on function public.set_default_wallet(uuid) from public, anon;
grant execute on function public.set_default_wallet(uuid) to authenticated;
revoke all on function public.fund_envelope(
  text, uuid, bigint, date, uuid
) from public, anon;
grant execute on function public.fund_envelope(
  text, uuid, bigint, date, uuid
) to authenticated;

commit;
