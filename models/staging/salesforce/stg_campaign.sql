
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_campaign') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
            id as id
            , CAST(isdeleted AS BOOLEAN) as is_deleted
            , name as name
            , parentid as parent_id
            , type as type
            , status as status
            , to_date(startdate, 'YYYY-MM-DD') as start_date
            , to_date(enddate, 'YYYY-MM-DD') as end_date
            , CAST(expectedrevenue AS NUMBER) as expected_revenue
            , CAST(budgetedcost AS NUMBER) as budgeted_cost
            , CAST(actualcost AS NUMBER) as actual_cost
            , CAST(expectedresponse AS FLOAT) as expected_response
            , CAST(numbersent AS FLOAT) as number_sent
            , CAST(isactive AS BOOLEAN) as is_active
            , description as description
            , CAST(numberofleads AS NUMBER) as number_of_leads
            , CAST(numberofconvertedleads AS NUMBER) as number_of_converted_leads
            , CAST(numberofcontacts AS NUMBER) as number_of_contacts
            , CAST(numberofresponses AS NUMBER) as number_of_responses
            , CAST(numberofopportunities AS NUMBER) as number_of_opportunities
            , CAST(numberofwonopportunities AS NUMBER) as number_of_won_opportunities
            , CAST(amountallopportunities AS NUMBER) as amount_all_opportunities
            , CAST(amountwonopportunities AS NUMBER) as amount_won_opportunities
            , CAST(hierarchynumberofleads AS NUMBER) as hierarchy_number_of_leads
            , CAST(hierarchynumberofconvertedleads AS NUMBER) as hierarchy_number_of_converted_leads
            , CAST(hierarchynumberofcontacts AS NUMBER) as hierarchy_number_of_contacts
            , CAST(hierarchynumberofresponses AS NUMBER) as hierarchy_number_of_responses
            , CAST(hierarchynumberofopportunities AS NUMBER) as hierarchy_number_of_opportunities
            , CAST(hierarchynumberofwonopportunities AS NUMBER) as hierarchy_number_of_won_opportunities
            , CAST(hierarchyamountallopportunities AS NUMBER) as hierarchy_amount_all_opportunities
            , CAST(hierarchyamountwonopportunities AS NUMBER) as hierarchy_amount_won_opportunities
            , CAST(hierarchynumbersent AS FLOAT) as hierarchy_number_sent
            , CAST(hierarchyexpectedrevenue AS NUMBER) as hierarchy_expected_revenue
            , CAST(hierarchybudgetedcost AS NUMBER) as hierarchy_budgeted_cost
            , CAST(hierarchyactualcost AS NUMBER) as hierarchy_actual_cost
            , ownerid as owner_id
            , to_timestamp_tz(createddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            , createdbyid as created_by_id
            , to_timestamp_tz(lastmodifieddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            , lastmodifiedbyid as last_modified_by_id
            , to_timestamp_tz(systemmodstamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            , to_date(lastactivitydate, 'YYYY-MM-DD') as last_activity_date
            , to_timestamp_tz(lastvieweddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            , to_timestamp_tz(lastreferenceddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            , campaignmemberrecordtypeid as campaign_member_record_type_id
            , to_timestamp_tz(purecloud__adjusted_end_date_time__c, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as purecloud_adjusted_end_date_time_c
            , to_timestamp_tz(purecloud__adjusted_start_date_time__c, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as purecloud_adjusted_start_date_time_c
            , CAST(purecloud__failed_attempts_to_reconcile_results__c AS FLOAT) as purecloud_failed_attempts_to_reconcile_results_c
            , purecloud__purecloud_campaign_id__c as purecloud_pure_cloud_campaign_id_c
            , purecloud__purecloud_campaign_priority__c as purecloud_pure_cloud_campaign_priority_c
            , purecloud__purecloud_contact_list_id__c as purecloud_pure_cloud_contact_list_id_c
            , CAST(purecloud__reconciled_contact_results__c AS BOOLEAN) as purecloud_reconciled_contact_results_c
            , purecloud__time_zone__c as purecloud_time_zone_c
            , purecloud__purecloud_campaign_status__c as purecloud_pure_cloud_campaign_status_c
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