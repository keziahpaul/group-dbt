select
    extracted,
    id,
    get(payload, 'avatarUrls')::variant as avatarUrls,
    get(payload, 'entityId')::string as entityId,
    get(payload, 'expand')::string as expand,
    get(payload, 'isPrivate')::boolean as isPrivate,
    get(payload, 'key')::string as key,
    get(payload, 'name')::string as name,
    get(payload, 'projectCategory')::variant as projectCategory,
    get(payload, 'projectTypeKey')::string as projectTypeKey,
    get(payload, 'properties')::variant as properties,
    get(payload, 'self')::string as self,
    get(payload, 'simplified')::boolean as simplified,
    get(payload, 'style')::string as style,
    get(payload, 'uuid')::string as uuid
from {{ref('projects')}}
