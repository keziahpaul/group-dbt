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
      clauseNames,
      custom,
      navigable,
      orderable,
      get(schema, 'custom')::string as schema_custom,
      get(schema, 'type')::string as schema_type,
      get(schema, 'items')::string as schema_items,
      get(scope, 'type')::string as scope_type,
      get(get(scope, 'project'), 'id')::string as scope_project_id,
      searchable,
      untranslatedName,
      extracted as inserted_at,
      extracted as updated_at,
      HASH(name, key, clauseNames, custom, navigable, orderable, schema_custom, schema_type, schema_items, scope_type, scope_project_id, searchable, untranslatedName) as hash
  from {{ref('vw_fields')}}
)
select
  s.id,
  s.name,
  s.key,
  s.clauseNames,
  s.custom,
  s.navigable,
  s.orderable,
  s.schema_custom,
  s.schema_type,
  s.schema_items,
  s.scope_type,
  s.scope_project_id,
  s.searchable,
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
