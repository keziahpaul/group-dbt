with all_src as (
    -- This View will be utilised for building Dashboard in Prod Group account 
    -- where findings from all 3 Prod accounts and 3 NonProd accounts will be utilised

    (
        -- For testing purpose, view will be created in Non-Prod group, but will incorrectly reflect nonprod_group as prod_group. 
        select
            *,
            'prod_group' as account_name
        from {{ ref('findings') }}
    )
    {%- if env_var('DBT_ENV_NAME') in ('dev', 'prd') %}
    union
    (
        select
            *,
            'nonprod_exchange' as account_name
        from {{ source('nonprod_exchange_trustcenter_share', 'findings') }}
    )
    {%- endif %}
    {%- if env_var('DBT_ENV_NAME') == 'prd' %}
    union
    (
        select
            *,
            'prod_exchange' as account_name
        from {{ source('prod_exchange_trustcenter_share', 'findings') }}
    )
    union
    (
        select
            *,
            'nonprod_group' as account_name
        from {{ source('nonprod_group_trustcenter_share', 'findings') }}
    )
    {%- endif %}

)

select * from all_src
