begin;

create table if not exists public.envelopes (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  category_id uuid not null references public.categories(id) on delete cascade,
  name text not null check (char_length(trim(name)) between 1 and 80),
  amount bigint not null check (amount > 0),
  currency_code text not null default 'MGA'
    check (currency_code ~ '^[A-Z]{3}$'),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, category_id)
);

create index if not exists envelopes_user_id_idx
  on public.envelopes(user_id);

alter table public.envelopes enable row level security;

create policy "Users read own envelopes"
  on public.envelopes for select to authenticated
  using (user_id = (select auth.uid()));

create policy "Users insert own envelopes"
  on public.envelopes for insert to authenticated
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.categories
      where categories.id = category_id
        and categories.user_id = (select auth.uid())
        and categories.transaction_type = 'expense'
    )
  );

create policy "Users update own envelopes"
  on public.envelopes for update to authenticated
  using (user_id = (select auth.uid()))
  with check (
    user_id = (select auth.uid())
    and exists (
      select 1 from public.categories
      where categories.id = category_id
        and categories.user_id = (select auth.uid())
        and categories.transaction_type = 'expense'
    )
  );

create policy "Users delete own envelopes"
  on public.envelopes for delete to authenticated
  using (user_id = (select auth.uid()));

grant select, insert, update, delete on public.envelopes to authenticated;

commit;
