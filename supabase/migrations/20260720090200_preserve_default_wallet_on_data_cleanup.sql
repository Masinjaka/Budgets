begin;

create or replace function public.cleanup_user_app_data(
  p_user_id uuid,
  p_recreate_profile boolean default false
) returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_email text;
  v_profile_ids uuid[];
begin
  if p_user_id is null then
    raise exception 'invalid_user';
  end if;

  select email into v_email from auth.users where id = p_user_id;
  select coalesce(array_agg(id), '{}'::uuid[]) into v_profile_ids
  from public."user" where user_id = p_user_id;

  delete from public.subcategory_expenses
  where transaction_id in (
    select id from public."transaction" where user_id = p_user_id
  ) or sub_id in (
    select s.id from public.subcategories s
    join public.categories c on c.id = s.category_id
    where c.user_id = p_user_id
  );

  if to_regclass('public.transaction_wallet_debits') is not null then
    execute 'delete from public.transaction_wallet_debits where user_id = $1'
      using p_user_id;
  end if;

  delete from public.wallet_income_credits where user_id = p_user_id;
  delete from public.budget_notification_log where user_id = p_user_id;
  delete from public.budget_history where user_id = p_user_id;
  delete from public."transaction" where user_id = p_user_id;
  delete from public.wallet_transfers where user_id = p_user_id;
  delete from public.ai_chat_messages where user_id = p_user_id;
  delete from public.ai_requests where user_id = p_user_id;
  delete from public.envelopes where user_id = p_user_id;
  delete from public.budgets where user_id = p_user_id;
  delete from public.goals where user_id = p_user_id;
  delete from public.subscriptions
  where user_id = p_user_id or user_id = any(v_profile_ids);
  delete from public.subcategories where category_id in (
    select id from public.categories where user_id = p_user_id
  );
  delete from public.categories where user_id = p_user_id;

  if p_recreate_profile then
    delete from public.wallets
    where user_id = p_user_id and not is_default;
    update public.wallets
    set balance = 0, updated_at = now()
    where user_id = p_user_id and is_default;
    insert into public.wallets(user_id, name, is_default)
    select p_user_id, 'Main wallet', true
    where not exists (
      select 1 from public.wallets
      where user_id = p_user_id and is_default
    );
  else
    delete from public.wallets where user_id = p_user_id;
  end if;

  delete from public.device_tokens where user_id = p_user_id;
  delete from public.notification_settings where user_id = p_user_id;
  delete from public."user" where user_id = p_user_id;

  if p_recreate_profile and v_email is not null then
    insert into public."user" (user_id, username, profile_photo, currency_code)
    values (p_user_id, split_part(v_email, '@', 1), null, 'MGA')
    on conflict (user_id) do update set
      username = excluded.username,
      profile_photo = null,
      currency_code = excluded.currency_code;
  end if;
end;
$$;

revoke all on function public.cleanup_user_app_data(uuid, boolean)
  from public, anon, authenticated;
grant execute on function public.cleanup_user_app_data(uuid, boolean)
  to service_role;

commit;
