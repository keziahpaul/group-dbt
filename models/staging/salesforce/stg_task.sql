
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_task') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
              id as id
            ,  recordtypeid as record_type_id
            ,  whoid as who_id
            ,  whatid as what_id
            ,  CAST(whocount as NUMBER) as who_count
            ,  CAST(whatcount as NUMBER) as what_count
            ,  subject as subject
            ,  to_date(activitydate, 'YYYY-MM-DD') as activity_date
            ,  status as status
            ,  priority as priority
            ,  CAST(ishighpriority as BOOLEAN) as is_high_priority
            ,  ownerid as owner_id
            ,  description as description
            ,  CAST(isdeleted as BOOLEAN) as is_deleted
            ,  accountid as account_id
            ,  CAST(isclosed as BOOLEAN) as is_closed
            ,  to_timestamp_tz(createddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            ,  createdbyid as created_by_id
            ,  to_timestamp_tz(lastmodifieddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            ,  lastmodifiedbyid as last_modified_by_id
            ,  to_timestamp_tz(systemmodstamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            ,  CAST(isarchived as BOOLEAN) as is_archived
            ,  CAST(calldurationinseconds as NUMBER) as call_duration_in_seconds
            ,  calltype as call_type
            ,  calldisposition as call_disposition
            ,  callobject as call_object
            ,  to_timestamp_tz(reminderdatetime, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as reminder_date_time
            ,  CAST(isreminderset as BOOLEAN) as is_reminder_set
            ,  recurrenceactivityid as recurrence_activity_id
            ,  CAST(isrecurrence as BOOLEAN) as is_recurrence
            ,  to_date(recurrencestartdateonly, 'YYYY-MM-DD') as recurrence_start_date_only
            ,  to_date(recurrenceenddateonly, 'YYYY-MM-DD') as recurrence_end_date_only
            ,  recurrencetimezonesidkey as recurrence_time_zone_sid_key
            ,  recurrencetype as recurrence_type
            ,  CAST(recurrenceinterval as NUMBER) as recurrence_interval
            ,  CAST(recurrencedayofweekmask as NUMBER) as recurrence_day_of_week_mask
            ,  CAST(recurrencedayofmonth as NUMBER) as recurrence_day_of_month
            ,  recurrenceinstance as recurrence_instance
            ,  recurrencemonthofyear as recurrence_month_of_year
            ,  recurrenceregeneratedtype as recurrence_regenerated_type
            ,  tasksubtype as task_subtype
            ,  to_timestamp_tz(completeddatetime, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as completed_date_time
              , CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
            ,  case when isdeleted = true then 'D' else 'I' end as op
            ,  lead(op) over (partition by {{pk}} order by system_modstamp asc nulls first) as next_op
     from  {{ src_view_name }} 
     {% if is_incremental() %}
        where metadata_filename in {{ daily_refresh_stage(this,src_view_name) }}
     
     {% endif %} 
    ) 
    select 
     * exclude(next_op, op, system_modstamp_aest), 
     row_number() over (partition by {{pk}} order by system_modstamp asc nulls first) as row_num, 
     case when upper(op)='D' 
             then system_modstamp_aest 
         when upper(next_op) ='D' 
             then lead(system_modstamp_aest) over (partition by {{pk}} order by system_modstamp_aest asc nulls first)
         else null 
     end as deleted_at,
     {{ var('inserted_at' ) }} as inserted_at 
 from  initial