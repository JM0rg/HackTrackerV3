-- Lineup tables: lineups, lineup_slots.

create table if not exists public.lineups (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references public.games(id) on delete cascade,
  team_id uuid not null references public.teams(id) on delete cascade,
  name text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.lineup_slots (
  id uuid primary key default gen_random_uuid(),
  lineup_id uuid not null references public.lineups(id) on delete cascade,
  team_id uuid not null references public.teams(id) on delete cascade,
  player_id uuid not null references public.players(id) on delete restrict,
  batting_order int not null check (batting_order >= 1),
  field_position text check (field_position is null or field_position = any('{P,C,1B,2B,3B,SS,LF,LCF,RCF,RF,EH}'::text[])),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (lineup_id, batting_order)
);
