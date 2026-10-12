{{
    config(
        materialized='incremental',
        unique_key='id',
        merge_exclude_columns = ['inserted_at']
    )
}}
with
{%if is_incremental()%}
target_max_timestamp as 
(
    select max(src_delta_extract_ts) as last_load_max_timestamp from {{this}}
),
{%endif%}
participants as 
(
    select 
        subscriber_id,
        workspace_id,
        workspace_role_id,
        MAX(inserted_at) AS INSERTED_AT
    from {{ source('exchange_share', 'vw_participants') }} p
    where workspace_role_id in (2,4)
        and status='ACTIVE'
        {% if is_incremental()%}
        and inserted_at > (select last_load_max_timestamp from target_max_timestamp)
        {%endif%}
    group by subscriber_id,
        workspace_id,
        workspace_role_id
),

final_output as 
(     select  
        concat(settlement_id,'-',workspace_role_id) as id,
        settlement_id,
        s.date1 as settlement_date, 
        s.subscriber_id, 
        p.workspace_role_id,
        case when workspace_role_id = 2 then date1 else null end as buyer_settlement_date,
        case when workspace_role_id = 4 then date1 else null end as seller_settlement_date,
        {{ extract_financial_year('date1') }} as financial_year,
        greatest_ignore_nulls(s.inserted_at,p.inserted_at) as src_delta_extract_ts
    from {{ source('exchange_share', 'vw_settlements') }} s
    join participants p
    on s.subscriber_id = p.subscriber_id
    and s.workspace_id=p.workspace_id
    {% if is_incremental()%}
        and ( s.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
             or P.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
            )
    {%endif%}
)

select 
    id,
    settlement_id,
    settlement_date,
    subscriber_id,
    workspace_role_id,
    buyer_settlement_date,
    seller_settlement_date,
    financial_year,
    CONVERT_TIMEZONE('Australia/Sydney',src_delta_extract_ts) as src_delta_extract_ts,
    {{ var('inserted_at') }} as inserted_at,
    {{ var('updated_at') }} as updated_at
from final_output