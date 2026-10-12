select
    extracted,
    id,
    get(payload, 'description')::string as description,
    get(payload, 'iconUrl')::string as iconUrl,
    get(payload, 'isDefault')::boolean as isDefault,
    get(payload, 'name')::string as name,
    get(payload, 'self')::string as self,
    get(payload, 'statusColor')::string as statusColor
from {{ref('priorities')}}
