-- Storage: private 'team-logos' bucket + object-level policies.
-- Object path convention: <team_id>/<filename>, so the first path segment
-- (storage.foldername(name))[1] is the team id used for authorization.

insert into storage.buckets (id, name, public)
values ('team-logos', 'team-logos', false)
on conflict (id) do nothing;

-- Read: any active member of the owning team.
create policy team_logos_select on storage.objects
  for select using (
    bucket_id = 'team-logos'
    and public.is_team_member((storage.foldername(name))[1]::uuid)
  );

-- Insert: owner/coach of the owning team.
create policy team_logos_insert on storage.objects
  for insert with check (
    bucket_id = 'team-logos'
    and public.has_team_role((storage.foldername(name))[1]::uuid, array['owner', 'coach']::public.member_role[])
  );

-- Update: owner/coach of the owning team.
create policy team_logos_update on storage.objects
  for update using (
    bucket_id = 'team-logos'
    and public.has_team_role((storage.foldername(name))[1]::uuid, array['owner', 'coach']::public.member_role[])
  ) with check (
    bucket_id = 'team-logos'
    and public.has_team_role((storage.foldername(name))[1]::uuid, array['owner', 'coach']::public.member_role[])
  );

-- Delete: owner/coach of the owning team (storage objects are hard-deleted).
create policy team_logos_delete on storage.objects
  for delete using (
    bucket_id = 'team-logos'
    and public.has_team_role((storage.foldername(name))[1]::uuid, array['owner', 'coach']::public.member_role[])
  );
