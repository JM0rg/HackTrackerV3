-- Field Mode rebuild: one replayable log per game.
--
-- Plate appearances and finished opponent halves share a sequence space, so a
-- game can be replayed, corrected mid-game, and undone one entry at a time.

-- Slowpitch has no bunt, so there is no sacrifice hit.
update public.plate_appearances set result = 'out' where result = 'sacrifice';

alter table public.plate_appearances
  alter column result type text using result::text;

drop type public.pa_result;

create type public.pa_result as enum (
  'single',
  'double',
  'triple',
  'homer',
  'walk',
  'strikeout',
  'out',
  'sac_fly',
  'fielders_choice',
  'reach_on_error'
);

alter table public.plate_appearances
  alter column result type public.pa_result using result::public.pa_result;

-- Scorer corrections. Null means the engine's own count stands.
alter table public.plate_appearances add column runs_on_play int;
alter table public.plate_appearances add column batter_scored boolean;

-- Runs tallied in the opponent half that is under way, plus the manual score
-- personal games keep by hand.
alter table public.games add column their_half_runs int not null default 0;
alter table public.games add column our_runs_adjust int not null default 0;
alter table public.games add column their_runs_adjust int not null default 0;

create type public.game_event_kind as enum ('their_half');

create table public.game_events (
  id uuid primary key default gen_random_uuid(),
  team_id uuid references public.teams (id) on delete cascade,
  game_id uuid not null references public.games (id) on delete cascade,
  sequence int not null,
  kind public.game_event_kind not null,
  runs int not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index game_events_game_id_idx
  on public.game_events (game_id)
  where deleted_at is null;

create trigger game_events_touch_updated_at
  before insert or update on public.game_events
  for each row execute function private.touch_updated_at();

alter table public.game_events enable row level security;

create policy game_events_select on public.game_events
  for select to authenticated
  using (
    (team_id is not null and private.is_team_member(team_id))
    or (
      team_id is null
      and game_id in (
        select id from public.games where kind = 'personal' and team_id is null
      )
    )
  );

create policy game_events_write_coach on public.game_events
  for all to authenticated
  using (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (
      team_id is null
      and game_id in (
        select id from public.games where kind = 'personal' and team_id is null
      )
    )
  )
  with check (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (
      team_id is null
      and game_id in (
        select id from public.games where kind = 'personal' and team_id is null
      )
    )
  );

grant select, insert, update, delete on public.game_events to authenticated;
