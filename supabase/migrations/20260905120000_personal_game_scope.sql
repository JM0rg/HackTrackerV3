-- Personal games choose what to keep: just at-bats, or at-bats plus both
-- teams' scores. A scoring personal game ends our half by hand.
alter type public.game_event_kind add value if not exists 'our_half';

alter table public.games
  add column scope text not null default 'game'
  check (scope in ('bat', 'game'));
alter table public.games add column our_half_runs int not null default 0;

-- Manual score keeping is gone; every run is now an event in the log.
alter table public.games drop column our_runs_adjust;
alter table public.games drop column their_runs_adjust;
