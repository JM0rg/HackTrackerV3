-- Privilege grants. RLS still governs row visibility; these grants only open
-- the schema/table/function surface to the client roles.

grant usage on schema public to authenticated;

-- Table privileges. No DELETE: deletion is soft (deleted_at) via UPDATE.
grant select, insert, update on public.profiles to authenticated;
grant select, insert, update on public.teams to authenticated;
grant select, insert, update on public.team_members to authenticated;
grant select, insert, update on public.players to authenticated;
grant select, insert, update on public.groups to authenticated;
grant select, insert, update on public.games to authenticated;
grant select, insert, update on public.game_groups to authenticated;
grant select, insert, update on public.lineups to authenticated;
grant select, insert, update on public.lineup_slots to authenticated;

-- Function execute grants. DROP FUNCTION discards grants, so every function
-- created in this migration set has an explicit grant line here.
grant execute on function public.is_team_member(uuid) to authenticated;
grant execute on function public.is_team_member(uuid) to anon;
grant execute on function public.has_team_role(uuid, public.member_role[]) to authenticated;
grant execute on function public.has_team_role(uuid, public.member_role[]) to anon;
grant execute on function public.set_updated_at() to authenticated;
grant execute on function public.create_owner_membership() to authenticated;
grant execute on function public.handle_new_user() to authenticated;
grant execute on function public.sync_child_team_id() to authenticated;
