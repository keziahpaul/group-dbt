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
      colorName,
      self,
      extracted as inserted_at,
      extracted as updated_at,
      HASH(name, key, colorName, self) as hash
  from {{ref('vw_statuscategories')}}
)
select
  s.id,
  s.name,
  s.key,
  s.colorName,
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
