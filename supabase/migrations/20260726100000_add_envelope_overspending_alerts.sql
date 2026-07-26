begin;

alter table public.envelopes
  add column overspent_amount bigint not null default 0
    check (overspent_amount >= 0);

with envelope_shortfalls as (
  select
    tx.envelope_id,
    coalesce(sum(debit.amount), 0)::bigint as amount
  from public."transaction" tx
  join public.transaction_wallet_debits debit
    on debit.transaction_id = tx.id
  where tx.envelope_id is not null
    and tx.transaction_type = 'expense'
  group by tx.envelope_id
)
update public.envelopes envelope
set amount = greatest(envelope.amount - shortfall.amount, 0),
    overspent_amount = shortfall.amount,
    updated_at = now()
from envelope_shortfalls shortfall
where envelope.id = shortfall.envelope_id;

create table public.finance_notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  notification_type text not null
    check (notification_type in ('envelope_overspent')),
  envelope_id uuid not null
    references public.envelopes(id) on delete cascade,
  transaction_id uuid not null
    references public."transaction"(id) on delete cascade,
  envelope_name text not null,
  amount bigint not null check (amount > 0),
  period_month date not null,
  is_read boolean not null default false,
  created_at timestamptz not null default now(),
  unique (transaction_id, notification_type)
);

create index finance_notifications_user_unread_idx
  on public.finance_notifications(user_id, is_read, created_at desc);

alter table public.finance_notifications enable row level security;

create policy "Users read own finance notifications"
  on public.finance_notifications for select to authenticated
  using ((select auth.uid()) = user_id);

create policy "Users update own finance notifications"
  on public.finance_notifications for update to authenticated
  using ((select auth.uid()) = user_id)
  with check ((select auth.uid()) = user_id);

revoke all on public.finance_notifications from anon, authenticated;
grant select on public.finance_notifications to authenticated;
grant update (is_read) on public.finance_notifications to authenticated;

commit;
