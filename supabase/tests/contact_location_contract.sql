-- Read-only contract test; no fixtures or user data changes.
do $$
declare c record;
begin
  for c in select * from (values
    (null::text,true),('LF',true),('{"v":1,"x":0.3,"y":0.7,"flight":"line","bats":"right"}',true),
    ('{"v":1}',true),('{"v":1,"region":"SS"}',true),('{"v":1,"x":9,"y":0}',false),
    ('{"v":1,"x":0}',false),('{"v":1,"x":null,"y":null}',false),('{"v":1,"bats":"switch"}',false),
    ('{"v":2}',false),('garbage',false)
  ) as cases(source,expected) loop
    if public.valid_contact_location(c.source) is distinct from c.expected then
      raise exception 'Unexpected contact validation: %', c.source;
    end if;
  end loop;
end $$;
