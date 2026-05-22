-- Roster + schedule tables: players, groups, games, game_groups.

create table if not exists public.players (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  name text not null,
  jersey_number text,
  throws public.handedness,
  bats public.batting_side,
  gender text check (gender is null or gender in ('male', 'female', 'nonbinary', 'unspecified')),
  status text not null default 'full_time' check (status in ('full_time', 'sub', 'inactive', 'injured')),
  default_positions text[] not null default '{}' check (default_positions <@ '{P,C,1B,2B,3B,SS,LF,LCF,RCF,RF,EH}'::text[]),
  phone text,
  email text,
  linked_user_id uuid references public.profiles(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.groups (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  name text not null,
  group_type public.group_type not null,
  league_name text,
  location text,
  start_date date,
  end_date date check (end_date is null or start_date is null or end_date >= start_date),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.games (
  id uuid primary key default gen_random_uuid(),
  team_id uuid not null references public.teams(id) on delete cascade,
  opponent_name text,
  park_name text,
  city_or_address text,
  start_time timestamptz,
  home_away public.home_away not null default 'home',
  status text not null default 'scheduled' check (status in ('scheduled', 'live', 'final', 'postponed', 'cancelled')),
  our_score int check (our_score is null or our_score >= 0),
  opp_score int check (opp_score is null or opp_score >= 0),
  notes text,
  result text generated always as (case when status <> 'final' or our_score is null or opp_score is null then null when our_score > opp_score then 'W' when our_score < opp_score then 'L' else 'T' end) stored,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create table if not exists public.game_groups (
  id uuid primary key default gen_random_uuid(),
  game_id uuid not null references public.games(id) on delete cascade,
  group_id uuid not null references public.groups(id) on delete cascade,
  team_id uuid not null references public.teams(id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  unique (game_id, group_id)
);
