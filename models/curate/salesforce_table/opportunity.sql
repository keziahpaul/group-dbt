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
    ,	account_id
    ,	record_type_id
    ,	is_private
    ,	name
    ,	description
    ,	stage_name
    ,	amount
    ,	probability
    ,	expected_revenue
    ,	total_opportunity_quantity
    ,	close_date
    ,	type
    ,	next_step
    ,	lead_source
    ,	is_closed
    ,	is_won
    ,	forecast_category
    ,	forecast_category_name
    ,	campaign_id
    ,	has_opportunity_line_item
    ,	owner_id
    ,	created_date
    ,	created_by_id
    ,	last_modified_date
    ,	last_modified_by_id
    ,	system_modstamp
    ,	last_activity_date
    ,	push_count
    ,	last_stage_change_date
    ,	fiscal_quarter
    ,	fiscal_year
    ,	fiscal
    ,	contact_id
    ,	last_viewed_date
    ,	last_referenced_date
    ,	has_open_activity
    ,	has_overdue_task
    ,	last_amount_changed_history_id
    ,	last_close_date_changed_history_id
    ,	budget_confirmed_c
    ,	discovery_completed_c
    ,	roi_analysis_completed_c
    ,	ps_acln_c
    ,	loss_reason_c
    ,	ps_demonstration_completed_c
    ,	ps_expiry_lapsing_date_c
    ,	ps_lead_valueifknown_c
    ,	ps_loss_reason_c
    ,	ps_mouissued_c
    ,	ps_moureturned_c
    ,	ps_mousigned_c
    ,	ps_non_adi_c
    ,	ps_onboarding_id_c
    ,	ps_operating_model_preference_c
    ,	ps_opportunity_record_type_name_c
    ,	ps_other_reason_c
    ,	ps_shared_sales_collateral_c
    ,	ps_subscriber_id_c
    ,	ps_subscription_name_c
    ,	primary_contact_c
    ,	win_reason_c
    ,	sales_performance_opportunity_c
    ,	product_name_c
    ,	account_tier_c
    ,	new_owner_c
    ,	new_properties_c
    ,	properties_c
    ,	workspace_id_c 
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_opportunity' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
 