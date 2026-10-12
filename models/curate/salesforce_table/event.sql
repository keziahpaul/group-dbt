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
    ,	record_type_id
    ,	who_id
    ,	what_id
    ,	who_count
    ,	what_count
    ,	subject
    ,	location
    ,	is_all_day_event
    ,	activity_date_time
    ,	activity_date
    ,	duration_in_minutes
    ,	start_date_time
    ,	end_date_time
    ,	end_date
    ,	description
    ,	account_id
    ,	owner_id
    ,	type
    ,	is_private
    ,	show_as
    ,	is_deleted
    ,	is_child
    ,	is_group_event
    ,	group_event_type
    ,	created_date
    ,	created_by_id
    ,	last_modified_date
    ,	last_modified_by_id
    ,	system_modstamp
    ,	is_archived
    ,	recurrence_activity_id
    ,	is_recurrence
    ,	recurrence_start_date_time
    ,	recurrence_end_date_only
    ,	recurrence_time_zone_sid_key
    ,	recurrence_type
    ,	recurrence_interval
    ,	recurrence_day_of_week_mask
    ,	recurrence_day_of_month
    ,	recurrence_instance
    ,	recurrence_month_of_year
    ,	reminder_date_time
    ,	is_reminder_set
    ,	event_subtype
    ,	is_recurrence_2_exclusion
    ,	recurrence_2_pattern_text
    ,	recurrence_2_pattern_version
    ,	is_recurrence_2
    ,	is_recurrence_2_exception
    ,	recurrence_2_pattern_start_date
    ,	recurrence_2_pattern_time_zone
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_event' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
