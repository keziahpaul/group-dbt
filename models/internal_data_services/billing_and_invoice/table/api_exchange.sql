{{ config(
    materialized = 'incremental',
    incremental_strategy = 'merge',
    unique_key = [
        'api_hash'
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
),
api_sub as 
(
    select 
            exch_api.subscriber_id as subscriber_id
            , latest_lodge.subscriber_name as subscriber_name
            , latest_lodge.subscriber_status as subscriber_status
            , latest_lodge.subscriber_type as subscriber_type
            , latest_lodge.workspace_id as workspace_id
            , exch_api.workspace_id as workspace_number
            , latest_lodge.settlement_date as settlement_date
            , latest_lodge.workspace_status as workspace_status

            , LISTAGG( distinct exch_api.API, ', ') WITHIN GROUP (ORDER BY exch_api.API) OVER (partition by exch_api.uuid, exch_api.workspace_id
        ,exch_api.subscriber_id) as api_description
            , exch_api.uuid as uuid
            , exch_api.integrator_name as integrator_name
            , exch_api.request_timestamp_aest::date as request_date
            , count(*) over (partition by exch_api.uuid, exch_api.workspace_id
        ,exch_api.subscriber_id) as exp_api_ind
            , latest_lodge.subscriber_reference as subscriber_reference
            , latest_lodge.workspace_role as workspace_role
            , latest_lodge.transaction_type as transaction_type
            , latest_lodge.src_delta_extract_ts as src_delta_extract_ts
            
        from latest_lodge_part latest_lodge
        join {{ source('api_share','vw_api_report_logs') }} exch_api
            on exch_api.workspace_id = latest_lodge.workspace_number
            and exch_api.subscriber_id =latest_lodge.subscriber_id
        where latest_lodge.workspace_status in ('LODGED_DISBURSED','LODGED', 'COMPLETED_DISBURSED','CLOSED')
)
select 
      subscriber_id as subscriber_id
    , MAX(subscriber_name) as subscriber_name
    , MAX(subscriber_status) as subscriber_status
    , MAX(subscriber_type) as subscriber_type
    , MAX(workspace_id) as workspace_id
    , workspace_number as workspace_number
    , MAX(settlement_date) as settlement_date
    , MAX(workspace_status) as workspace_status
    , MAX(api_description) as api_description
    , uuid as uuid
    , integrator_name
    , request_date
    , max(exp_api_ind) as exp_api_ind
    , count(api_description) as count_api_calls
    , MAX(subscriber_reference) as subscriber_reference
    , MAX(workspace_role) as workspace_role
    , MAX(transaction_type) as transaction_type
    , MAX(src_delta_extract_ts) as src_delta_extract_ts
    , hash(request_date
        ,uuid
        ,workspace_number
        ,subscriber_id
        ,integrator_name) as api_hash
    , max(CONVERT_TIMEZONE('Australia/Sydney',CURRENT_TIMESTAMP(2))) as inserted_at
    , max(CONVERT_TIMEZONE('Australia/Sydney',CURRENT_TIMESTAMP(2))) as updated_at 
    from (
            select subscriber_id as subscriber_id
                ,subscriber_name
                ,subscriber_status
                ,subscriber_type
                ,workspace_id
                ,workspace_number
                ,settlement_date
                ,workspace_status
                , case when exp_api_ind > 1 and map.tableau_api is not null then map.tableau_api
                        else  api_sub.api_description
                  end as api_description
                , uuid as uuid
                , max(integrator_name) over(partition by uuid) as integrator_name
                , request_date
                , case when exp_api_ind>1 and map.tableau_api is not null then 'Y' else 'N' end as exp_api_ind
                ,subscriber_reference
                ,workspace_role
                ,transaction_type
                ,src_delta_extract_ts
            from api_sub
            left join {{ ref('experience_api_idenitity_map')}} map on ARRAY_CONTAINS(map.EXCHANGE_RESOURCE_API::VARIANT,SPLIT(upper(nvl(api_sub.api_description,'UNKNOWN')), ',')) 
            
        ) api
group by request_date
        ,uuid
        ,workspace_number
        ,subscriber_id
        ,integrator_name
        
        


