create table public.people (
  id uuid primary key default gen_random_uuid(),
  display_name text not null default 'Me',
  first_name text not null default 'Me',
  last_name text not null default '',
  linked_user_id uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create unique index people_linked_user_id_uidx
  on public.people (linked_user_id)
  where linked_user_id is not null and deleted_at is null;

create trigger people_touch_updated_at
  before insert or update on public.people
  for each row execute function private.touch_updated_at();

alter table public.people enable row level security;

create policy people_select_own on public.people
  for select to authenticated
  using (linked_user_id = auth.uid());
create policy people_insert_own on public.people
  for insert to authenticated
  with check (linked_user_id = auth.uid());
create policy people_update_own on public.people
  for update to authenticated
  using (linked_user_id = auth.uid())
  with check (linked_user_id = auth.uid());

grant select, insert, update, delete on public.people to authenticated;

create type public.game_kind as enum ('team', 'personal');

alter table public.players drop column linked_user_id;
alter table public.players alter column team_id drop not null;
alter table public.players
  add column person_id uuid references public.people (id) on delete set null;

alter table public.games alter column team_id drop not null;
alter table public.games
  add column kind public.game_kind not null default 'team';
alter table public.games add column opponent_name text;
alter table public.games add column played_for_name text;

alter table public.plate_appearances alter column team_id drop not null;
alter table public.plate_appearances
  add column person_id uuid references public.people (id) on delete set null;

alter table public.lineup_slots alter column team_id drop not null;
alter table public.game_innings alter column team_id drop not null;

create index players_person_id_idx
  on public.players (person_id)
  where deleted_at is null;
create index plate_appearances_person_id_idx
  on public.plate_appearances (person_id)
  where deleted_at is null;
create index games_kind_idx
  on public.games (kind)
  where deleted_at is null;

drop policy players_select on public.players;
drop policy players_write_coach on public.players;
create policy players_select on public.players
  for select to authenticated
  using (
    (team_id is not null and private.is_team_member(team_id))
    or (
      team_id is null
      and person_id in (
        select id from public.people where linked_user_id = auth.uid()
      )
    )
  );
create policy players_write_coach on public.players
  for all to authenticated
  using (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (
      team_id is null
      and person_id in (
        select id from public.people where linked_user_id = auth.uid()
      )
    )
  )
  with check (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (
      team_id is null
      and person_id in (
        select id from public.people where linked_user_id = auth.uid()
      )
    )
  );

drop policy games_select on public.games;
drop policy games_write_coach on public.games;
create policy games_select on public.games
  for select to authenticated
  using (
    (team_id is not null and private.is_team_member(team_id))
    or (
      team_id is null
      and kind = 'personal'
      and id in (
        select ls.game_id
        from public.lineup_slots ls
        join public.players p on p.id = ls.player_id
        join public.people pe on pe.id = p.person_id
        where pe.linked_user_id = auth.uid()
          and ls.deleted_at is null
      )
    )
  );
create policy games_write_coach on public.games
  for all to authenticated
  using (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (
      team_id is null
      and kind = 'personal'
      and id in (
        select ls.game_id
        from public.lineup_slots ls
        join public.players p on p.id = ls.player_id
        join public.people pe on pe.id = p.person_id
        where pe.linked_user_id = auth.uid()
          and ls.deleted_at is null
      )
    )
  )
  with check (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (team_id is null and kind = 'personal')
  );

drop policy lineup_slots_select on public.lineup_slots;
drop policy lineup_slots_write_coach on public.lineup_slots;
create policy lineup_slots_select on public.lineup_slots
  for select to authenticated
  using (
    (team_id is not null and private.is_team_member(team_id))
    or (
      team_id is null
      and game_id in (select id from public.games where kind = 'personal' and team_id is null)
    )
  );
create policy lineup_slots_write_coach on public.lineup_slots
  for all to authenticated
  using (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (
      team_id is null
      and game_id in (select id from public.games where kind = 'personal' and team_id is null)
    )
  )
  with check (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (
      team_id is null
      and game_id in (select id from public.games where kind = 'personal' and team_id is null)
    )
  );

drop policy plate_appearances_select on public.plate_appearances;
drop policy plate_appearances_write_coach on public.plate_appearances;
create policy plate_appearances_select on public.plate_appearances
  for select to authenticated
  using (
    (team_id is not null and private.is_team_member(team_id))
    or (person_id in (select id from public.people where linked_user_id = auth.uid()))
  );
create policy plate_appearances_write_coach on public.plate_appearances
  for all to authenticated
  using (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (person_id in (select id from public.people where linked_user_id = auth.uid()))
  )
  with check (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (person_id in (select id from public.people where linked_user_id = auth.uid()))
  );

drop policy game_innings_select on public.game_innings;
drop policy game_innings_write_coach on public.game_innings;
create policy game_innings_select on public.game_innings
  for select to authenticated
  using (
    (team_id is not null and private.is_team_member(team_id))
    or (
      team_id is null
      and game_id in (select id from public.games where kind = 'personal' and team_id is null)
    )
  );
create policy game_innings_write_coach on public.game_innings
  for all to authenticated
  using (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (
      team_id is null
      and game_id in (select id from public.games where kind = 'personal' and team_id is null)
    )
  )
  with check (
    (team_id is not null and private.has_team_role(team_id, array['owner', 'coach']))
    or (
      team_id is null
      and game_id in (select id from public.games where kind = 'personal' and team_id is null)
    )
  );
