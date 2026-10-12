
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_ps_subscription__c') %}  
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
            ,  to_date(lastactivitydate, 'YYYY-MM-DD') as last_activity_date
            ,  to_timestamp_tz(lastvieweddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            ,  to_timestamp_tz(lastreferenceddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            ,  ps_account__c as ps_account_c
            ,  ps_acln__c as ps_acln_c
            ,  ps_afin__c as ps_afin_c
            ,  ps_apcaiddestination__c as ps_apcaiddestination_c
            ,  ps_apcaidsources__c as ps_apcaidsources_c
            ,  ps_arbn__c as ps_arbn_c
            ,  ps_accountcategory__c as ps_account_category_c
            ,  to_date(ps_activationdate__c, 'YYYY-MM-DD') as ps_activation_date_c
            ,  CAST(ps_activedigitalcertificate__c as FLOAT) as ps_active_digital_certificate_c
            ,  ps_approvedforsoftcert__c as ps_approvedfor_soft_cert_c
            ,  ps_digitalsigningsoftwareversion__c as ps_digital_signing_software_version_c
            ,  ps_digitalsigningsoftware__c as ps_digital_signing_software_c
            ,  ps_esa__c as ps_esa_c
            ,  ps_entitytype__c as ps_entity_type_c
            ,  to_date(ps_expirydate__c, 'YYYY-MM-DD') as ps_expiry_date_c
            ,  ps_lenderofrecord__c as ps_lenderof_record_c
            ,  activationdateconverted__c as activationdate_converted_c
            ,  ps_microsoftwindowversion__c as ps_microsoft_window_version_c
            ,  ps_nonadi__c as ps_non_adi_c
            ,  ps_onboardingid__c as ps_onboarding_id_c
            ,  ps_othercategory__c as ps_other_category_c
            ,  ps_ownesaaccount__c as ps_own_esaaccount_c
            ,  ps_pasignedby__c as ps_pasigned_by_c
            ,  ps_paversion__c as ps_paversion_c
            ,  CAST(ps_pexarevenue__c as NUMBER) as ps_pexarevenue_c
            ,  ps_reasonforsuspension__c as ps_reasonfor_suspension_c
            ,  ps_reasonfortermination__c as ps_reasonfor_termination_c
            ,  ps_settlertype__c as ps_settler_type_c
            ,  ps_sponsor__c as ps_sponsor_c
            ,  ps_status__c as ps_status_c
            ,  ps_subcategory__c as ps_sub_category_c
            ,  ps_subscriberid__c as ps_subscriber_id_c
            ,  ps_subscriptiontype__c as ps_subscription_type_c
            ,  to_date(ps_suspensionterminationdate__c, 'YYYY-MM-DD') as ps_suspension_termination_date_c
            ,  ps_terminationother__c as ps_termination_other_c
            ,  ps_twofactorauthentication__c as ps_two_factor_authentication_c
            ,  ps_numberofpexausers__c as ps_numberofpexausers_c
            ,  ps_operatingmodelpreference__c as ps_operating_model_preference_c
            ,  ps_opportunityid__c as ps_opportunity_id_c
            ,  to_date(ps_expiry_date_2__c, 'YYYY-MM-DD') as ps_expiry_date_2_c
            ,  ps_masterpolicynumber__c as ps_master_policy_number_c
            ,  ps_master_policy_number_2__c as ps_master_policy_number_2_c
            ,  sf18_subscription_id__c as sf18_subscription_id_c
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