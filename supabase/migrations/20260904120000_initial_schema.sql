-- HackTracker initial schema.
-- RLS helpers live in `private` (security definer, not exposed via the Data API).

create schema if not exists private;

create type public.team_type as enum ('mens', 'womens', 'coed');
create type public.team_role as enum ('owner', 'coach', 'player', 'fan');
create type public.competition_type as enum ('season', 'tournament');
create type public.game_status as enum ('scheduled', 'live', 'final', 'rainout', 'forfeit');
create type public.handedness as enum ('left', 'right', 'switch');
create type public.player_gender as enum ('male', 'female', 'undisclosed');
create type public.home_away as enum ('home', 'away');
create type public.field_position as enum (
  'P', 'C', '1B', '2B', '3B', 'SS', 'LF', 'LCF', 'RCF', 'RF', 'EH'
);
create type public.pa_result as enum (
  'single',
  'double',
  'triple',
  'homer',
  'walk',
  'strikeout',
  'out',
  'sac_fly',
  'sacrifice',
  'fielders_choice',
  'reach_on_error'
);
create type public.inning_half as enum ('top', 'bottom');

create or replace function private.touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  if new.updated_at is null then
    new.updated_at := now();
  end if;
  return new;
end;
$$;

create or replace function private.is_team_member(p_team_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.team_members tm
    where tm.team_id = p_team_id
      and tm.user_id = auth.uid()
      and tm.deleted_at is null
  );
$$;

create or replace function private.has_team_role(p_team_id uuid, p_roles text[])
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.team_members tm
    where tm.team_id = p_team_id
      and tm.user_id = auth.uid()
      and tm.deleted_at is null
      and tm.role::text = any (p_roles)
  );
$$;

create or replace function private.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.profiles (id, display_name, created_at, updated_at)
  values (
    new.id,
    coalesce(new.raw_user_meta_data ->> 'display_name', ''),
    now(),
    now()
  );
  return new;
end;
$$;

create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text not null default '',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.teams (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  type public.team_type not null default 'mens',
  settings jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.team_members (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete cascade,
  user_id uuid not null references auth.users (id) on delete cascade,
  role public.team_role not null default 'player',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (team_id, user_id)
);

create table public.invite_codes (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete cascade,
  code text not null unique,
  role public.team_role not null default 'player',
  expires_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.players (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete cascade,
  linked_user_id uuid references auth.users (id) on delete set null,
  first_name text not null,
  last_name text not null default '',
  jersey_number text,
  bats public.handedness not null default 'right',
  throws public.handedness not null default 'right',
  gender public.player_gender not null default 'undisclosed',
  status text not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.opponents (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete cascade,
  name text not null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.competitions (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete cascade,
  type public.competition_type not null,
  name text not null,
  league_name text,
  location text,
  starts_on date,
  ends_on date,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.games (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete cascade,
  opponent_id uuid references public.opponents (id) on delete set null,
  park text,
  starts_at timestamptz,
  home_away public.home_away not null default 'home',
  status public.game_status not null default 'scheduled',
  our_runs int not null default 0,
  their_runs int not null default 0,
  current_inning int not null default 1,
  current_half public.inning_half not null default 'bottom',
  outs int not null default 0,
  scorer_user_id uuid references auth.users (id) on delete set null,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.game_competitions (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete cascade,
  game_id uuid not null references public.games (id) on delete cascade,
  competition_id uuid not null references public.competitions (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (game_id, competition_id)
);

create table public.lineup_slots (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete cascade,
  game_id uuid not null references public.games (id) on delete cascade,
  player_id uuid not null references public.players (id) on delete cascade,
  batting_order int not null,
  position public.field_position,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.plate_appearances (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete cascade,
  game_id uuid not null references public.games (id) on delete cascade,
  player_id uuid not null references public.players (id) on delete cascade,
  sequence int not null,
  inning int not null,
  inning_half public.inning_half not null,
  result public.pa_result not null,
  rbi int not null default 0,
  runs_scored int not null default 0,
  outs_recorded int not null default 0,
  hit_location text,
  quality_of_contact text,
  fielder_player_id uuid references public.players (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table public.game_innings (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams (id) on delete cascade,
  game_id uuid not null references public.games (id) on delete cascade,
  inning int not null,
  our_runs int not null default 0,
  their_runs int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (game_id, inning)
);

create table public.sync_cursors (
  user_id uuid not null references auth.users (id) on delete cascade,
  table_name text not null,
  cursor timestamptz not null default '1970-01-01'::timestamptz,
  primary key (user_id, table_name)
);

create index players_team_id_idx on public.players (team_id) where deleted_at is null;
create index opponents_team_id_idx on public.opponents (team_id) where deleted_at is null;
create index competitions_team_id_idx on public.competitions (team_id) where deleted_at is null;
create index games_team_id_idx on public.games (team_id) where deleted_at is null;
create index games_updated_at_idx on public.games (updated_at);
create index plate_appearances_game_id_idx on public.plate_appearances (game_id) where deleted_at is null;
create index lineup_slots_game_id_idx on public.lineup_slots (game_id) where deleted_at is null;
create index team_members_user_id_idx on public.team_members (user_id) where deleted_at is null;

do $$
declare
  t text;
begin
  foreach t in array array[
    'profiles',
    'teams',
    'team_members',
    'invite_codes',
    'players',
    'opponents',
    'competitions',
    'games',
    'game_competitions',
    'lineup_slots',
    'plate_appearances',
    'game_innings'
  ]
  loop
    execute format(
      'create trigger %I_touch_updated_at before insert or update on public.%I for each row execute function private.touch_updated_at()',
      t,
      t
    );
  end loop;
end;
$$;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function private.handle_new_user();

alter table public.profiles enable row level security;
alter table public.teams enable row level security;
alter table public.team_members enable row level security;
alter table public.invite_codes enable row level security;
alter table public.players enable row level security;
alter table public.opponents enable row level security;
alter table public.competitions enable row level security;
alter table public.games enable row level security;
alter table public.game_competitions enable row level security;
alter table public.lineup_slots enable row level security;
alter table public.plate_appearances enable row level security;
alter table public.game_innings enable row level security;
alter table public.sync_cursors enable row level security;

create policy profiles_select_own on public.profiles
  for select to authenticated using (id = auth.uid());
create policy profiles_update_own on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
create policy profiles_insert_own on public.profiles
  for insert to authenticated with check (id = auth.uid());

create policy teams_select_member on public.teams
  for select to authenticated using (private.is_team_member(id));
create policy teams_insert_auth on public.teams
  for insert to authenticated with check (auth.uid() is not null);
create policy teams_update_coach on public.teams
  for update to authenticated
  using (private.has_team_role(id, array['owner', 'coach']))
  with check (private.has_team_role(id, array['owner', 'coach']));
create policy teams_delete_owner on public.teams
  for update to authenticated
  using (private.has_team_role(id, array['owner']));

create policy team_members_select on public.team_members
  for select to authenticated using (private.is_team_member(team_id) or user_id = auth.uid());
create policy team_members_insert_self_owner on public.team_members
  for insert to authenticated
  with check (
    user_id = auth.uid()
    or private.has_team_role(team_id, array['owner', 'coach'])
  );
create policy team_members_update_owner on public.team_members
  for update to authenticated
  using (private.has_team_role(team_id, array['owner']))
  with check (private.has_team_role(team_id, array['owner']));

create policy invite_codes_select on public.invite_codes
  for select to authenticated using (private.is_team_member(team_id));
create policy invite_codes_write_coach on public.invite_codes
  for all to authenticated
  using (private.has_team_role(team_id, array['owner', 'coach']))
  with check (private.has_team_role(team_id, array['owner', 'coach']));

-- Open read of invite code by exact match is handled in an RPC (join_team).

create or replace function public.join_team_with_code(p_code text)
returns uuid
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_invite public.invite_codes%rowtype;
begin
  if auth.uid() is null then
    raise exception 'not authenticated';
  end if;

  select * into v_invite
  from public.invite_codes
  where code = p_code
    and deleted_at is null
    and (expires_at is null or expires_at > now());

  if not found then
    raise exception 'invalid invite';
  end if;

  insert into public.team_members (team_id, user_id, role)
  values (v_invite.team_id, auth.uid(), v_invite.role)
  on conflict (team_id, user_id) do update
    set deleted_at = null,
        role = excluded.role,
        updated_at = now();

  return v_invite.team_id;
end;
$$;

create policy players_select on public.players
  for select to authenticated using (private.is_team_member(team_id));
create policy players_write_coach on public.players
  for all to authenticated
  using (private.has_team_role(team_id, array['owner', 'coach']))
  with check (private.has_team_role(team_id, array['owner', 'coach']));

create policy opponents_select on public.opponents
  for select to authenticated using (private.is_team_member(team_id));
create policy opponents_write_coach on public.opponents
  for all to authenticated
  using (private.has_team_role(team_id, array['owner', 'coach']))
  with check (private.has_team_role(team_id, array['owner', 'coach']));

create policy competitions_select on public.competitions
  for select to authenticated using (private.is_team_member(team_id));
create policy competitions_write_coach on public.competitions
  for all to authenticated
  using (private.has_team_role(team_id, array['owner', 'coach']))
  with check (private.has_team_role(team_id, array['owner', 'coach']));

create policy games_select on public.games
  for select to authenticated using (private.is_team_member(team_id));
create policy games_write_coach on public.games
  for all to authenticated
  using (private.has_team_role(team_id, array['owner', 'coach']))
  with check (private.has_team_role(team_id, array['owner', 'coach']));

create policy game_competitions_select on public.game_competitions
  for select to authenticated using (private.is_team_member(team_id));
create policy game_competitions_write_coach on public.game_competitions
  for all to authenticated
  using (private.has_team_role(team_id, array['owner', 'coach']))
  with check (private.has_team_role(team_id, array['owner', 'coach']));

create policy lineup_slots_select on public.lineup_slots
  for select to authenticated using (private.is_team_member(team_id));
create policy lineup_slots_write_coach on public.lineup_slots
  for all to authenticated
  using (private.has_team_role(team_id, array['owner', 'coach']))
  with check (private.has_team_role(team_id, array['owner', 'coach']));

create policy plate_appearances_select on public.plate_appearances
  for select to authenticated using (private.is_team_member(team_id));
create policy plate_appearances_write_coach on public.plate_appearances
  for all to authenticated
  using (private.has_team_role(team_id, array['owner', 'coach']))
  with check (private.has_team_role(team_id, array['owner', 'coach']));

create policy game_innings_select on public.game_innings
  for select to authenticated using (private.is_team_member(team_id));
create policy game_innings_write_coach on public.game_innings
  for all to authenticated
  using (private.has_team_role(team_id, array['owner', 'coach']))
  with check (private.has_team_role(team_id, array['owner', 'coach']));

create policy sync_cursors_own on public.sync_cursors
  for all to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

grant usage on schema private to postgres, service_role;
grant execute on function private.is_team_member(uuid) to authenticated, anon;
grant execute on function private.has_team_role(uuid, text[]) to authenticated, anon;
grant execute on function public.join_team_with_code(text) to authenticated;

grant select, insert, update, delete on all tables in schema public to authenticated;
