{# maintained for compatibility -#}
select
    id as permission,
    description,
    key,
    name,
    type,
    extracted as inserted_at
from {{ref('vw_permissions_new')}}
{#- prior version of this was
SELECT 
    permission_key as permission,
    permission_data:description::STRING as description,
    permission_data:key::STRING as key,
    permission_data:name::STRING as name,
    permission_data:type::STRING as type,
    inserted_at
FROM permissions
-#}