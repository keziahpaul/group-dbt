
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_incident') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
            id as id
            ,  ownerid as owner_id
            ,  CAST(isdeleted as BOOLEAN) as is_deleted
            ,  incidentnumber as incident_number
            ,  recordtypeid as record_type_id
            ,  to_timestamp_tz(createddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            ,  createdbyid as created_by_id
            ,  to_timestamp_tz(lastmodifieddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            ,  lastmodifiedbyid as last_modified_by_id
            ,  to_timestamp_tz(systemmodstamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            ,  to_timestamp_tz(lastvieweddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            ,  to_timestamp_tz(lastreferenceddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            ,  subject as subject
            ,  description as description
            ,  parentincidentid as parent_incident_id
            ,  to_timestamp_tz(detecteddatetime, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as detected_date_time
            ,  to_timestamp_tz(startdatetime, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as start_date_time
            ,  to_timestamp_tz(enddatetime, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as end_date_time
            ,  resolutionsummary as resolution_summary
            ,  resolvedbyid as resolved_by_id
            ,  to_timestamp_tz(resolutiondatetime, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as resolution_date_time
            ,  statuscode as status_code
            ,  status as status
            ,  impact as impact
            ,  urgency as urgency
            ,  priority as priority
            ,  reportedmethod as reported_method
            ,  type as type
            ,  category as category
            ,  subcategory as sub_category
            ,  priorityoverridereason as priority_override_reason
            ,  CAST(ismajorincident as BOOLEAN) as is_major_incident
            ,  CAST(isstopped as BOOLEAN) as is_stopped
            ,  to_timestamp_tz(stopstartdate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as stop_start_date
            ,  to_timestamp_tz(slastartdate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as sla_start_date
            ,  to_timestamp_tz(slaexitdate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as sla_exit_date
            ,  businesshoursid as business_hours_id
            ,  milestonestatus as milestone_status
            ,  CAST(isclosed as BOOLEAN) as is_closed
            ,  casenumber__c as case_number_c
            ,  components__c as components_c
            ,  environment__c as environment_c
            ,  escalated__c as escalated_c
            ,  networkincidentcreated__c as network_incident_created_c
            ,  networkincidentresolved__c as network_incident_resolved_c
            ,  networkincident__c as network_incident_c
            ,  networkmember__c as network_member_c
            ,  original_estimate__c as original_estimate_c
            ,  rootcausedetails__c as root_cause_details_c
            ,  root_cause__c as root_cause_c
            ,  settlementfailedorrescheduled__c as settlement_failed_or_rescheduled_c
            ,  severity__c as severity_c
            ,  sub_type__c as sub_type_c
            ,  team__c as team_c
            ,  timespent__c as timespent_c
            ,  totalimpactedworkspaces__c as total_impacted_workspaces_c
            ,  totalscheduledsettlement__c as total_scheduled_settlement_c
            ,  triage_analysis__c as triage_analysis_c
            ,  workaround__c as work_around_c
            ,  subcategory__c as sub_category_c
            ,  sub_component__c as sub_component_c
            ,  component__c as component_c
            ,  supportteamowner__c as support_team_owner_c
            ,  createcase__c as create_case_c
            ,  incidentemailupdate__c as incident_email_update_c
            ,  jirareference__c as jira_reference_c
            ,  raised_by__c as raised_by_c
            ,  defect_reference__c as defect_reference_c
            ,  destination_page_url__c as destination_page_url_c
            ,  origin_page_url__c as origin_page_url_c
            ,  technical_owner__c as technical_owner_c
            ,  workspace_id__c as workspace_id_c
            ,  incident_category__c as incident_category_c
            ,  incident_subcategory_au__c as incident_subcategory_au_c
            ,  sub_sub_category__c as sub_sub_category_c
            ,  effort_spent__c as effort_spent_c
            --  , ENTITLEMENTID as ENTITLEMENT_ID. -- not readable from salesforce
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