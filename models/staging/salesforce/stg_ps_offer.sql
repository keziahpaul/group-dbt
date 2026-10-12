
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_ps_offer__c') %}  
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
            ,  to_timestamp_tz(lastvieweddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            ,  to_timestamp_tz(lastreferenceddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            ,  ps_provider__c as ps_provider_c
            ,  CAST(ps_daysfromsettlement__c as FLOAT) as ps_daysfrom_settlement_c
            ,  to_date(ps_expirydate__c, 'YYYY-MM-DD') as ps_expiry_date_c
            ,  ps_externalofferid__c as ps_external_offer_id_c
            ,  ps_fulfillmentendpoint__c as ps_fulfillment_endpoint_c
            ,  ps_fulfillmenttype__c as ps_fulfillment_type_c
            ,  ps_handoverdescription__c as ps_handover_description_c
            ,  ps_handoverfooter__c as ps_handover_footer_c
            ,  ps_handoverheader__c as ps_handover_header_c
            ,  ps_handoverimage__c as ps_handover_image_c
            ,  ps_handoverlogo__c as ps_handover_logo_c
            ,  ps_handovertitle__c as ps_handover_title_c
            ,  ps_jurisdiction__c as ps_jurisdiction_c
            ,  ps_offerbadge__c as ps_offer_badge_c
            ,  ps_offerlogo__c as ps_offer_logo_c
            ,  ps_postcode__c as ps_postcode_c
            ,  ps_propertyclassification__c as ps_property_classification_c
            ,  ps_settlementstatus__c as ps_settlement_status_c
            ,  to_date(ps_startdate__c, 'YYYY-MM-DD') as ps_start_date_c
            ,  ps_status__c as ps_status_c
            ,  ps_userrole__c as ps_user_role_c
            ,  CAST(ps_version__c as FLOAT) as ps_version_c
            ,  provider_name__c as provider_name_c
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