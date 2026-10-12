{{
    config(
        materialized='incremental',
        unique_key='subscriber_id',
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

projects_workspace as (
    select be.subscriber_id,
        be.created_date,
        greatest_ignore_nulls(be.inserted_at,p.inserted_at) as src_delta_extract_ts
    from {{ source('exchange_share', 'vw_business_event') }} be
    join {{ source('exchange_share', 'vw_participants') }} p
    on be.workspace_id = p.workspace_id
    where be.business_event_type_id in (1)
    and pexa_projects_id is not null                       
    {% if is_incremental()%}
        and (be.created_date > (select last_load_max_timestamp from target_max_timestamp)
            or p.inserted_at > (select last_load_max_timestamp from target_max_timestamp))
    {%endif%}
),

final_output as (
    select subscriber_id,
        max(created_date) as ws_last_created_date,
        max(src_delta_extract_ts) as src_delta_extract_ts
    from projects_workspace
    group by subscriber_id
)


select subscriber_id,
    ws_last_created_date,
    CONVERT_TIMEZONE('Australia/Sydney',src_delta_extract_ts) as src_delta_extract_ts,
    {{ var('inserted_at') }} as inserted_at,
    {{ var('updated_at') }} as updated_at
from final_output
