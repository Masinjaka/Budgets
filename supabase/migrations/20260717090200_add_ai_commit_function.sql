begin;

create or replace function public.complete_ai_request(
  p_request_id uuid,
  p_user_id uuid,
  p_provider_response jsonb,
  p_transactions jsonb,
  p_categories jsonb default '[]',
  p_input_tokens integer default null,
  p_output_tokens integer default null
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_item jsonb;
  v_category_id uuid;
  v_name text;
  v_requested_name text;
  v_type text;
  v_icon text;
  v_emoji text;
  v_color text;
  v_transaction_id uuid;
  v_entries jsonb := '[]'::jsonb;
  v_daily_count integer;
begin
  if jsonb_typeof(p_transactions) <> 'array'
      or jsonb_array_length(p_transactions) > 10
      or jsonb_typeof(p_categories) <> 'array'
      or jsonb_array_length(p_categories) > 10 then
    raise exception 'invalid_ai_result';
  end if;

  if not exists (
    select 1 from public.ai_requests
    where id = p_request_id
      and user_id = p_user_id
      and status = 'processing'
  ) then
    raise exception 'invalid_ai_request';
  end if;

  for v_item in select value from jsonb_array_elements(p_categories)
  loop
    v_name := nullif(trim(v_item->>'name'), '');
    v_type := case when v_item->>'transaction_type' = 'income'
      then 'income' else 'expense' end;
    if v_name is not null then
      insert into public.categories(
        user_id, name, emoji, color, icon_key, transaction_type
      ) values (
        p_user_id,
        v_name,
        coalesce(nullif(v_item->>'emoji', ''), '🧾'),
        coalesce(nullif(v_item->>'color', ''), 'FF9E9E9E'),
        'other',
        v_type
      ) on conflict (
        user_id, lower(name), coalesce(transaction_type, 'expense')
      ) do nothing;
    end if;
  end loop;

  for v_item in select value from jsonb_array_elements(p_transactions)
  loop
    v_requested_name := nullif(trim(v_item->>'category_name'), '');
    v_type := case when v_item->>'transaction_type' = 'income'
      then 'income' else 'expense' end;
    v_category_id := null;
    v_name := null;
    v_emoji := null;
    v_color := null;
    v_icon := null;
    if v_requested_name is null
        or coalesce((v_item->>'amount')::numeric, 0) <= 0 then
      raise exception 'invalid_transaction';
    end if;

    select c.id, c.name, c.emoji, c.color, c.icon_key
    into v_category_id, v_name, v_emoji, v_color, v_icon
    from public.categories c
    where c.user_id = p_user_id
      and lower(c.name) = lower(v_requested_name)
      and coalesce(c.transaction_type, 'expense') = v_type
    limit 1;

    if v_category_id is null then
      select p.name, p.emoji, p.color, p.icon_key
      into v_name, v_emoji, v_color, v_icon
      from public.category_presets p
      where p.transaction_type = v_type
        and (
          lower(p.name) = lower(v_requested_name)
          or exists (
            select 1
            from unnest(p.aliases) as alias(value)
            where lower(alias.value) = lower(v_requested_name)
          )
        )
      limit 1;

      v_name := coalesce(v_name, v_requested_name);
      insert into public.categories(
        user_id, name, emoji, color, icon_key, transaction_type
      ) values (
        p_user_id,
        v_name,
        coalesce(v_emoji, '🧾'),
        coalesce(v_color, 'FF9E9E9E'),
        coalesce(v_icon, 'other'),
        v_type
      ) on conflict (
        user_id, lower(name), coalesce(transaction_type, 'expense')
      ) do update set name = excluded.name
      returning id into v_category_id;
    end if;

    insert into public."transaction"(
      user_id,
      title,
      description,
      amount,
      date,
      category_id,
      transaction_type,
      ai_request_id,
      currency_code
    ) values (
      p_user_id,
      left(coalesce(nullif(trim(v_item->>'title'), ''), v_name), 120),
      left(coalesce(v_item->>'description', ''), 500),
      round((v_item->>'amount')::numeric)::bigint,
      least(coalesce((v_item->>'occurred_at')::timestamptz, now()), now()),
      v_category_id,
      v_type,
      p_request_id,
      upper(left(coalesce(nullif(v_item->>'currency_code', ''), 'MGA'), 3))
    ) returning id into v_transaction_id;

    v_entries := v_entries || jsonb_build_array(jsonb_build_object(
      'id', v_transaction_id,
      'title', coalesce(nullif(trim(v_item->>'title'), ''), v_name),
      'description', coalesce(v_item->>'description', ''),
      'amount', round((v_item->>'amount')::numeric),
      'date', least(coalesce((v_item->>'occurred_at')::timestamptz, now()), now()),
      'transaction_type', v_type,
      'currency_code', upper(left(coalesce(
        nullif(v_item->>'currency_code', ''), 'MGA'
      ), 3)),
      'category', jsonb_build_object(
        'id', v_category_id,
        'name', v_name,
        'icon_key', coalesce(v_icon, 'other'),
        'emoji', coalesce(v_emoji, '🧾')
      )
    ));
  end loop;

  update public.ai_requests
  set status = 'succeeded',
      provider_response = p_provider_response,
      input_tokens = p_input_tokens,
      output_tokens = p_output_tokens,
      completed_at = now()
  where id = p_request_id and user_id = p_user_id;

  insert into public.ai_chat_messages(
    request_id, user_id, role, content, metadata
  ) values (
    p_request_id,
    p_user_id,
    'assistant',
    p_provider_response::text,
    jsonb_build_object('entry_count', jsonb_array_length(v_entries))
  );

  select count(*)::integer into v_daily_count
  from public.ai_requests
  where user_id = p_user_id
    and created_at >= date_trunc('day', now());

  return jsonb_build_object(
    'entries', v_entries,
    'remaining', greatest(0, 20 - v_daily_count)
  );
end;
$$;

revoke all on function public.complete_ai_request(
  uuid, uuid, jsonb, jsonb, jsonb, integer, integer
) from public, anon, authenticated;
grant execute on function public.complete_ai_request(
  uuid, uuid, jsonb, jsonb, jsonb, integer, integer
) to service_role;

commit;
