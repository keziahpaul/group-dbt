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
      isDefault,
      self,
      extracted as inserted_at,
      extracted as updated_at,
      HASH(name, description, isDefault, self) as hash
  from {{ref('vw_resolutions')}}
)
select
  s.id,
  s.name,
  s.description,
  s.isDefault,
  s.self,
  s.inserted_at,
  s.updated_at,
  s.hash
from source_records s
{%- if is_incremental() %}
left join {{this}} o on s.id = o.id and s.hash = o.hash
where o.id is null
{%- endif %}
order by s.id
