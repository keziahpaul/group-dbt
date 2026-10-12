select
    extracted,
    id,
    get(payload, 'name')::string as name
from {{ref('groups')}}
