begin;

revoke all on function public.delete_user()
  from public, anon, authenticated;

commit;
