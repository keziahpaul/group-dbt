
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_digital_certificate__c') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
            id as id
            , cast(isdeleted as boolean) as is_deleted
            , name as name
            , to_timestamp_tz(createddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            , createdbyid as created_by_id
            , to_timestamp_tz(lastmodifieddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            , lastmodifiedbyid as last_modified_by_id
            , to_timestamp_tz(systemmodstamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            , to_timestamp_tz(lastvieweddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            , to_timestamp_tz(lastreferenceddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            , account__c as account_c
            , contact__c as contact_c
            , email_for_symantec_digital_certificate__c as email_for_symantec_digital_certificate_c
            , cast(obtain_digital_certificate__c as boolean) as obtain_digital_certificate_c
            , cast(symantec_digital_certificate__c as boolean) as symantec_digital_certificate_c
            , related_application__c as related_application_c
            , requires_a_new_digital_certificate__c as requires_a_new_digital_certificate_c
            , symantec_digital_certificate_suitable_fo__c as symantec_digital_certificate_suitable_fo_c
            , requires_additional_digital_certificate__c as requires_additional_digital_certificate_c
            , authorisor_email__c as authorisor_email_c
            , authorisor_name__c as authorisor_name_c
            , to_date(certificate_expiry_date__c, 'YYYY-MM-DD') as certificate_expiry_date_c
            , certificate_holder_type__c as certificate_holder_type_c
            , certificate_status__c as certificate_status_c
            , certificate_type__c as certificate_type_c
            , city__c as city_c
            , to_date(date_form_received__c, 'YYYY-MM-DD') as date_form_received_c
            , to_date(date_ordered__c, 'YYYY-MM-DD') as date_ordered_c
            , to_date(date_requested__c, 'YYYY-MM-DD') as date_requested_c
            , to_date(date_terminated__c, 'YYYY-MM-DD') as date_terminated_c
            , express_post_tracking_number__c as express_post_tracking_number_c
            , express_post__c as express_post_c
            , order_status__c as order_status_c
            , postcode__c as postcode_c
            , previous_digital_certificate__c as previous_digital_certificate_c
            , cast(primary_certificate__c as boolean) as primary_certificate_c
            , re_ordered__c as re_ordered_c
            , reason_for_fee_waiver__c as reason_for_fee_waiver_c
            , reason_for_termination__c as reason_for_termination_c
            , state__c as state_c
            , street_1__c as street_1_c
            , street_2__c as street_2_c
            , street_3__c as street_3_c
            , subscriber_id__c as subscriber_id_c
            , verizon_apply_charge__c as verizon_apply_charge_c
            , verizon_certificate_required__c as verizon_certificate_required_c
            , verizon_portal_status__c as verizon_portal_status_c
            , email_for_symantec_digital_ceriticate__c as email_for_symantec_digital_ceriticate_c
            , comments__c as comments_c
            , legacy_id__c as legacy_id_c
            , pexa_symantec__c as pexa_symantec_c
            , email_for_digital_certificate_c__c as email_for_digital_certificate_c_c
            , email_for_digital_certificate__c as email_for_digital_certificate_c
            , sf18digitdigicert__c as sf18digitdigicert_c
                -- ,MOBILE_SIGNING_CERTIFICATE__C as MOBILE_SIGNING_CERTIFICATE_C. --not readable from salesforce
                ,CERTIFICATE_PROVIDER__C as CERTIFICATE_PROVIDER_C
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