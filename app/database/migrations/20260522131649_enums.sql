-- Enum types for HackTracker.
-- Idempotent: each type is created only if it does not already exist.
-- game_status and player_status intentionally stay text + CHECK (not enums).

do $$
begin
  if not exists (select 1 from pg_type where typname = 'team_type') then
    create type public.team_type as enum ('mens', 'womens', 'coed');
  end if;
end $$;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'member_role') then
    create type public.member_role as enum ('owner', 'coach', 'player', 'fan');
  end if;
end $$;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'group_type') then
    create type public.group_type as enum ('season', 'tournament');
  end if;
end $$;

do $$
begin
  if not exists (select 1 from pg_type where typname = 'home_away') then
    create type public.home_away as enum ('home', 'away', 'neutral');
  end if;
end $$;

-- Used by players.throws.
do $$
begin
  if not exists (select 1 from pg_type where typname = 'handedness') then
    create type public.handedness as enum ('left', 'right');
  end if;
end $$;

-- Used by players.bats.
do $$
begin
  if not exists (select 1 from pg_type where typname = 'batting_side') then
    create type public.batting_side as enum ('left', 'right', 'switch');
  end if;
end $$;
