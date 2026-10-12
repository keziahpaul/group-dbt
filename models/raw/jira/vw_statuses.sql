select
    extracted,
    id,
    get(payload, 'description')::string as description,
    get(payload, 'name')::string as name,
    get(payload, 'scope')::variant as scope,
    get(payload, 'statusCategory')::string as statusCategory
from {{ref('statuses')}}
