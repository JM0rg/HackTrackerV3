-- How an out was made. Optional; a strikeout stays its own result.
alter table public.plate_appearances
  add column out_kind text
  check (out_kind is null or out_kind in ('fly', 'ground', 'line'));
