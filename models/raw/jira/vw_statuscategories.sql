select
    extracted,
    id,
    get(payload, 'colorName')::string as colorName,
    get(payload, 'key')::string as key,
    get(payload, 'name')::string as name,
    get(payload, 'self')::string as self
from {{ref('statuscategories')}}
