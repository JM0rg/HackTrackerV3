-- HackTracker only: uzyfohclwmkrqlfnlxxw.
-- Creating a team and assigning its owner must be one server transaction.
create or replace function private.assign_team_creator()
returns trigger language plpgsql security definer set search_path = '' as $$
begin
  if auth.uid() is null then raise exception 'authenticated creator required'; end if;
  insert into public.team_members(team_id, user_id, role)
  values (new.id, auth.uid(), 'owner');
  return new;
end;
$$;
revoke all on function private.assign_team_creator() from public, anon, authenticated;
create trigger assign_team_creator after insert on public.teams
for each row execute function private.assign_team_creator();

-- Support the policy names in both the checked-in baseline and live project.
do $$
declare p text;
begin
  for p in select policyname from pg_policies where schemaname='public'
    and tablename='team_members' and cmd='INSERT'
  loop
    execute format('alter policy %I on public.team_members with check (
      private.has_team_role(team_id, array[''owner'']) and role::text in (''coach'', ''player'', ''fan'')
      or private.has_team_role(team_id, array[''coach'']) and role::text in (''player'', ''fan'')
    )', p);
  end loop;
end;
$$;

alter policy invite_codes_write_coach on public.invite_codes
using (private.has_team_role(team_id, array['owner', 'coach']))
with check (
  private.has_team_role(team_id, array['owner']) and role::text in ('coach', 'player', 'fan')
  or private.has_team_role(team_id, array['coach']) and role::text in ('player', 'fan')
);

create or replace function public.join_team_with_code(p_code text)
returns uuid language plpgsql security definer set search_path = '' as $$
declare v_invite public.invite_codes%rowtype;
begin
  if auth.uid() is null then raise exception 'not authenticated'; end if;
  select * into v_invite from public.invite_codes
    where code = p_code and deleted_at is null
      and (expires_at is null or expires_at > now())
      and role::text in ('coach', 'player', 'fan');
  if not found then raise exception 'invalid invite'; end if;
  insert into public.team_members (team_id, user_id, role)
  values (v_invite.team_id, auth.uid(), v_invite.role)
  on conflict (team_id, user_id) do update
    set role = case when public.team_members.deleted_at is null
      then public.team_members.role else excluded.role end,
      deleted_at = null, updated_at = now();
  return v_invite.team_id;
end;
$$;
revoke all on function public.join_team_with_code(text) from public, anon;
grant execute on function public.join_team_with_code(text) to authenticated;
