select
    extracted,
    id,
    get(payload, 'clauseNames')::array as clauseNames,
    get(payload, 'custom')::boolean as custom,
    get(payload, 'key')::string as key,
    get(payload, 'name')::string as name,
    get(payload, 'navigable')::boolean as navigable,
    get(payload, 'orderable')::boolean as orderable,
    get(payload, 'schema')::variant as schema,
{#-
"schema": {
    "custom": "com.atlassian.jira.plugin.system.customfieldtypes:multicheckboxes",
    "customId": 10871,
    "items": "option",
    "type": "array"
}
#}
    get(payload, 'scope')::variant as scope,
{#-
"scope": {
    "project": {
      "id": "10288"
    },
    "type": "PROJECT"
}
#}
    get(payload, 'searchable')::boolean as searchable,
    get(payload, 'untranslatedName')::string as untranslatedName
from {{ref('fields')}}
