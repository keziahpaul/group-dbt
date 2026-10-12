select
    extracted,
    id,
    get(payload, 'description')::string as description,
    get(payload, 'isDefault')::boolean as isDefault,
    get(payload, 'name')::string as name,
    get(payload, 'self')::string as self
from {{ref('resolutions')}}
