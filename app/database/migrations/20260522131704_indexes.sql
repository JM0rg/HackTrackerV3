-- Secondary + partial indexes. Partial indexes exclude soft-deleted rows.

create index if not exists idx_teams_owner_id
  on public.teams (owner_id)
  where deleted_at is null;

create index if not exists idx_team_members_user_id
  on public.team_members (user_id)
  where deleted_at is null;

create index if not exists idx_team_members_team_id_role
  on public.team_members (team_id, role)
  where deleted_at is null;

create index if not exists idx_players_team_id
  on public.players (team_id)
  where deleted_at is null;

create index if not exists idx_players_linked_user_id
  on public.players (linked_user_id)
  where linked_user_id is not null and deleted_at is null;

create index if not exists idx_groups_team_id_group_type
  on public.groups (team_id, group_type)
  where deleted_at is null;

create index if not exists idx_games_team_id_start_time
  on public.games (team_id, start_time)
  where deleted_at is null;

create index if not exists idx_games_team_id_status
  on public.games (team_id, status)
  where deleted_at is null;

create index if not exists idx_game_groups_group_id
  on public.game_groups (group_id)
  where deleted_at is null;

create index if not exists idx_lineups_game_id
  on public.lineups (game_id)
  where deleted_at is null;

create index if not exists idx_lineup_slots_lineup_id
  on public.lineup_slots (lineup_id)
  where deleted_at is null;
