-- Row Level Security: enable + force on every table, then policies.
-- No DELETE policies anywhere: deletion is soft (deleted_at) only.

-- profiles -------------------------------------------------------------------
alter table public.profiles enable row level security;
alter table public.profiles force row level security;

create policy profiles_select on public.profiles
  for select using (id = auth.uid());

create policy profiles_update on public.profiles
  for update using (id = auth.uid()) with check (id = auth.uid());

-- teams ----------------------------------------------------------------------
alter table public.teams enable row level security;
alter table public.teams force row level security;

create policy teams_select on public.teams
  for select using (public.is_team_member(id));

create policy teams_insert on public.teams
  for insert with check (owner_id = auth.uid());

create policy teams_update on public.teams
  for update using (public.has_team_role(id, array['owner']::public.member_role[]))
  with check (public.has_team_role(id, array['owner']::public.member_role[]));

-- team_members ---------------------------------------------------------------
alter table public.team_members enable row level security;
alter table public.team_members force row level security;

create policy team_members_select on public.team_members
  for select using (public.is_team_member(team_id));

create policy team_members_insert on public.team_members
  for insert with check (public.has_team_role(team_id, array['owner']::public.member_role[]));

create policy team_members_update on public.team_members
  for update using (public.has_team_role(team_id, array['owner']::public.member_role[]))
  with check (public.has_team_role(team_id, array['owner']::public.member_role[]));

-- players --------------------------------------------------------------------
alter table public.players enable row level security;
alter table public.players force row level security;

create policy players_select on public.players
  for select using (public.is_team_member(team_id));

create policy players_insert on public.players
  for insert with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));

create policy players_update on public.players
  for update using (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]))
  with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));

-- groups ---------------------------------------------------------------------
alter table public.groups enable row level security;
alter table public.groups force row level security;

create policy groups_select on public.groups
  for select using (public.is_team_member(team_id));

create policy groups_insert on public.groups
  for insert with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));

create policy groups_update on public.groups
  for update using (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]))
  with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));

-- games ----------------------------------------------------------------------
alter table public.games enable row level security;
alter table public.games force row level security;

create policy games_select on public.games
  for select using (public.is_team_member(team_id));

create policy games_insert on public.games
  for insert with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));

create policy games_update on public.games
  for update using (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]))
  with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));

-- game_groups ----------------------------------------------------------------
alter table public.game_groups enable row level security;
alter table public.game_groups force row level security;

create policy game_groups_select on public.game_groups
  for select using (public.is_team_member(team_id));

create policy game_groups_insert on public.game_groups
  for insert with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));

create policy game_groups_update on public.game_groups
  for update using (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]))
  with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));

-- lineups --------------------------------------------------------------------
alter table public.lineups enable row level security;
alter table public.lineups force row level security;

create policy lineups_select on public.lineups
  for select using (public.is_team_member(team_id));

create policy lineups_insert on public.lineups
  for insert with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));

create policy lineups_update on public.lineups
  for update using (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]))
  with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));

-- lineup_slots ---------------------------------------------------------------
alter table public.lineup_slots enable row level security;
alter table public.lineup_slots force row level security;

create policy lineup_slots_select on public.lineup_slots
  for select using (public.is_team_member(team_id));

create policy lineup_slots_insert on public.lineup_slots
  for insert with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));

create policy lineup_slots_update on public.lineup_slots
  for update using (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]))
  with check (public.has_team_role(team_id, array['owner', 'coach']::public.member_role[]));
