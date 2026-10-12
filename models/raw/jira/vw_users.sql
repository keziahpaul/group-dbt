select
    extracted,
    id,
    get(payload, 'accountType')::string as accountType,
    get(payload, 'active')::boolean as active,
    get(payload, 'avatarUrls')::variant as avatarUrls,
    get(payload, 'displayName')::string as displayName,
    get(payload, 'emailAddress')::string as emailAddress,
    get(payload, 'locale')::string as locale,
    get(payload, 'self')::string as self,
    get(payload, 'timeZone')::string as timeZone
from {{ref('users')}}
