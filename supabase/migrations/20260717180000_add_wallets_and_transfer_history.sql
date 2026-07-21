begin;

create table public.wallets (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 80),
  balance bigint not null default 0 check (balance >= 0),
  currency_code text not null default 'MGA'
    check (currency_code ~ '^[A-Z]{3}$'),
  icon_key text not null default 'wallet',
  is_default boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create unique index wallets_user_name_unique
on public.wallets(user_id, lower(name));

create unique index wallets_one_default_per_user
on public.wallets(user_id) where is_default;

create table public.wallet_transfers (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  from_wallet_id uuid not null,
  to_wallet_id uuid not null,
  amount bigint not null check (amount > 0),
  currency_code text not null check (currency_code ~ '^[A-Z]{3}$'),
  description text not null default '',
  occurred_at timestamptz not null default now(),
  ai_request_id uuid references public.ai_requests(id) on delete set null,
  created_at timestamptz not null default now(),
  constraint wallet_transfer_distinct_wallets
    check (from_wallet_id <> to_wallet_id),
  constraint wallet_transfer_from_wallet_fkey
    foreign key (from_wallet_id) references public.wallets(id),
  constraint wallet_transfer_to_wallet_fkey
    foreign key (to_wallet_id) references public.wallets(id)
);

create index wallet_transfers_user_date_idx
on public.wallet_transfers(user_id, occurred_at desc);

alter table public.wallets enable row level security;
alter table public.wallet_transfers enable row level security;

create policy "Users can view their wallets"
on public.wallets for select to authenticated
using ((select auth.uid()) = user_id);

create policy "Users can create their wallets"
on public.wallets for insert to authenticated
with check ((select auth.uid()) = user_id);

create policy "Users can update their wallets"
on public.wallets for update to authenticated
using ((select auth.uid()) = user_id)
with check ((select auth.uid()) = user_id);

create policy "Users can delete non-default wallets"
on public.wallets for delete to authenticated
using ((select auth.uid()) = user_id and not is_default);

create policy "Users can view their wallet transfers"
on public.wallet_transfers for select to authenticated
using ((select auth.uid()) = user_id);

create or replace function public.create_default_wallet()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.wallets(user_id, name, is_default)
  values (new.id, 'Main wallet', true)
  on conflict do nothing;
  return new;
end;
$$;

create trigger create_wallet_after_signup
after insert on auth.users
for each row execute function public.create_default_wallet();

insert into public.wallets(user_id, name, is_default)
select u.id, 'Main wallet', true
from auth.users u
where not exists (
  select 1 from public.wallets w where w.user_id = u.id
);

revoke all on function public.create_default_wallet()
from public, anon, authenticated;

commit;
