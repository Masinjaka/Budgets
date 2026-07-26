begin;

create table if not exists public.receipt_scans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  storage_paths text[] not null,
  mime_types text[] not null,
  source text not null check (source in ('camera', 'file')),
  status text not null default 'uploaded'
    check (status in ('uploaded', 'processing', 'processed', 'failed')),
  extracted_data jsonb,
  error_message text,
  created_at timestamptz not null default now(),
  processed_at timestamptz,
  constraint receipt_scan_files_present check (
    cardinality(storage_paths) between 1 and 10
    and cardinality(storage_paths) = cardinality(mime_types)
  )
);

create index if not exists receipt_scans_user_created_idx
  on public.receipt_scans(user_id, created_at desc);

alter table public.receipt_scans enable row level security;

create policy "Users read own receipt scans"
on public.receipt_scans for select to authenticated
using (user_id = (select auth.uid()));

create policy "Users create own receipt scans"
on public.receipt_scans for insert to authenticated
with check (user_id = (select auth.uid()));

create policy "Users delete own receipt scans"
on public.receipt_scans for delete to authenticated
using (user_id = (select auth.uid()));

grant select, insert, delete on public.receipt_scans to authenticated;
grant all on public.receipt_scans to service_role;

insert into storage.buckets (
  id, name, public, file_size_limit, allowed_mime_types
) values (
  'receipts', 'receipts', false, 15728640,
  array['image/jpeg', 'image/png', 'application/pdf']
)
on conflict (id) do update set
  public = false,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

create policy "Users upload own receipts"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'receipts'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "Users read own receipts"
on storage.objects for select to authenticated
using (
  bucket_id = 'receipts'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

create policy "Users delete own receipts"
on storage.objects for delete to authenticated
using (
  bucket_id = 'receipts'
  and (storage.foldername(name))[1] = (select auth.uid())::text
);

commit;
