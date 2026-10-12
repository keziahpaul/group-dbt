{{
    config(
        materialized='ephemeral'
    )
}}
{#- This model exists to test if the the JSON fields contain valid JSON -#}

select
    *
from {{ref('_genesys_config')}}
where (
    arguments is null
    or
    arguments is not null and try_parse_json(arguments) is not null
)
and (
    id_path not like '[%]'
    or
    id_path like '[%]' and try_parse_json(id_path) is not null
)