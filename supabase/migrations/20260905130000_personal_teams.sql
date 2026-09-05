-- Teams a person plays with in personal games. Metadata only: a name to tag
-- games with. Unrelated to public.teams, which carry rosters and members.
create table public.personal_teams (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references public.people (id) on delete cascade,
  name text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz
);

create index personal_teams_person_id_idx
  on public.personal_teams (person_id)
  where deleted_at is null;

create trigger personal_teams_touch_updated_at
  before insert or update on public.personal_teams
  for each row execute function private.touch_updated_at();

alter table public.personal_teams enable row level security;

create policy personal_teams_own on public.personal_teams
  for all to authenticated
  using (
    person_id in (select id from public.people where linked_user_id = auth.uid())
  )
  with check (
    person_id in (select id from public.people where linked_user_id = auth.uid())
  );

grant select, insert, update, delete on public.personal_teams to authenticated;

-- Games keep the name they were tagged with, plus the team it came from.
alter table public.games
  add column played_for_team_id uuid
  references public.personal_teams (id) on delete set null;
