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
    ,	incident_number
    ,	record_type_id
    ,	created_date
    ,	created_by_id
    ,	last_modified_date
    ,	last_modified_by_id
    ,	system_modstamp
    ,	last_viewed_date
    ,	last_referenced_date
    ,	subject
    ,	description
    ,	parent_incident_id
    ,	detected_date_time
    ,	start_date_time
    ,	end_date_time
    ,	resolution_summary
    ,	resolved_by_id
    ,	resolution_date_time
    ,	status_code
    ,	status
    ,	impact
    ,	urgency
    ,	priority
    ,	reported_method
    ,	type
    ,	category
    ,	sub_category
    ,	priority_override_reason
    ,	is_major_incident
    ,	is_stopped
    ,	stop_start_date
    ,	sla_start_date
    ,	sla_exit_date
    ,	business_hours_id
    ,	milestone_status
    ,	is_closed
    ,	case_number_c
    ,	components_c
    ,	environment_c
    ,	escalated_c
    ,	network_incident_created_c
    ,	network_incident_resolved_c
    ,	network_incident_c
    ,	network_member_c
    ,	original_estimate_c
    ,	root_cause_details_c
    ,	root_cause_c
    ,	settlement_failed_or_rescheduled_c
    ,	severity_c
    ,	sub_type_c
    ,	team_c
    ,	timespent_c
    ,	total_impacted_workspaces_c
    ,	total_scheduled_settlement_c
    ,	triage_analysis_c
    ,	work_around_c
    ,	sub_category_c
    ,	sub_component_c
    ,	component_c
    ,	support_team_owner_c
    ,	create_case_c
    ,	incident_email_update_c
    ,	jira_reference_c
    ,	raised_by_c
    ,	defect_reference_c
    ,	destination_page_url_c
    ,	origin_page_url_c
    ,	technical_owner_c
    ,	workspace_id_c
    ,	incident_category_c
    ,	incident_subcategory_au_c
    ,	sub_sub_category_c
    ,	effort_spent_c
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_incident' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
    