select
    extracted,
    id,
    get(payload, 'avatarId')::number as avatarId,
    get(payload, 'description')::string as description,
    get(payload, 'hierarchyLevel')::number as hierarchyLevel,
    get(payload, 'iconUrl')::string as iconUrl,
    get(payload, 'name')::string as name,
    get(payload, 'scope')::variant as scope,
    get(payload, 'self')::string as self,
    get(payload, 'subtask')::boolean as subtask,
    get(payload, 'untranslatedName')::string as untranslatedName
from {{ref('issuetypes')}}
