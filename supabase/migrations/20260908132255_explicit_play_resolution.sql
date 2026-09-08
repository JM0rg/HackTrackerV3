-- HackTracker only. Draft gestures stay device-local and are not synchronized.
alter table public.plate_appearances
  add column resolution text,
  add column batter_was_male boolean;
alter table public.game_events add column payload text;
