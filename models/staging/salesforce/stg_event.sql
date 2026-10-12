
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_event') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
            id as id
            ,    recordtypeid as record_type_id
            ,    whoid as who_id
            ,    whatid as what_id
            ,    CAST(whocount as NUMBER) as who_count
            ,    CAST(whatcount as NUMBER) as what_count
            ,    subject as subject
            ,    location as location
            ,    CAST(isalldayevent as BOOLEAN) as is_all_day_event
            ,    to_timestamp_tz(activitydatetime, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as activity_date_time
            ,    to_date(activitydate, 'YYYY-MM-DD') as activity_date
            ,    CAST(durationinminutes as NUMBER) as duration_in_minutes
            ,    to_timestamp_tz(startdatetime, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as start_date_time
            ,    to_timestamp_tz(enddatetime, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as end_date_time
            ,    to_date(enddate, 'YYYY-MM-DD') as end_date
            ,    description as description
            ,    accountid as account_id
            ,    ownerid as owner_id
            ,    type as type
            ,    CAST(isprivate as BOOLEAN) as is_private
            ,    showas as show_as
            ,    CAST(isdeleted as BOOLEAN) as is_deleted
            ,    CAST(ischild as BOOLEAN) as is_child
            ,    CAST(isgroupevent as BOOLEAN) as is_group_event
            ,    groupeventtype as group_event_type
            ,    to_timestamp_tz(createddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            ,    createdbyid as created_by_id
            ,    to_timestamp_tz(lastmodifieddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            ,    lastmodifiedbyid as last_modified_by_id
            ,    to_timestamp_tz(systemmodstamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            ,    CAST(isarchived as BOOLEAN) as is_archived
            ,    recurrenceactivityid as recurrence_activity_id
            ,    CAST(isrecurrence as BOOLEAN) as is_recurrence
            ,    to_timestamp_tz(recurrencestartdatetime, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as recurrence_start_date_time
            ,    to_date(recurrenceenddateonly, 'YYYY-MM-DD') as recurrence_end_date_only
            ,    recurrencetimezonesidkey as recurrence_time_zone_sid_key
            ,    recurrencetype as recurrence_type
            ,    CAST(recurrenceinterval as NUMBER) as recurrence_interval
            ,    CAST(recurrencedayofweekmask as NUMBER) as recurrence_day_of_week_mask
            ,    CAST(recurrencedayofmonth as NUMBER) as recurrence_day_of_month
            ,    recurrenceinstance as recurrence_instance
            ,    recurrencemonthofyear as recurrence_month_of_year
            ,    to_timestamp_tz(reminderdatetime, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as reminder_date_time
            ,    CAST(isreminderset as BOOLEAN) as is_reminder_set
            ,    eventsubtype as event_subtype
            ,    CAST(isrecurrence2exclusion as BOOLEAN) as is_recurrence_2_exclusion
            ,    recurrence2patterntext as recurrence_2_pattern_text
            ,    recurrence2patternversion as recurrence_2_pattern_version
            ,    CAST(isrecurrence2 as BOOLEAN) as is_recurrence_2
            ,    CAST(isrecurrence2exception as BOOLEAN) as is_recurrence_2_exception
            ,    to_timestamp_tz(recurrence2patternstartdate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as recurrence_2_pattern_start_date
            ,    recurrence2patterntimezone as recurrence_2_pattern_time_zone
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