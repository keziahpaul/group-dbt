{{ config(
    materialized="incremental", 
    incremental_strategy="append", 
    transient=false
) }}

with initial as (
    select
        *,
        {{ var("inserted_at") }} as inserted_at
    from {{ source('snowflake_trustcenter', 'findings') }}
    where
        severity in ('CRITICAL', 'HIGH', 'MEDIUM')
        and scanner_id not in (
            'CIS_BENCHMARKS_CIS3_1',
            'CIS_BENCHMARKS_CIS1_4',
            'CIS_BENCHMARKS_CIS1_15',
            'CIS_BENCHMARKS_CIS1_6',
            'CIS_BENCHMARKS_CIS1_14',
            'CIS_BENCHMARKS_CIS1_17',
            'CIS_BENCHMARKS_CIS1_16',
            'CIS_BENCHMARKS_CIS1_1'
        )
    {%- if is_incremental() %}
        and created_on > (select coalesce(max(created_on), '1900-01-01 00:00:00') from {{ this }}) 
    {%- endif %}
)

select * from initial
