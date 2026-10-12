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
      description,
      get(scope, 'type')::string as scope_type,
      get(get(scope, 'project'), 'id')::string as scope_project_id,
      statusCategory,
      extracted as inserted_at,
      extracted as updated_at,
      HASH(name, description, scope_type, scope_project_id, statusCategory) as hash
  from {{ref('vw_statuses')}}
)
select
  s.id,
  s.name,
  s.description,
  s.scope_type,
  s.scope_project_id,
  s.statusCategory,
  s.inserted_at,
  s.updated_at,
  s.hash
from source_records s
{%- if is_incremental() %}
left join {{this}} o on s.id = o.id and s.hash = o.hash
where o.id is null
{%- endif %}
order by s.id
