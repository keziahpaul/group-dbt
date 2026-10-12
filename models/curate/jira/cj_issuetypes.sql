{{
  config(
    materialized = 'incremental',
    unique_key = 'id',
    incremental_strategy = 'merge',
    merge_exclude_columns = ['id', 'inserted_at']
    )
}}
with source_records as (
  select
      id,
      name,
      avatarId,
      description,
      hierarchyLevel,
      iconUrl,
      get(scope, 'type')::string as scope_type,
      get(get(scope, 'project'), 'id')::string as scope_project_id,
      self,
      subtask,
      untranslatedName,
      extracted as inserted_at,
      extracted as updated_at,
      HASH(name, avatarId, description, hierarchyLevel, iconUrl, scope_type, scope_project_id, self, subtask, untranslatedName) as hash
  from {{ref('vw_issuetypes')}}
)
select
  s.id,
  s.name,
  s.avatarId,
  s.description,
  s.hierarchyLevel,
  s.iconUrl,
  s.scope_type,
  s.scope_project_id,
  s.self,
  s.subtask,
  s.untranslatedName,
  s.inserted_at,
  s.updated_at,
  s.hash
from source_records s
{%- if is_incremental() %}
left join {{this}} o on s.id = o.id and s.hash = o.hash
where o.id is null
{%- endif %}
order by s.id
