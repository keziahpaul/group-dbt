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
    ,	parent_id
    ,	type
    ,	status
    ,	start_date
    ,	end_date
    ,	expected_revenue
    ,	budgeted_cost
    ,	actual_cost
    ,	expected_response
    ,	number_sent
    ,	is_active
    ,	description
    ,	number_of_leads
    ,	number_of_converted_leads
    ,	number_of_contacts
    ,	number_of_responses
    ,	number_of_opportunities
    ,	number_of_won_opportunities
    ,	amount_all_opportunities
    ,	amount_won_opportunities
    ,	hierarchy_number_of_leads
    ,	hierarchy_number_of_converted_leads
    ,	hierarchy_number_of_contacts
    ,	hierarchy_number_of_responses
    ,	hierarchy_number_of_opportunities
    ,	hierarchy_number_of_won_opportunities
    ,	hierarchy_amount_all_opportunities
    ,	hierarchy_amount_won_opportunities
    ,	hierarchy_number_sent
    ,	hierarchy_expected_revenue
    ,	hierarchy_budgeted_cost
    ,	hierarchy_actual_cost
    ,	owner_id
    ,	created_date
    ,	created_by_id
    ,	last_modified_date
    ,	last_modified_by_id
    ,	system_modstamp
    ,	last_activity_date
    ,	last_viewed_date
    ,	last_referenced_date
    ,	campaign_member_record_type_id
    ,	purecloud_adjusted_end_date_time_c
    ,	purecloud_adjusted_start_date_time_c
    ,	purecloud_failed_attempts_to_reconcile_results_c
    ,	purecloud_pure_cloud_campaign_id_c
    ,	purecloud_pure_cloud_campaign_priority_c
    ,	purecloud_pure_cloud_contact_list_id_c
    ,	purecloud_reconciled_contact_results_c
    ,	purecloud_time_zone_c
    ,	purecloud_pure_cloud_campaign_status_c
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_campaign' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
