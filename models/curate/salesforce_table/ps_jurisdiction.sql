{{ config (
    materialized='scd_materialization',
    incremental_strategy='scd2_transformation',
    primary_key=['id'],
    source_delta_column = "inserted_at",
    source_scd_effective_column = "system_modstamp_aest",
    scd2_ignore_columns =['row_num','deleted_at'],
    target_delta_column = "src_delta_extract_ts",
    handle_deletes=true, 
    src_delete_identifier ='is_deleted',
    deleted_at_identifier='deleted_at',
    src_timestamp_grain ='second',
    target_ignore_columns=["row_num","deleted_at"]
)  
}}

select
        id
    ,	is_deleted
    ,	name
    ,	created_date
    ,	created_by_id
    ,	last_modified_date
    ,	last_modified_by_id
    ,	system_modstamp
    ,	last_activity_date
    ,	last_viewed_date
    ,	last_referenced_date
    ,	ps_accountid_c
    ,	ps_activation_date_c
    ,	ps_contact_c
    ,	ps_lrcode_c
    ,	ps_stamp_duty_code_c
    ,	ps_state_c
    ,	ps_status_c
    ,	ps_subscription_c
    ,	ps_withdrawn_date_c
    ,	ps_withdrawn_reason_c
    ,	conveyancers_triennia_licence_expiry_date_c
    ,	conveyancers_triennial_licence_date_c
    ,	conveyancers_triennial_licence_name_c
    ,	conveyancers_triennial_licence_number_c
    ,	conveyancers_triennial_licence_type_c
    ,	current_jurisdiction_c
    ,	future_jurisdictions_c
    ,	jurisdiction_type_c
    ,	account_name_c
    ,	act_c
    ,	current_jurisdiction_del_c
    ,	future_jurisdictions_del_c
    ,	nsw_c
    ,	nt_c
    ,	qld_c
    ,	related_application_c
    ,	sa_c
    ,	state_c
    ,	tas_c
    ,	vic_c
    ,	wa_c
    ,	accountid_c
    ,	jurisdiction_c
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_ps_jurisdiction' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
