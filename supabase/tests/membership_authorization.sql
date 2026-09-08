-- Execute only on HackTracker uzyfohclwmkrqlfnlxxw. All fixtures roll back.
begin;
do $$
declare owner_id uuid := gen_random_uuid(); outsider_id uuid := gen_random_uuid();
  fixture_team_id uuid := gen_random_uuid(); denied boolean := false;
begin
  insert into auth.users(id) values(owner_id), (outsider_id);
  perform set_config('request.jwt.claim.sub', owner_id::text, true);
  set local role authenticated;
  insert into public.teams(id, name) values(fixture_team_id, 'Authorization regression fixture');
  if not exists(select 1 from public.team_members m where m.team_id = fixture_team_id
      and m.user_id = owner_id and m.role = 'owner') then
    raise exception 'team creator was not made owner';
  end if;
  perform set_config('request.jwt.claim.sub', outsider_id::text, true);
  begin
    insert into public.team_members(team_id, user_id, role)
      values(fixture_team_id, outsider_id, 'owner');
  exception when insufficient_privilege then denied := true;
  end;
  if not denied then raise exception 'self-enrollment allowed'; end if;
  if exists(select 1 from public.teams t where t.id = fixture_team_id) then
    raise exception 'outsider can read team';
  end if;
  perform set_config('request.jwt.claim.sub', owner_id::text, true);
  insert into public.invite_codes(team_id, code, role)
    values(fixture_team_id, 'fixture-' || fixture_team_id::text, 'player');
  perform public.join_team_with_code('fixture-' || fixture_team_id::text);
  if not exists(select 1 from public.team_members m where m.team_id = fixture_team_id
      and m.user_id = owner_id and m.role = 'owner') then
    raise exception 'accepting player invitation demoted owner';
  end if;
  perform set_config('request.jwt.claim.sub', outsider_id::text, true);
  perform public.join_team_with_code('fixture-' || fixture_team_id::text);
  if not exists(select 1 from public.team_members m where m.team_id = fixture_team_id
      and m.user_id = outsider_id and m.role = 'player') then
    raise exception 'invited player could not join';
  end if;
  reset role;
end;
$$;
rollback;
select 'membership authorization regressions passed; fixtures rolled back' as result;
