
    
    with api_logs as 
      (
        select 
            api_logs.api as api
            ,api_logs.channel as channel 
            ,api_logs.error_message as error_message 
            ,api_logs.legal_entity_name as legal_entity_name 
            ,api_logs.ob_code as ob_code 
            ,api_logs.pms as api_pms 
            ,api_logs.product as product 
            ,api_logs.integrator_name as integrator_name
            ,api_logs.request_timestamp_aest::date as request_date
            ,api_logs.response_status as response_status 
            ,api_logs.subscriber_id as api_subscriber_id 
            ,api_logs.subscriber_type as api_subscriber_type 
            ,api_logs.username as username 
            ,api_logs.workspace_id as workspace_number 
            ,max(api_logs.uuid) as uuid 
            ,max(api_logs.request_body) as request_body
            ,max(api_logs.request_qry_string) as request_qry_string
            ,max(api_logs.request_url) as request_url
            ,max(api_logs.response_body) as response_body
            ,max(api_logs.response_headers) as response_headers
            ,max(api_logs.inserted_at) as api_inserted_at
            ,max(api_logs.client_name) as client_name
            ,count(request_timestamp) as count_of_api
        from {{ source('api_share','vw_api_report_logs') }} api_logs
        group by all
        
      )
      select 
        api
        , channel
        , error_message
        , legal_entity_name
        , ob_code
        , api_pms
        , product
        , integrator_name
        , request_body
        , request_qry_string
        , request_date
        , request_url
        , response_body
        , response_headers
        , response_status
        , api_subscriber_id
        , api_subscriber_type
        , username
        , uuid
        , workspace_number
        , api_inserted_at
        , client_name
        , count_of_api
        , last_updated_date
        , status
        , workspace_id
        , number1
        , src_delta_extract_ts
        , updated_at
        , settlements_inserted_at
        , settlement_date
        , status_datetime_qld
        , status_datetime_nsw
        , subscriber_status_reason
        , subscriber_trading_name
        , status_datetime_wa
        , customer_segment_0
        , account_management_segment
        , pms
        , active_act_flag
        , status_datetime_act
        , active_qld_flag
        , customer_segment
        , subscriber_type
        , active_sa_flag
        , subscriber_legal_entity_name
        , account_owner_status
        , transfers_wa_l12m_count
        , active_vic_flag
        , subscriber_status_reason_datetime
        , subscriber_type_id
        , subscriber_created_datetime
        , psob_0
        , subscriber_id
        , transfers_sa_l12m_count
        , subscribers_hidden_from_search_flag
        , status_datetime_nt
        , transfers_l12m_count
        , subscriber_panel_member_flag
        , account_manager
        , information_broker_updated_date
        , active_tas_flag
        , pexa_planner_access_flag
        , status_datetime_sa
        , active_nsw_flag
        , transfers_act_l12m_count
        , subscriber_status
        , information_broker
        , primary_source_of_business
        , transactions_l12m_count
        , transfers_tas_l12m_count
        , status_datetime_vic
        , pms_updated_date
        , status_datetime_tas
        , transfers_qld_l12m_count
        , active_wa_flag
        , subscriber_state
        , subscriber_profile
        , transfers_vic_l12m_count
        , transfers_nsw_l12m_count
        , customer_segment_2
        , subscriber_party_type
        , subscriber_postcode
        , transfers_nt_l12m_count
        , subscriber_name
        , pexa_key_registration_flag
        , acn
        , parent_account_name
        , active_nt_flag
        , account_owner
        , abn
        , {{ var('inserted_at') }} as inserted_at
    from 
    (
        select api_logs.api as api
        ,api_logs.channel as channel
        ,api_logs.error_message as error_message
        ,api_logs.legal_entity_name as legal_entity_name
        ,api_logs.ob_code as ob_code
        ,api_logs.api_pms as api_pms
        ,api_logs.product as product
        ,api_logs.integrator_name AS integrator_name
        ,api_logs.request_body as request_body
        ,api_logs.request_qry_string as request_qry_string
        ,api_logs.request_date as request_date
        ,api_logs.request_url as request_url
        ,api_logs.response_body as response_body
        ,api_logs.response_headers as response_headers
        ,api_logs.response_status as response_status
        ,api_logs.api_subscriber_id as api_subscriber_id
        ,api_logs.api_subscriber_type as api_subscriber_type
        ,api_logs.username as username
        ,api_logs.uuid as uuid
        ,api_logs.workspace_number as workspace_number
        ,api_logs.api_inserted_at as api_inserted_at
        ,api_logs.client_name as client_name
        ,api_logs.count_of_api as count_of_api
        ,settl.last_updated_date as last_updated_date
        ,settl.status as status
        ,settl.workspace_id as workspace_id
        ,settl.number1 as number1
        ,settl.src_delta_extract_ts as src_delta_extract_ts
        ,settl.updated_at as updated_at
        ,settl.inserted_at as settlements_inserted_at
        ,settl.settlement_date as settlement_date
        ,subs_enr_mas.status_datetime_qld as status_datetime_qld
        ,subs_enr_mas.status_datetime_nsw as status_datetime_nsw
        ,subs_enr_mas.subscriber_status_reason as subscriber_status_reason
        ,subs_enr_mas.subscriber_trading_name as subscriber_trading_name
        ,subs_enr_mas.status_datetime_wa as status_datetime_wa
        ,subs_enr_mas.customer_segment_0 as customer_segment_0
        ,subs_enr_mas.account_management_segment as account_management_segment
        ,subs_enr_mas.pms as pms
        ,subs_enr_mas.active_act_flag as active_act_flag
        ,subs_enr_mas.status_datetime_act as status_datetime_act
        ,subs_enr_mas.active_qld_flag as active_qld_flag
        ,subs_enr_mas.customer_segment as customer_segment
        ,subs_enr_mas.subscriber_type as subscriber_type
        ,subs_enr_mas.active_sa_flag as active_sa_flag
        ,subs_enr_mas.subscriber_legal_entity_name as subscriber_legal_entity_name
        ,subs_enr_mas.account_owner_status as account_owner_status
        ,subs_enr_mas.transfers_wa_l12m_count as transfers_wa_l12m_count
        ,subs_enr_mas.active_vic_flag as active_vic_flag
        ,subs_enr_mas.subscriber_status_reason_datetime as subscriber_status_reason_datetime
        ,subs_enr_mas.subscriber_type_id as subscriber_type_id
        ,subs_enr_mas.subscriber_created_datetime as subscriber_created_datetime
        ,subs_enr_mas.psob_0 as psob_0
        ,subs_enr_mas.subscriber_id as subscriber_id
        ,subs_enr_mas.transfers_sa_l12m_count as transfers_sa_l12m_count
        ,subs_enr_mas.subscribers_hidden_from_search_flag as subscribers_hidden_from_search_flag
        ,subs_enr_mas.status_datetime_nt as status_datetime_nt
        ,subs_enr_mas.transfers_l12m_count as transfers_l12m_count
        ,subs_enr_mas.subscriber_panel_member_flag as subscriber_panel_member_flag
        ,subs_enr_mas.account_manager as account_manager
        ,subs_enr_mas.information_broker_updated_date as information_broker_updated_date
        ,subs_enr_mas.active_tas_flag as active_tas_flag
        ,subs_enr_mas.pexa_planner_access_flag as pexa_planner_access_flag
        ,subs_enr_mas.status_datetime_sa as status_datetime_sa
        ,subs_enr_mas.active_nsw_flag as active_nsw_flag
        ,subs_enr_mas.transfers_act_l12m_count as transfers_act_l12m_count
        ,subs_enr_mas.subscriber_status as subscriber_status
        ,subs_enr_mas.information_broker as information_broker
        ,subs_enr_mas.primary_source_of_business as primary_source_of_business
        ,subs_enr_mas.transactions_l12m_count as transactions_l12m_count
        ,subs_enr_mas.transfers_tas_l12m_count as transfers_tas_l12m_count
        ,subs_enr_mas.status_datetime_vic as status_datetime_vic
        ,subs_enr_mas.pms_updated_date as pms_updated_date
        ,subs_enr_mas.status_datetime_tas as status_datetime_tas
        ,subs_enr_mas.transfers_qld_l12m_count as transfers_qld_l12m_count
        ,subs_enr_mas.active_wa_flag as active_wa_flag
        ,subs_enr_mas.subscriber_state as subscriber_state
        ,subs_enr_mas.subscriber_profile as subscriber_profile
        ,subs_enr_mas.transfers_vic_l12m_count as transfers_vic_l12m_count
        ,subs_enr_mas.transfers_nsw_l12m_count as transfers_nsw_l12m_count
        ,subs_enr_mas.customer_segment_2 as customer_segment_2
        ,subs_enr_mas.subscriber_party_type as subscriber_party_type
        ,subs_enr_mas.subscriber_postcode as subscriber_postcode
        ,subs_enr_mas.transfers_nt_l12m_count as transfers_nt_l12m_count
        ,subs_enr_mas.subscriber_name as subscriber_name
        ,subs_enr_mas.pexa_key_registration_flag as pexa_key_registration_flag
        ,subs_enr_mas.acn as acn
        ,subs_enr_mas.parent_account_name as parent_account_name
        ,subs_enr_mas.active_nt_flag as active_nt_flag
        ,subs_enr_mas.account_owner as account_owner
        ,subs_enr_mas.abn as abn
    from  api_logs
    left join {{ source('ssa_source','settlements') }} settl
        on api_logs.workspace_number = settl.number1
    left join {{ source('ssa_source','subscribers_enriched_master') }} subs_enr_mas
        on api_logs.api_subscriber_id = subs_enr_mas.subscriber_id
    )
    