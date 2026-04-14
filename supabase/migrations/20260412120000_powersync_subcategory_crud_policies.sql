begin;

alter table public.subcategories enable row level security;
alter table public.subcategory_expenses enable row level security;

drop policy if exists "subcategories_select_own_category_powersync" on public.subcategories;
drop policy if exists "subcategories_insert_own_category_powersync" on public.subcategories;
drop policy if exists "subcategories_update_own_category_powersync" on public.subcategories;
drop policy if exists "subcategories_delete_own_category_powersync" on public.subcategories;

create policy "subcategories_select_own_category_powersync"
on public.subcategories
for select
to authenticated
using (
  exists (
    select 1
    from public.categories c
    where c.id = subcategories.category_id
      and c.user_id = auth.uid()
  )
);

create policy "subcategories_insert_own_category_powersync"
on public.subcategories
for insert
to authenticated
with check (
  exists (
    select 1
    from public.categories c
    where c.id = subcategories.category_id
      and c.user_id = auth.uid()
  )
);

create policy "subcategories_update_own_category_powersync"
on public.subcategories
for update
to authenticated
using (
  exists (
    select 1
    from public.categories c
    where c.id = subcategories.category_id
      and c.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.categories c
    where c.id = subcategories.category_id
      and c.user_id = auth.uid()
  )
);

create policy "subcategories_delete_own_category_powersync"
on public.subcategories
for delete
to authenticated
using (
  exists (
    select 1
    from public.categories c
    where c.id = subcategories.category_id
      and c.user_id = auth.uid()
  )
);

drop policy if exists "subcategory_expenses_select_own_transaction_powersync" on public.subcategory_expenses;
drop policy if exists "subcategory_expenses_insert_own_transaction_powersync" on public.subcategory_expenses;
drop policy if exists "subcategory_expenses_update_own_transaction_powersync" on public.subcategory_expenses;
drop policy if exists "subcategory_expenses_delete_own_transaction_powersync" on public.subcategory_expenses;

create policy "subcategory_expenses_select_own_transaction_powersync"
on public.subcategory_expenses
for select
to authenticated
using (
  exists (
    select 1
    from public.transaction t
    where t.id = subcategory_expenses.transaction_id
      and t.user_id = auth.uid()
  )
);

create policy "subcategory_expenses_insert_own_transaction_powersync"
on public.subcategory_expenses
for insert
to authenticated
with check (
  exists (
    select 1
    from public.transaction t
    where t.id = subcategory_expenses.transaction_id
      and t.user_id = auth.uid()
  )
  and exists (
    select 1
    from public.subcategories s
    join public.categories c on c.id = s.category_id
    where s.id = subcategory_expenses.sub_id
      and c.user_id = auth.uid()
  )
);

create policy "subcategory_expenses_update_own_transaction_powersync"
on public.subcategory_expenses
for update
to authenticated
using (
  exists (
    select 1
    from public.transaction t
    where t.id = subcategory_expenses.transaction_id
      and t.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.transaction t
    where t.id = subcategory_expenses.transaction_id
      and t.user_id = auth.uid()
  )
  and exists (
    select 1
    from public.subcategories s
    join public.categories c on c.id = s.category_id
    where s.id = subcategory_expenses.sub_id
      and c.user_id = auth.uid()
  )
);

create policy "subcategory_expenses_delete_own_transaction_powersync"
on public.subcategory_expenses
for delete
to authenticated
using (
  exists (
    select 1
    from public.transaction t
    where t.id = subcategory_expenses.transaction_id
      and t.user_id = auth.uid()
  )
);

commit;
