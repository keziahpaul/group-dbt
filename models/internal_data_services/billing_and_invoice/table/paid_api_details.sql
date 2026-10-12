with api_sub as
(select 
     subscriber_id
    ,subscriber_name
    ,subscriber_status
    ,subscriber_type
    ,workspace_id
    ,settlement_date
    ,workspace_status
    ,api_description
    ,integrator_name
    ,request_date 
    ,sum(count_api_calls) as count_api_calls
    ,transaction_type
    ,webhook_notification_count
    ,webhook_registration_id
    ,webhook_uri
    ,event_type
    ,source
    ,max(src_delta_extract_ts) as src_delta_extract_ts
    ,max(inserted_at) as inserted_at
    ,max(updated_at) as updated_at
from (
            select
                subscriber_id
                ,subscriber_name
                ,subscriber_status
                ,subscriber_type
                ,workspace_number as workspace_id
                ,settlement_date
                ,workspace_status
                ,null as api_description
                ,integrator_id as integrator_name
                ,request_date 
                ,null as count_api_calls
                ,transaction_type
                ,webhook_notification_count
                ,webhook_registration_id
                ,webhook_uri
                ,event_type
                ,'PUSH_NOTIFICATION' as source
                , src_delta_extract_ts
                , inserted_at
                , updated_at
            from {{ ref('api_push_notification') }}
            UNION ALL
            select
                subscriber_id
                ,subscriber_name
                ,subscriber_status
                ,subscriber_type
                ,workspace_number as workspace_id
                ,settlement_date
                ,workspace_status
                ,api_description
                ,integrator_name
                ,request_date
                ,count_api_calls
                ,transaction_type
                ,null as webhook_notification_count
                ,null as webhook_registration_id
                ,null as webhook_uri
                ,null as event_type
                ,case when exp_api_ind = 'Y' then 'EXPERIENCE_API' else 'EXCHANGE_API' end as source
                , src_delta_extract_ts
                , inserted_at
                , updated_at
            from {{ ref('api_exchange') }}
    ) 
 group by all
)
select 
    api_sub.subscriber_id
    ,api_sub.subscriber_name
    ,api_sub.subscriber_status
    ,api_sub.subscriber_type
    ,api_sub.workspace_id
    ,api_sub.settlement_date
    ,api_sub.workspace_status
    ,api_sub.api_description
    ,api_sub.integrator_name
    ,api_sub.request_date 
    ,api_sub.count_api_calls
    ,lodge.participant_reference as subscriber_reference
    ,lodge.workspace_role as  workspace_role
    ,api_sub.transaction_type
    ,api_sub.webhook_notification_count
    ,api_sub.webhook_registration_id
    ,api_sub.webhook_uri
    ,api_sub.event_type
    ,api_sub.source
    ,api_sub.src_delta_extract_ts
    ,api_sub.inserted_at
    ,api_sub.updated_at
from api_sub
left join {{ source('ssa_source','lodgement_participants') }} lodge
        on api_sub.workspace_id = lodge.workspace_number
        and api_sub.subscriber_id =lodge.subscriber_id


