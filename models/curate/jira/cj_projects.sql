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
      key,
      entityId,
      expand,
      isPrivate,
      get(projectCategory, 'id')::string as projectCategory_id,
      projectTypeKey,
      properties, {#- variant field #}
      self,
      simplified,
      style,
      uuid,
      get(avatarUrls, '16x16')::string as avatarUrl_16,
      get(avatarUrls, '24x24')::string as avatarUrl_24,
      get(avatarUrls, '32x32')::string as avatarUrl_32,
      get(avatarUrls, '48x48')::string as avatarUrl_48,
      extracted as inserted_at,
      extracted as updated_at,
      HASH(name, key, entityId, expand, isPrivate, projectCategory_id, projectTypeKey, properties, self, simplified, style, uuid, avatarUrl_16, avatarUrl_24, avatarUrl_32, avatarUrl_48) as hash
  from {{ref('vw_projects')}}
)
select
  s.id,
  s.name,
  s.key,
  s.entityId,
  s.expand,
  s.isPrivate,
  s.projectCategory_id,
  s.projectTypeKey,
  s.properties,
  s.self,
  s.simplified,
  s.style,
  s.uuid,
  s.avatarUrl_16,
  s.avatarUrl_24,
  s.avatarUrl_32,
  s.avatarUrl_48,
  s.inserted_at,
  s.updated_at,
  s.hash
from source_records s
{%- if is_incremental() %}
left join {{this}} o on s.id = o.id and s.hash = o.hash
where o.id is null
{%- endif %}
order by s.id
