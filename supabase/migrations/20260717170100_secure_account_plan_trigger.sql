begin;

revoke all on function public.create_default_account_plan()
from public, anon, authenticated;

commit;
