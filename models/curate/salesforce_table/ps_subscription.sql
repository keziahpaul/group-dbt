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
    ,	owner_id
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
    ,	ps_account_c
    ,	ps_acln_c
    ,	ps_afin_c
    ,	ps_apcaiddestination_c
    ,	ps_apcaidsources_c
    ,	ps_arbn_c
    ,	ps_account_category_c
    ,	ps_activation_date_c
    ,	ps_active_digital_certificate_c
    ,	ps_approvedfor_soft_cert_c
    ,	ps_digital_signing_software_version_c
    ,	ps_digital_signing_software_c
    ,	ps_esa_c
    ,	ps_entity_type_c
    ,	ps_expiry_date_c
    ,	ps_lenderof_record_c
    ,	activationdate_converted_c
    ,	ps_microsoft_window_version_c
    ,	ps_non_adi_c
    ,	ps_onboarding_id_c
    ,	ps_other_category_c
    ,	ps_own_esaaccount_c
    ,	ps_pasigned_by_c
    ,	ps_paversion_c
    ,	ps_pexarevenue_c
    ,	ps_reasonfor_suspension_c
    ,	ps_reasonfor_termination_c
    ,	ps_settler_type_c
    ,	ps_sponsor_c
    ,	ps_status_c
    ,	ps_sub_category_c
    ,	ps_subscriber_id_c
    ,	ps_subscription_type_c
    ,	ps_suspension_termination_date_c
    ,	ps_termination_other_c
    ,	ps_two_factor_authentication_c
    ,	ps_numberofpexausers_c
    ,	ps_operating_model_preference_c
    ,	ps_opportunity_id_c
    ,	ps_expiry_date_2_c
    ,	ps_master_policy_number_c
    ,	ps_master_policy_number_2_c
    ,	sf18_subscription_id_c
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_ps_subscription' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
