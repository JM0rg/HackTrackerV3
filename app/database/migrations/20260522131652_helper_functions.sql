-- RLS helper functions + the generic updated_at trigger function.

-- True if the current user is an active member of the given team.
create or replace function public.is_team_member(p_team_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.team_members tm
    where tm.team_id = p_team_id
      and tm.user_id = auth.uid()
      and tm.deleted_at is null
  );
$$;

-- True if the current user is an active member of the team holding any of the
-- given roles.
create or replace function public.has_team_role(p_team_id uuid, p_roles public.member_role[])
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.team_members tm
    where tm.team_id = p_team_id
      and tm.user_id = auth.uid()
      and tm.deleted_at is null
      and tm.role = any(p_roles)
  );
$$;

-- Generic BEFORE UPDATE trigger: stamp updated_at to now().
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;
