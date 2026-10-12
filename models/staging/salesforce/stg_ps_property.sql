
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_ps_property__c') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
              id as id
            ,  ownerid as owner_id
            ,  CAST(isdeleted as BOOLEAN) as is_deleted
            ,  name as name
            ,  to_timestamp_tz(createddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            ,  createdbyid as created_by_id
            ,  to_timestamp_tz(lastmodifieddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            ,  lastmodifiedbyid as last_modified_by_id
            ,  to_timestamp_tz(systemmodstamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            ,  to_timestamp_tz(lastvieweddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            ,  to_timestamp_tz(lastreferenceddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            ,  ps_addressline__c as ps_address_line_c
            ,  ps_consumer__c as ps_consumer_c
            ,  to_timestamp_tz(ps_invitationaccepteddate__c, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_invitation_accepted_date_c
            ,  to_timestamp_tz(ps_invitationdate__c, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_invitation_date_c
            ,  ps_organisation__c as ps_organisation_c
            ,  ps_partyid__c as ps_party_id_c
            ,  CAST(ps_postcode__c as FLOAT) as ps_post_code_c
            ,  ps_propertyclassification__c as ps_property_classification_c
            ,  CAST(ps_propertysettled__c as BOOLEAN) as ps_property_settled_c
            ,  to_timestamp_tz(ps_settlementdate__c, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_settlement_date_c
            ,  ps_settlementstatus__c as ps_settlement_status_c
            ,  ps_state__c as ps_state_c
            ,  ps_suburb__c as ps_suburb_c
            ,  ps_trackingid__c as ps_tracking_id_c
            ,  ps_trackingstatus__c as ps_tracking_status_c
            ,  ps_userrole__c as ps_user_role_c
            ,  ps_workspaceid__c as ps_workspace_id_c
            ,  country__c as country_c
            ,  full_workspace_number__c as full_workspace_number_c
            ,  opportunity__c as opportunity_c
            ,  CAST(purchase_price__c as FLOAT) as purchase_price_c
            ,  send_registration_id__c as send_registration_id_c
            ,  to_date(settlement_date__c, 'YYYY-MM-DD') as settlement_date_c
            ,  subscriber_id__c as subscriber_id_c
            ,  subscriber_reference__c as subscriber_reference_c
            ,  to_date(workspace_create_date__c, 'YYYY-MM-DD') as workspace_create_date_c
            ,  account_name__c as account_name_c
            ,  opportunity_owner__c as opportunity_owner_c
            ,  new_owner__c as new_owner_c
            ,  account_owner__c as account_owner_c
            ,  account_tier__c as account_tier_c
            ,  sales_outcome__c as sales_outcome_c
            ,  opportunity_stage__c as opportunity_stage_c
            ,  property_type__c as property_type_c
            ,  fx_api__c as fx_api_c
            ,  registration__c as registration_c
            ,  source__c as source_c
            ,  participant_id__c as participant_id_c
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