select
    extracted,
    id,
    get(payload, 'inward')::string as inward,
    get(payload, 'name')::string as name,
    get(payload, 'outward')::string as outward,
    get(payload, 'self')::string as self
from {{ref('issuelinktypes')}}
