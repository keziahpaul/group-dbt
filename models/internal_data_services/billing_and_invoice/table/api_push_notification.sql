{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = [
        'request_date',
        'subscriber_id',
        'workspace_number',
        'integrator_id',
        'webhook_registration_id',
        'event_type',
        'webhook_uri'
    ],
    merge_exclude_columns=['inserted_at']
) }}

with
{%- if is_incremental() %}
 last_load_dt as (
    select nvl(max(src_delta_extract_ts), to_date('{{env_var('DBT_API_CUT_OFF_DT')}}','YYYYMMDD') ) as load_dt FROM {{this}}
),
{%- endif %}
 latest_lodge_part as (
select lodge.workspace_number
    , lodge.subscriber_id
    , lodge.workspace_id
    , lodge.participant_reference as subscriber_reference
    , lodge.workspace_role
    , lodge.workspace_tx_type as transaction_type
    , nvl(lodge.settlement_date::date ,lodge.lodgement_date::date) as settlement_date
    , lodge.workspace_status as workspace_status
    , subs_enr_mas.subscriber_name as subscriber_name
    , subs_enr_mas.subscriber_status as subscriber_status
    , subs_enr_mas.subscriber_type  as subscriber_type
    , nvl(lodge.settlement_date ,lodge.lodgement_date) as src_delta_extract_ts
from {{ source('ssa_source','lodgement_participants') }} lodge
left join {{ source('ssa_source','subscribers_enriched_master') }} subs_enr_mas
    on lodge.subscriber_id = subs_enr_mas.subscriber_id 
{%- if is_incremental() %}
   join last_load_dt on 1=1
   where nvl(lodge.settlement_date ,lodge.lodgement_date) > last_load_dt.load_dt
{%- else %}
    where nvl(lodge.settlement_date ,lodge.lodgement_date) > to_date('{{env_var('DBT_API_CUT_OFF_DT')}}','YYYYMMDD')
{%- endif %}
QUALIFY ROW_NUMBER() OVER (
    PARTITION BY lodge.workspace_id, lodge.workspace_number, lodge.subscriber_id ORDER BY id DESC
    ) = 1
)
    select
        r.subscriber_id as subscriber_id
        , max(latest_lodge.subscriber_name) as subscriber_name
        , max(latest_lodge.subscriber_status) as subscriber_status
        , max(latest_lodge.subscriber_type) as subscriber_type
        , o.workspace_id as workspace_number
        , r.integrator_id as integrator_id
        , max(latest_lodge.workspace_id) as workspace_id
        , max(latest_lodge.settlement_date) as settlement_date
        , max(latest_lodge.workspace_status) as workspace_status
        , max(latest_lodge.subscriber_reference) as SUBSCRIBER_REFERENCE
        , max(latest_lodge.workspace_role) as WORKSPACE_ROLE
        , max(latest_lodge.transaction_type) as TRANSACTION_TYPE
        , count(*) as WEBHOOK_NOTIFICATION_COUNT
        , r.id as WEBHOOK_REGISTRATION_ID
        , wr.webhook_uri as WEBHOOK_URI
        , o.event_type  as EVENT_TYPE
        , o.updated_at_src::date as request_date
        , {{ var("inserted_at") }} as inserted_at
        , {{ var("inserted_at") }} as updated_at
        , max(src_delta_extract_ts) as src_delta_extract_ts
from latest_lodge_part latest_lodge
JOIN {{ source('push_not_share','vw_outbound_notification') }} o
        ON o.workspace_id = latest_lodge.workspace_number
JOIN {{ source('push_not_share','vw_registration') }} r
        ON o.registration_id = r.id
        and r.subscriber_id =  latest_lodge.subscriber_id
JOIN {{ source('push_not_share','vw_webhook_registration') }} wr
        ON r.id = wr.registration_id
where latest_lodge.workspace_status in ('LODGED_DISBURSED','LODGED', 'COMPLETED_DISBURSED','CLOSED')
GROUP BY r.subscriber_id, r.integrator_id, o.workspace_id, o.event_type, r.id, wr.webhook_uri, o.updated_at_src::date
