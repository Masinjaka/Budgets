-- Profiles are now read and written directly by authenticated clients.
delete from public."user" older
using public."user" newer
where older.user_id = newer.user_id
  and older.id > newer.id;

create unique index if not exists user_user_id_unique
  on public."user"(user_id);

create or replace function public.create_user_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public."user" (
    user_id,
    username,
    profile_photo,
    currency_code
  )
  values (
    new.id,
    coalesce(
      nullif(new.raw_user_meta_data ->> 'username', ''),
      split_part(coalesce(new.email, ''), '@', 1),
      'Utilisateur'
    ),
    nullif(new.raw_user_meta_data ->> 'profile_photo', ''),
    coalesce(
      nullif(new.raw_user_meta_data ->> 'currency_code', ''),
      'MGA'
    )
  )
  on conflict (user_id) do nothing;
  return new;
end;
$$;

drop trigger if exists create_user_profile_after_signup on auth.users;
create trigger create_user_profile_after_signup
after insert on auth.users
for each row execute function public.create_user_profile();

insert into public."user" (user_id, username, profile_photo, currency_code)
select
  au.id,
  coalesce(
    nullif(au.raw_user_meta_data ->> 'username', ''),
    split_part(coalesce(au.email, ''), '@', 1),
    'Utilisateur'
  ),
  nullif(au.raw_user_meta_data ->> 'profile_photo', ''),
  coalesce(
    nullif(au.raw_user_meta_data ->> 'currency_code', ''),
    'MGA'
  )
from auth.users au
on conflict (user_id) do nothing;

-- Remove policies created specifically for the retired sync layer.
drop policy if exists "subcategories_select_own_category_powersync"
  on public.subcategories;
drop policy if exists "subcategories_insert_own_category_powersync"
  on public.subcategories;
drop policy if exists "subcategories_update_own_category_powersync"
  on public.subcategories;
drop policy if exists "subcategories_delete_own_category_powersync"
  on public.subcategories;
drop policy if exists "Enable select for authenticated users"
  on public.subcategories;

create policy "Users read subcategories in own categories"
on public.subcategories for select to authenticated
using (
  exists (
    select 1 from public.categories c
    where c.id = category_id and c.user_id = (select auth.uid())
  )
);
create policy "Users insert subcategories in own categories"
on public.subcategories for insert to authenticated
with check (
  exists (
    select 1 from public.categories c
    where c.id = category_id and c.user_id = (select auth.uid())
  )
);
create policy "Users update subcategories in own categories"
on public.subcategories for update to authenticated
using (
  exists (
    select 1 from public.categories c
    where c.id = category_id and c.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1 from public.categories c
    where c.id = category_id and c.user_id = (select auth.uid())
  )
);
create policy "Users delete subcategories in own categories"
on public.subcategories for delete to authenticated
using (
  exists (
    select 1 from public.categories c
    where c.id = category_id and c.user_id = (select auth.uid())
  )
);

drop policy if exists "subcategory_expenses_select_own_transaction_powersync"
  on public.subcategory_expenses;
drop policy if exists "subcategory_expenses_insert_own_transaction_powersync"
  on public.subcategory_expenses;
drop policy if exists "subcategory_expenses_update_own_transaction_powersync"
  on public.subcategory_expenses;
drop policy if exists "subcategory_expenses_delete_own_transaction_powersync"
  on public.subcategory_expenses;
drop policy if exists "Enable read access for all users"
  on public.subcategory_expenses;

create policy "Users read own subcategory expenses"
on public.subcategory_expenses for select to authenticated
using (
  exists (
    select 1 from public."transaction" t
    where t.id = transaction_id and t.user_id = (select auth.uid())
  )
);
create policy "Users insert own subcategory expenses"
on public.subcategory_expenses for insert to authenticated
with check (
  exists (
    select 1 from public."transaction" t
    where t.id = transaction_id and t.user_id = (select auth.uid())
  )
);
create policy "Users update own subcategory expenses"
on public.subcategory_expenses for update to authenticated
using (
  exists (
    select 1 from public."transaction" t
    where t.id = transaction_id and t.user_id = (select auth.uid())
  )
)
with check (
  exists (
    select 1 from public."transaction" t
    where t.id = transaction_id and t.user_id = (select auth.uid())
  )
);
create policy "Users delete own subcategory expenses"
on public.subcategory_expenses for delete to authenticated
using (
  exists (
    select 1 from public."transaction" t
    where t.id = transaction_id and t.user_id = (select auth.uid())
  )
);

drop policy if exists "Enable insert for authenticated users only"
  on public."user";
create policy "Users insert own profile"
on public."user" for insert to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists "Enable insert for authenticated users only"
  on public.categories;
create policy "Users insert own categories"
on public.categories for insert to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists "Enable insert for users based on user_id"
  on public.budgets;
create policy "Users insert own budgets"
on public.budgets for insert to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists "Enable insert for authenticated users only"
  on public.budget_history;
create policy "Users insert own budget history"
on public.budget_history for insert to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists "Enable insert for authenticated users only"
  on public."transaction";
create policy "Users insert own transactions"
on public."transaction" for insert to authenticated
with check (user_id = (select auth.uid()));

drop policy if exists "Users update own transactions"
  on public."transaction";
create policy "Users update own transactions"
on public."transaction" for update to authenticated
using (user_id = (select auth.uid()))
with check (user_id = (select auth.uid()));
