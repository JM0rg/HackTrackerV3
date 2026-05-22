-- Trigger functions + trigger bindings.

-- Auto-create an owner membership row when a team is inserted.
create or replace function public.create_owner_membership()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.team_members (team_id, user_id, role)
  values (new.id, new.owner_id, 'owner')
  on conflict do nothing;
  return new;
end;
$$;

-- Mirror a new auth.users row into public.profiles.
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, avatar_path)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name'),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict do nothing;
  return new;
end;
$$;

-- Resolve a child row's team_id from its parent so callers don't have to set
-- it (and can't set it inconsistently). lineups & game_groups derive from
-- games; lineup_slots derives from lineups.
create or replace function public.sync_child_team_id()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_table_name = 'lineups' then
    select g.team_id into new.team_id from public.games g where g.id = new.game_id;
  elsif tg_table_name = 'game_groups' then
    select g.team_id into new.team_id from public.games g where g.id = new.game_id;
  elsif tg_table_name = 'lineup_slots' then
    select l.team_id into new.team_id from public.lineups l where l.id = new.lineup_id;
  end if;
  return new;
end;
$$;

-- updated_at bindings: BEFORE UPDATE on every table.
create trigger trg_set_updated_at_profiles
  before update on public.profiles
  for each row execute function public.set_updated_at();

create trigger trg_set_updated_at_teams
  before update on public.teams
  for each row execute function public.set_updated_at();

create trigger trg_set_updated_at_team_members
  before update on public.team_members
  for each row execute function public.set_updated_at();

create trigger trg_set_updated_at_players
  before update on public.players
  for each row execute function public.set_updated_at();

create trigger trg_set_updated_at_groups
  before update on public.groups
  for each row execute function public.set_updated_at();

create trigger trg_set_updated_at_games
  before update on public.games
  for each row execute function public.set_updated_at();

create trigger trg_set_updated_at_game_groups
  before update on public.game_groups
  for each row execute function public.set_updated_at();

create trigger trg_set_updated_at_lineups
  before update on public.lineups
  for each row execute function public.set_updated_at();

create trigger trg_set_updated_at_lineup_slots
  before update on public.lineup_slots
  for each row execute function public.set_updated_at();

-- Owner-membership binding.
create trigger trg_create_owner_membership
  after insert on public.teams
  for each row execute function public.create_owner_membership();

-- New-user profile binding (on the auth schema's users table).
create trigger trg_handle_new_user
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- team_id resolution bindings.
create trigger trg_sync_child_team_id_lineups
  before insert or update on public.lineups
  for each row execute function public.sync_child_team_id();

create trigger trg_sync_child_team_id_game_groups
  before insert or update on public.game_groups
  for each row execute function public.sync_child_team_id();

create trigger trg_sync_child_team_id_lineup_slots
  before insert or update on public.lineup_slots
  for each row execute function public.sync_child_team_id();
