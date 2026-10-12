
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_ps_jurisdiction__c') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
              id as id
            ,  CAST(isdeleted as BOOLEAN) as is_deleted
            ,  name as name
            ,  to_timestamp_tz(createddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            ,  createdbyid as created_by_id
            ,  to_timestamp_tz(lastmodifieddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            ,  lastmodifiedbyid as last_modified_by_id
            ,  to_timestamp_tz(systemmodstamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            ,  to_date(lastactivitydate, 'YYYY-MM-DD') as last_activity_date
            ,  to_timestamp_tz(lastvieweddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            ,  to_timestamp_tz(lastreferenceddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            ,  ps_accountid__c as ps_accountid_c
            ,  to_date(ps_activationdate__c, 'YYYY-MM-DD') as ps_activation_date_c
            ,  ps_contact__c as ps_contact_c
            ,  ps_lrcode__c as ps_lrcode_c
            ,  ps_stampdutycode__c as ps_stamp_duty_code_c
            ,  ps_state__c as ps_state_c
            ,  ps_status__c as ps_status_c
            ,  ps_subscription__c as ps_subscription_c
            ,  to_date(ps_withdrawndate__c, 'YYYY-MM-DD') as ps_withdrawn_date_c
            ,  ps_withdrawnreason__c as ps_withdrawn_reason_c
            ,  to_date(conveyancers_triennialicence_expiry_date__c, 'YYYY-MM-DD') as conveyancers_triennia_licence_expiry_date_c
            ,  to_date(conveyancers_triennial_licence_date__c, 'YYYY-MM-DD') as conveyancers_triennial_licence_date_c
            ,  conveyancers_triennial_licence_name__c as conveyancers_triennial_licence_name_c
            ,  conveyancers_triennial_licence_number__c as conveyancers_triennial_licence_number_c
            ,  conveyancers_triennial_licence_type__c as conveyancers_triennial_licence_type_c
            ,  current_jurisdiction__c as current_jurisdiction_c
            ,  future_jurisdictions__c as future_jurisdictions_c
            ,  jurisdiction_type__c as jurisdiction_type_c
            ,  account_name__c as account_name_c
            ,  CAST(act__c as BOOLEAN) as act_c
            ,  current_jurisdiction_del__c as current_jurisdiction_del_c
            ,  future_jurisdictions_del__c as future_jurisdictions_del_c
            ,  CAST(nsw__c as BOOLEAN) as nsw_c
            ,  CAST(nt__c as BOOLEAN) as nt_c
            ,  CAST(qld__c as BOOLEAN) as qld_c
            ,  related_application__c as related_application_c
            ,  CAST(sa__c as BOOLEAN) as sa_c
            ,  state__c as state_c
            ,  CAST(tas__c as BOOLEAN) as tas_c
            ,  CAST(vic__c as BOOLEAN) as vic_c
            ,  CAST(wa__c as BOOLEAN) as wa_c
            ,  accountid__c as accountid_c
            ,  jurisdiction__c as jurisdiction_c
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