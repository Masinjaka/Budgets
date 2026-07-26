begin;

revoke all on public.finance_notifications from anon, authenticated;
grant select on public.finance_notifications to authenticated;
grant update (is_read) on public.finance_notifications to authenticated;

commit;
