with 

source as ( 

    select * from {{ ref('task') }}

)
    select
        id,
        record_type_id,
        who_id,
        what_id,
        who_count,
        what_count,
        subject,
        activity_date,
        status,
        priority,
        is_high_priority,
        owner_id,
        description,
        is_deleted,
        account_id,
        is_closed,
        created_date,
        created_by_id,
        last_modified_date,
        last_modified_by_id,
        system_modstamp,
        is_archived,
        call_duration_in_seconds,
        call_type,
        call_disposition,
        call_object,
        reminder_date_time,
        is_reminder_set,
        recurrence_activity_id,
        is_recurrence,
        recurrence_start_date_only,
        recurrence_end_date_only,
        recurrence_time_zone_sid_key,
        recurrence_type,
        recurrence_interval,
        recurrence_day_of_week_mask,
        recurrence_day_of_month,
        recurrence_instance,
        recurrence_month_of_year,
        recurrence_regenerated_type,
        task_subtype,
        completed_date_time,
        effective_from,
        effective_to,
        inserted_at,
        updated_at  

    from source
    where effective_to::date = '{{var('active_date')}}'::date
    