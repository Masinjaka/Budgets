begin;

create or replace function public.reserve_ai_request(
  p_user_id uuid,
  p_provider text,
  p_model text,
  p_prompt text,
  p_daily_limit integer default 20,
  p_min_interval_seconds integer default 3
) returns jsonb
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_count integer;
  v_last_created timestamptz;
  v_request_id uuid;
  v_retry_after integer;
begin
  if p_user_id is null or char_length(trim(p_prompt)) not between 1 and 1000 then
    raise exception 'invalid_request';
  end if;

  perform pg_catalog.pg_advisory_xact_lock(
    pg_catalog.hashtextextended(p_user_id::text, 0)
  );

  select max(created_at) into v_last_created
  from public.ai_requests
  where user_id = p_user_id;

  if v_last_created is not null
      and v_last_created > now() - make_interval(secs => p_min_interval_seconds)
  then
    v_retry_after := greatest(
      1,
      ceil(extract(epoch from (
        v_last_created + make_interval(secs => p_min_interval_seconds) - now()
      )))::integer
    );
    return jsonb_build_object(
      'allowed', false,
      'code', 'rate_limited',
      'retry_after_seconds', v_retry_after
    );
  end if;

  select count(*)::integer into v_count
  from public.ai_requests
  where user_id = p_user_id
    and created_at >= date_trunc('day', now());

  if v_count >= p_daily_limit then
    return jsonb_build_object(
      'allowed', false,
      'code', 'daily_limit_exceeded',
      'remaining', 0
    );
  end if;

  insert into public.ai_requests(user_id, provider, model, prompt)
  values (p_user_id, p_provider, p_model, trim(p_prompt))
  returning id into v_request_id;

  insert into public.ai_chat_messages(
    request_id, user_id, role, content
  ) values (
    v_request_id, p_user_id, 'user', trim(p_prompt)
  );

  return jsonb_build_object(
    'allowed', true,
    'request_id', v_request_id,
    'remaining', p_daily_limit - v_count - 1
  );
end;
$$;

create or replace function public.fail_ai_request(
  p_request_id uuid,
  p_user_id uuid,
  p_error_code text,
  p_message text,
  p_provider_response jsonb default null
) returns void
language plpgsql
security definer
set search_path = ''
as $$
begin
  update public.ai_requests
  set status = 'failed',
      error_code = left(p_error_code, 80),
      provider_response = p_provider_response,
      completed_at = now()
  where id = p_request_id and user_id = p_user_id;

  if found then
    insert into public.ai_chat_messages(
      request_id, user_id, role, content, metadata
    ) values (
      p_request_id,
      p_user_id,
      'assistant',
      left(p_message, 1000),
      jsonb_build_object('error_code', p_error_code)
    );
  end if;
end;
$$;

revoke all on function public.reserve_ai_request(
  uuid, text, text, text, integer, integer
) from public, anon, authenticated;
grant execute on function public.reserve_ai_request(
  uuid, text, text, text, integer, integer
) to service_role;

revoke all on function public.fail_ai_request(
  uuid, uuid, text, text, jsonb
) from public, anon, authenticated;
grant execute on function public.fail_ai_request(
  uuid, uuid, text, text, jsonb
) to service_role;

commit;
