-- HackTracker only: uzyfohclwmkrqlfnlxxw. Additive scoring projections.
-- Keep requested result separately from effective stat credit.
alter table public.games add column settings_snapshot text;
alter table public.plate_appearances add column effective_result text;
update public.games g set settings_snapshot = coalesce(
  (select t.settings::text from public.teams t where t.id = g.team_id), '{}'
);
