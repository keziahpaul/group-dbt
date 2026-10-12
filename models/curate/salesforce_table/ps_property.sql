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
    ,	last_viewed_date
    ,	last_referenced_date
    ,	ps_address_line_c
    ,	ps_consumer_c
    ,	ps_invitation_accepted_date_c
    ,	ps_invitation_date_c
    ,	ps_organisation_c
    ,	ps_party_id_c
    ,	ps_post_code_c
    ,	ps_property_classification_c
    ,	ps_property_settled_c
    ,	ps_settlement_date_c
    ,	ps_settlement_status_c
    ,	ps_state_c
    ,	ps_suburb_c
    ,	ps_tracking_id_c
    ,	ps_tracking_status_c
    ,	ps_user_role_c
    ,	ps_workspace_id_c
    ,	country_c
    ,	full_workspace_number_c
    ,	opportunity_c
    ,	purchase_price_c
    ,	send_registration_id_c
    ,	settlement_date_c
    ,	subscriber_id_c
    ,	subscriber_reference_c
    ,	workspace_create_date_c
    ,	account_name_c
    ,	opportunity_owner_c
    ,	new_owner_c
    ,	account_owner_c
    ,	account_tier_c
    ,	sales_outcome_c
    ,	opportunity_stage_c
    ,	property_type_c
    ,	fx_api_c
    ,	registration_c
    ,	source_c
    ,	participant_id_c
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_ps_property' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
