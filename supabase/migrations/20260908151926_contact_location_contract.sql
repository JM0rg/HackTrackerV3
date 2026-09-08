-- Preserve existing region-only text while accepting versioned contact estimates.
-- This validator is pure, SECURITY INVOKER, and does not read user data.
create or replace function public.valid_contact_location(source text)
returns boolean language plpgsql immutable parallel safe
set search_path = pg_catalog
as $$
declare m jsonb; x numeric; y numeric;
begin
  if source is null then return true; end if;
  if source = any(array['P','C','1B','2B','SS','3B','LF','LCF','CF','RCF','RF']) then return true; end if;
  if length(source)>2048 then return false; end if;
  m := source::jsonb;
  if jsonb_typeof(m)<>'object' or m->'v' is distinct from '1'::jsonb then return false; end if;
  if (m ? 'x') <> (m ? 'y') then return false; end if;
  if m ? 'x' then
    if jsonb_typeof(m->'x')<>'number' or jsonb_typeof(m->'y')<>'number' then return false; end if;
    x:=(m->>'x')::numeric; y:=(m->>'y')::numeric;
    if abs(x)>1.2 or y< -0.15 or y>1.2 or x*x+y*y>1.5625 then return false; end if;
  end if;
  if m ? 'region' and not coalesce(m->>'region'=any(array['P','C','1B','2B','SS','3B','LF','LCF','CF','RCF','RF']),false) then return false; end if;
  if m ? 'flight' and not coalesce(m->>'flight'=any(array['ground','line','fly','popup']),false) then return false; end if;
  if m ? 'bats' and not coalesce(m->>'bats'=any(array['left','right']),false) then return false; end if;
  return true;
exception when others then return false;
end $$;
alter table public.plate_appearances
 add constraint plate_appearances_contact_location_valid check (public.valid_contact_location(hit_location)) not valid;
alter table public.plate_appearances validate constraint plate_appearances_contact_location_valid;
comment on column public.plate_appearances.hit_location is 'Legacy region code or v1 JSON: x/y relative to home in fence-radius units (CF=0,1), optional region, flight, bats. Estimated first-fielded/landing point, not measured distance. Missing point must not be inferred.';
