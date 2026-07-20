begin;

alter table public.categories
  add column if not exists icon_key text not null default 'other';

create table if not exists public.category_presets (
  slug text primary key,
  name text not null,
  emoji text not null,
  color text not null,
  icon_key text not null,
  transaction_type text not null
    check (transaction_type in ('income', 'expense')),
  aliases text[] not null default '{}',
  created_at timestamptz not null default now()
);

insert into public.category_presets
  (slug, name, emoji, color, icon_key, transaction_type, aliases)
values
  ('food', 'Foods & Drinks', '🍔', 'FFFF9800', 'food', 'expense',
    array['food', 'restaurant', 'groceries', 'drink']),
  ('shopping', 'Shopping', '🛒', 'FF9C27B0', 'shopping', 'expense',
    array['shopping', 'clothes', 'gift']),
  ('transport', 'Transportation', '🚕', 'FF2196F3', 'transport', 'expense',
    array['transport', 'taxi', 'bus', 'fuel']),
  ('housing', 'Housing', '🏠', 'FF795548', 'housing', 'expense',
    array['rent', 'housing', 'mortgage']),
  ('health', 'Health', '🏥', 'FFF44336', 'health', 'expense',
    array['health', 'doctor', 'pharmacy']),
  ('entertainment', 'Entertainment', '🎬', 'FF673AB7', 'entertainment',
    'expense', array['movie', 'games', 'entertainment']),
  ('education', 'Education', '🎓', 'FF3F51B5', 'education', 'expense',
    array['school', 'course', 'books']),
  ('utilities', 'Utilities', '💡', 'FF607D8B', 'utilities', 'expense',
    array['electricity', 'water', 'internet', 'phone']),
  ('salary', 'Salary', '💼', 'FF4CAF50', 'salary', 'income',
    array['salary', 'wage', 'paycheck']),
  ('freelance', 'Freelance', '🧑‍💻', 'FF009688', 'freelance', 'income',
    array['freelance', 'contract', 'consulting']),
  ('other_expense', 'Other', '🧾', 'FF9E9E9E', 'other', 'expense',
    array['other', 'miscellaneous']),
  ('other_income', 'Other income', '💰', 'FF8BC34A', 'income', 'income',
    array['other income', 'bonus'])
on conflict (slug) do update set
  name = excluded.name,
  emoji = excluded.emoji,
  color = excluded.color,
  icon_key = excluded.icon_key,
  transaction_type = excluded.transaction_type,
  aliases = excluded.aliases;

create table if not exists public.ai_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  provider text not null,
  model text not null,
  prompt text not null check (char_length(prompt) between 1 and 1000),
  status text not null default 'processing'
    check (status in ('processing', 'succeeded', 'failed')),
  error_code text,
  provider_response jsonb,
  input_tokens integer,
  output_tokens integer,
  created_at timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.ai_chat_messages (
  id uuid primary key default gen_random_uuid(),
  request_id uuid not null references public.ai_requests(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  role text not null check (role in ('user', 'assistant')),
  content text not null,
  metadata jsonb not null default '{}',
  created_at timestamptz not null default now()
);

alter table public."transaction"
  add column if not exists ai_request_id uuid
    references public.ai_requests(id) on delete set null,
  add column if not exists currency_code text not null default 'MGA';

create unique index if not exists categories_user_name_type_uidx
  on public.categories
  (user_id, lower(name), coalesce(transaction_type, 'expense'));
create index if not exists ai_requests_user_created_idx
  on public.ai_requests(user_id, created_at desc);
create index if not exists ai_chat_messages_user_created_idx
  on public.ai_chat_messages(user_id, created_at desc);
create index if not exists transaction_user_date_idx
  on public."transaction"(user_id, date desc);

alter table public.category_presets enable row level security;
alter table public.ai_requests enable row level security;
alter table public.ai_chat_messages enable row level security;

drop policy if exists "Authenticated users read category presets"
  on public.category_presets;
create policy "Authenticated users read category presets"
  on public.category_presets for select to authenticated using (true);

drop policy if exists "Users read own AI requests" on public.ai_requests;
create policy "Users read own AI requests"
  on public.ai_requests for select to authenticated
  using (user_id = (select auth.uid()));

drop policy if exists "Users read own AI chat messages"
  on public.ai_chat_messages;
create policy "Users read own AI chat messages"
  on public.ai_chat_messages for select to authenticated
  using (user_id = (select auth.uid()));

revoke all on public.ai_requests from anon, authenticated;
revoke all on public.ai_chat_messages from anon, authenticated;
grant select on public.ai_requests to authenticated;
grant select on public.ai_chat_messages to authenticated;
grant select on public.category_presets to authenticated;

commit;
