
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_ps_productservicestatus__c') %}  
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
            ,  ps_subscription__c as ps_subscription_c
            ,  ps_productservicename__c as ps_product_service_name_c
            ,  ps_ragicon__c as ps_ragicon_c
            ,  ps_ragstatus__c as ps_rag_status_c
            ,  ps_status__c as ps_status_c
            ,  account__c as account_c
            ,  CAST(do_not_talk_to_me_about_this_product__c as BOOLEAN) as do_not_talk_to_me_about_this_product_c
            ,  product_notes__c as product_notes_c
            ,  reason__c as reason_c
            ,  to_date(date_registered__c, 'YYYY-MM-DD') as date_registered_c
            ,  product_registration_id__c as product_registration_id_c
            ,  CAST(all_other_volume_immot_last_fy__c as FLOAT) as all_other_volume_immot_last_fy_c
            ,  CAST(all_other_volume_im_mot_current_fy__c as FLOAT) as all_other_volume_im_mot_current_fy_c
            ,  CAST(all_other_volume_im_mot_last_fy_minus1__c as FLOAT) as all_other_volume_im_mot_last_fy_minus_1_c
            ,  CAST(incoming_revenue_current_fy__c as FLOAT) as incoming_revenue_current_fy_c
            ,  CAST(incoming_revenue_last_fy_minus1__c as FLOAT) as incoming_revenue_last_fy_minus_1_c
            ,  CAST(incoming_revenue_last_fy__c as FLOAT) as incoming_revenue_last_fy_c
            ,  CAST(institution_revenue_current_fy__c as FLOAT) as institution_revenue_current_fy_c
            ,  CAST(institution_revenue_last_fy_minus1__c as FLOAT) as institution_revenue_last_fy_minus_1_c
            ,  CAST(institution_revenue_last_fy__c as FLOAT) as institution_revenue_last_fy_c
            ,  CAST(outgoing_revenue_current_fy__c as FLOAT) as outgoing_revenue_current_fy_c
            ,  CAST(outgoing_revenue_last_fy_minus1__c as FLOAT) as outgoing_revenue_last_fy_minus_1_c
            ,  CAST(outgoing_revenue_last_fy__c as FLOAT) as outgoing_revenue_last_fy_c
            ,  CAST(refinance_volume_immot_last_fy__c as FLOAT) as refinance_volume_immot_last_fy_c
            ,  CAST(refinance_volume_im_mot_current_fy__c as FLOAT) as refinance_volume_im_mot_current_fy_c
            ,  CAST(refinance_volume_im_mot_last_fy_minus1__c as FLOAT) as refinance_volume_im_mot_last_fy_minus_1_c
            ,  CAST(standalones_volume_immot_last_fy__c as FLOAT) as standalones_volume_immot_last_fy_c
            ,  CAST(standalones_volume_im_mot_current_fy__c as FLOAT) as standalones_volume_im_mot_current_fy_c
            ,  CAST(standalones_volume_im_mot_last_fy_minus1__c as FLOAT) as standalones_volume_im_mot_last_fy_minus_1_c
            ,  CAST(total_transaction_volume_current_fy__c as FLOAT) as total_transaction_volume_current_fy_c
            ,  CAST(total_transaction_volume_last_fy_minus1__c as FLOAT) as total_transaction_volume_last_fy_minus_1_c
            ,  CAST(total_transaction_volume_last_fy__c as FLOAT) as total_transaction_volume_last_fy_c
            ,  CAST(transfer_volume_immot_last_fy__c as FLOAT) as transfer_volume_immot_last_fy_c
            ,  CAST(transfer_volume_im_mot_current_fy__c as FLOAT) as transfer_volume_im_mot_current_fy_c
            ,  CAST(transfer_volume_im_mot_last_fy_minus1__c as FLOAT) as transfer_volume_im_mot_last_fy_minus_1_c
            ,  externalid__c as external_id_c
            ,  CAST(total_workspace_revenue_current_fy__c as FLOAT) as total_workspace_revenue_current_fy_c
            ,  to_date(last_transaction_date__c, 'YYYY-MM-DD') as last_transaction_date_c
            ,  to_date(first_transaction_date__c, 'YYYY-MM-DD') as first_transaction_date_c
            ,  subscriber_id__c as subscriber_id_c
            ,  CAST(all_other_volume_im_current_fy__c as FLOAT) as all_other_volume_im_current_fy_c
            ,  CAST(all_other_volume_im_last_fy__c as FLOAT) as all_other_volume_im_last_fy_c
            ,  CAST(all_other_volume_im_last_fy_minus1__c as FLOAT) as all_other_volume_im_last_fy_minus_1_c
            ,  CAST(all_other_volume_mot_current_fy__c as FLOAT) as all_other_volume_mot_current_fy_c
            ,  CAST(all_other_volume_mot_last_fy_1__c as FLOAT) as all_other_volume_mot_last_fy_1_c
            ,  CAST(all_other_volume_mot_last_fy__c as FLOAT) as all_other_volume_mot_last_fy_c
            ,  CAST(refinance_volume_im_current_fy__c as FLOAT) as refinance_volume_im_current_fy_c
            ,  CAST(refinance_volume_im_last_fy_minus1__c as FLOAT) as refinance_volume_im_last_fy_minus_1_c
            ,  CAST(refinance_volume_im_last_fy__c as FLOAT) as refinance_volume_im_last_fy_c
            ,  CAST(refinance_volume_mot_current_fy__c as FLOAT) as refinance_volume_mot_current_fy_c
            ,  CAST(refinance_volume_mot_last_fy_1__c as FLOAT) as refinance_volume_mot_last_fy_1_c
            ,  CAST(refinance_volume_mot_last_fy__c as FLOAT) as refinance_volume_mot_last_fy_c
            ,  CAST(standalones_volume_im_current_fy__c as FLOAT) as standalones_volume_im_current_fy_c
            ,  CAST(standalones_volume_im_last_fy_minus1__c as FLOAT) as standalones_volume_im_last_fy_minus_1_c
            ,  CAST(standalones_volume_im_last_fy__c as FLOAT) as standalones_volume_im_last_fy_c
            ,  CAST(standalones_volume_mot_current_fy__c as FLOAT) as standalones_volume_mot_current_fy_c
            ,  CAST(standalones_volume_mot_last_fy_1__c as FLOAT) as standalones_volume_mot_last_fy_1_c
            ,  CAST(standalones_volume_mot_last_fy__c as FLOAT) as standalones_volume_mot_last_fy_c
            ,  CAST(total_exchange_reveneu_pfy__c as FLOAT) as total_exchange_reveneu_pfy_c
            ,  CAST(total_exchange_revenue_current_fy__c as FLOAT) as total_exchange_revenue_current_fy_c
            ,  CAST(total_non_exchange_revenue_cfy__c as FLOAT) as total_non_exchange_revenue_cfy_c
            ,  CAST(total_non_exchange_revenue_pfy__c as FLOAT) as total_non_exchange_revenue_pfy_c
            ,  CAST(total_non_exchange_volume__c as FLOAT) as total_non_exchange_volume_c
            ,  CAST(total_non_exchange__c as FLOAT) as total_non_exchange_c
            ,  CAST(total_revenu_pfy__c as FLOAT) as total_revenu_pfy_c
            ,  CAST(total_revenue__c as FLOAT) as total_revenue_c
            ,  CAST(total_volume_pfy__c as FLOAT) as total_volume_pfy_c
            ,  CAST(total_volume__c as FLOAT) as total_volume_c
            ,  CAST(transfer_volume_im_current_fy__c as FLOAT) as transfer_volume_im_current_fy_c
            ,  CAST(transfer_volume_im_last_fy_minus1__c as FLOAT) as transfer_volume_im_last_fy_minus_1_c
            ,  CAST(transfer_volume_im_last_fy__c as FLOAT) as transfer_volume_im_last_fy_c
            ,  CAST(transfer_volume_mot_current_fy__c as FLOAT) as transfer_volume_mot_current_fy_c
            ,  CAST(transfer_volume_mot_last_fy_1__c as FLOAT) as transfer_volume_mot_last_fy_1_c
            ,  CAST(transfer_volume_mot_last_fy__c as FLOAT) as transfer_volume_mot_last_fy_c
            ,  CAST(foreign_properties_all_time__c as FLOAT) as foreign_properties_all_time_c
            ,  CAST(pexa_commission__c as FLOAT) as pexa_commission_c
            ,  registration_am__c as registration_am_c
            ,  CAST(send_registration_opt_in__c as BOOLEAN) as send_registration_opt_in_c
            ,  CAST(settled_turnover__c as FLOAT) as settled_turnover_c
            ,  CAST(total_volume_buyer_cfy__c as FLOAT) as total_volume_buyer_cfy_c
            ,  CAST(total_volume_seller_cfy__c as FLOAT) as total_volume_seller_cfy_c
            ,  CAST(total_transaction_volume_currentfy__c as FLOAT) as total_transaction_volume_currentfy_c
            ,  CAST(total_workspace_revenue_currentfy__c as FLOAT) as total_workspace_revenue_currentfy_c
            ,  CAST(transfer_volume_im_mot_currentfy__c as FLOAT) as transfer_volume_im_mot_currentfy_c
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