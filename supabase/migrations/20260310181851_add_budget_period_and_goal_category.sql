begin;

alter table public.budgets
  add column if not exists period text not null default 'monthly';

alter table public.budgets
  add column if not exists last_reset_at timestamp with time zone not null default now();

alter table public.budgets
  drop constraint if exists budgets_period_check;

alter table public.budgets
  add constraint budgets_period_check
  check (period in ('weekly', 'biweekly', 'monthly', 'bimonthly', 'yearly'));

update public.budgets
set period = coalesce(period, 'monthly'),
    last_reset_at = coalesce(last_reset_at, created_at, now())
where period is null or last_reset_at is null;

alter table public.goals
  add column if not exists category uuid;

alter table public.goals
  drop constraint if exists goals_category_fkey;

alter table public.goals
  add constraint goals_category_fkey
  foreign key (category)
  references public.categories(id)
  on delete set null;

create index if not exists goals_category_idx on public.goals(category);
create index if not exists budgets_period_idx on public.budgets(period);

commit;
