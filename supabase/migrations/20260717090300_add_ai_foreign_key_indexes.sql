begin;

create index if not exists ai_chat_messages_request_idx
  on public.ai_chat_messages(request_id);
create index if not exists transaction_ai_request_idx
  on public."transaction"(ai_request_id)
  where ai_request_id is not null;

commit;
