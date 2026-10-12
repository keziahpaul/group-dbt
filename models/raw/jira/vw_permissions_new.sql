select
    extracted,
    id,
    get(payload, 'description')::string as description,
    get(payload, 'key')::string as key,
    get(payload, 'name')::string as name,
    get(payload, 'type')::string as type
from {{ref('permissions')}}
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