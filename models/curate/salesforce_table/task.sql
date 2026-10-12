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
    ,	activity_date
    ,	status
    ,	priority
    ,	is_high_priority
    ,	owner_id
    ,	description
    ,	is_deleted
    ,	account_id
    ,	is_closed
    ,	created_date
    ,	created_by_id
    ,	last_modified_date
    ,	last_modified_by_id
    ,	system_modstamp
    ,	is_archived
    ,	call_duration_in_seconds
    ,	call_type
    ,	call_disposition
    ,	call_object
    ,	reminder_date_time
    ,	is_reminder_set
    ,	recurrence_activity_id
    ,	is_recurrence
    ,	recurrence_start_date_only
    ,	recurrence_end_date_only
    ,	recurrence_time_zone_sid_key
    ,	recurrence_type
    ,	recurrence_interval
    ,	recurrence_day_of_week_mask
    ,	recurrence_day_of_month
    ,	recurrence_instance
    ,	recurrence_month_of_year
    ,	recurrence_regenerated_type
    ,	task_subtype
    ,   completed_date_time
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_task' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
