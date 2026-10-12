
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_case') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
            id as id
            ,cast(isdeleted as boolean) as is_deleted
            ,masterrecordid as master_record_id
            ,casenumber as case_number
            ,contactid as contact_id
            ,accountid as account_id
            ,sourceid as source_id
            ,businesshoursid as business_hours_id
            ,parentid as parent_id
            ,suppliedname as supplied_name
            ,suppliedemail as supplied_email
            ,suppliedphone as supplied_phone
            ,suppliedcompany as supplied_company
            ,type as type
            ,recordtypeid as record_type_id
            ,status as status
            ,reason as reason
            ,origin as origin
            ,language as language
            ,subject as subject
            ,priority as priority
            ,description as description
            ,cast(isclosed as boolean) as is_closed
            ,to_timestamp_tz(closeddate ,'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') as closed_date
            ,cast(isescalated as boolean) as is_escalated
            ,ownerid as owner_id
            ,cast(isclosedoncreate as boolean) as is_closed_on_create
            ,to_timestamp_tz(createddate ,'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') as created_date
            ,createdbyid as created_by_id
            ,to_timestamp_tz(lastmodifieddate ,'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') as last_modified_date
            ,lastmodifiedbyid as last_modified_by_id
            ,to_timestamp_tz(systemmodstamp ,'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') as system_modstamp
            ,contactphone as contact_phone
            ,contactmobile as contact_mobile
            ,contactemail as contact_email
            ,contactfax as contact_fax
            ,comments as comments
            ,to_timestamp_tz(lastvieweddate ,'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') as last_viewed_date
            ,to_timestamp_tz(lastreferenceddate ,'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') as last_referenced_date
            ,build_number__c as build_number_c
            ,cast(case_reopened__c as boolean) as case_reopened_c
            ,cause__c as cause_c
            ,cast(change_code_required__c as boolean) as change_code_required_c
            ,impact__c as impact_c
            ,integrated_service_partner__c as integrated_service_partner_c
            ,jira_reference__c as jira_reference_c
            ,to_date(planned_release_date__c , 'yyyy-mm-dd') as planned_release_date_c
            ,severity__c as severity_c
            ,sub_category__c as sub_category_c
            ,sub_sub_category__c as sub_sub_category_c
            ,subscription__c as subscription_c
            ,transaction_jurisdiction__c as transaction_jurisdiction_c
            ,urgency__c as urgency_c
            ,cast(work_around_available__c as boolean) as work_around_available_c
            ,additional_detail_for_customer_email__c as additional_detail_for_customer_email_c
            ,assignment_group__c as assignment_group_c
            ,case_close_plus_3__c as case_close_plus_3_c
            ,case_number_calc__c as case_number_calc_c
            ,cast(case_cannot_be_reopened__c as boolean) as case_cannot_be_reopened_c
            ,cast(clone_case__c as boolean) as clone_case_c
            ,cast(close_on_create__c as boolean) as close_on_create_c
            ,configuration_item__c as configuration_item_c
            ,contact_first_name__c as contact_first_name_c
            ,contact_last_surveyed_less_than_30_days__c as contact_last_surveyed_less_than_30_days_c
            ,to_date(date_contact_last_surveyed__c , 'yyyy-mm-dd') as date_contact_last_surveyed_c
            ,cast(email_received_more_than_3_days__c as boolean) as email_received_more_than_3_days_c
            ,integrated_service_partner2__c as integrated_service_partner_2_c
            ,integrated_service_partner_reference__c as integrated_service_partner_reference_c
            ,reason_for_contact_for_customer_email__c as reason_for_contact_for_customer_email_c
            ,resolution_notes_for_customer_email__c as resolution_notes_for_customer_email_c
            ,resolution__c as resolution_c
            ,send_survey__c as send_survey_c
            ,service_now_reference__c as service_now_reference_c
            ,to_date(settlement_date__c , 'yyyy-mm-dd') as settlement_date_c
            ,settlement_time__c as settlement_time_c
            ,transaction_type__c as transaction_type_c
            ,workspace_id__c as workspace_id_c
            ,cast(number_of_messages_received__c as float) as number_of_messages_received_c
            ,cast(number_of_messages_sent__c as float) as number_of_messages_sent_c
            ,jira_ticket_description__c as jira_ticket_description_c
            ,related_case__c as related_case_c
            ,cast(child_case_auto_email__c as boolean) as child_case_auto_email_c
            ,cast(resolved_email_sent__c as boolean) as resolved_email_sent_c
            ,first_call_resolution__c as first_call_resolution_c
            ,to_date(date_survey_last_sent__c , 'yyyy-mm-dd') as date_survey_last_sent_c
            ,to_timestamp_tz(update_upon_case_comments__c ,'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') as update_upon_case_comments_c
            ,pdb_reference__c as pdb_reference_c
            ,call_notes__c as call_notes_c
            ,settlement_time2__c as settlement_time_2_c
            ,case_owner_name__c as case_owner_name_c
            ,sf18_case_id__c as sf18_case_id_c
            ,parent_jira_reference__c as parent_jira_reference_c
            ,genesys_interaction_id__c as genesys_interaction_id_c
            ,case_label__c as case_label_c
            ,case_modified_plus_10__c as case_modified_plus_10_c
            ,cast(customer_progress__c as float) as customer_progress_c
            ,directdebtifinancialinstname__c as direct_debti_financial_inst_name_c
            ,existing_abn__c as existing_abn_c
            ,internal_status__c as internal_status_c
            ,is_this_a_new_registration__c as is_this_a_new_registration_c
            ,legal_entity_name__c as legal_entity_name_c
            ,new_registration__c as new_registration_c
            ,cast(not_a_new_registration__c as float) as not_a_new_registration_c
            ,payment_authoriser_1_name__c as payment_authoriser_1_name_c
            ,payment_authoriser_1_office_title__c as payment_authoriser_1_office_title_c
            ,payment_authoriser_2_name__c as payment_authoriser_2_name_c
            ,payment_authoriser_2_office_title__c as payment_authoriser_2_office_title_c
            ,payment_authoriser_3_name__c as payment_authoriser_3_name_c
            ,payment_authoriser_3_office_title__c as payment_authoriser_3_office_title_c
            ,payment_authoriser_4_name__c as payment_authoriser_4_name_c
            ,payment_authoriser_4_office_title__c as payment_authoriser_4_office_title_c
            ,payment_authoriser_5_name__c as payment_authoriser_5_name_c
            ,payment_authoriser_5_office_title__c as payment_authoriser_5_office_title_c
            ,cast(settlement_in_the_next_10_days__c as boolean) as settlement_in_the_next_10_days_c
            ,sub_manager__c as sub_manager_c
            ,trustfinancial_instiution_name__c as trust_financial_instiution_name_c
            ,validation_officer__c as validation_officer_c
            ,digital_certificate_1_name__c as digital_certificate_1_name_c
            ,digital_certificate_2_name__c as digital_certificate_2_name_c
            ,digital_certificate_3_name__c as digital_certificate_3_name_c
            ,digital_certificate_4_name__c as digital_certificate_4_name_c
            ,digital_certificate_5_name__c as digital_certificate_5_name_c
            ,digital_certificate_6_name__c as digital_certificate_6_name_c
            ,digital_certificate_7_name__c as digital_certificate_7_name_c
            ,digital_certificate_8_name__c as digital_certificate_8_name_c
            ,digital_certificate_1_email__c as digital_certificate_1_email_c
            ,digital_certificate_1_last_name__c as digital_certificate_1_last_name_c
            ,digital_certificate_1_middle_name__c as digital_certificate_1_middle_name_c
            ,digital_certificate_2_email__c as digital_certificate_2_email_c
            ,digital_certificate_2_last_name__c as digital_certificate_2_last_name_c
            ,digital_certificate_2_middle_name__c as digital_certificate_2_middle_name_c
            ,digital_certificate_3_email__c as digital_certificate_3_email_c
            ,digital_certificate_3_last_name__c as digital_certificate_3_last_name_c
            ,digital_certificate_3_middle_name__c as digital_certificate_3_middle_name_c
            ,digital_certificate_4_email__c as digital_certificate_4_email_c
            ,digital_certificate_4_last_name__c as digital_certificate_4_last_name_c
            ,digital_certificate_4_middle_name__c as digital_certificate_4_middle_name_c
            ,digital_certificate_5_email__c as digital_certificate_5_email_c
            ,digital_certificate_5_last_name__c as digital_certificate_5_last_name_c
            ,digital_certificate_5_middle_name__c as digital_certificate_5_middle_name_c
            ,digital_certificate_6_email__c as digital_certificate_6_email_c
            ,digital_certificate_6_last_name__c as digital_certificate_6_last_name_c
            ,digital_certificate_6_middle_name__c as digital_certificate_6_middle_name_c
            ,digital_certificate_7_email__c as digital_certificate_7_email_c
            ,digital_certificate_7_last_name__c as digital_certificate_7_last_name_c
            ,digital_certificate_7_middle_name__c as digital_certificate_7_middle_name_c
            ,digital_certificate_8_email__c as digital_certificate_8_email_c
            ,digital_certificate_8_last_name__c as digital_certificate_8_last_name_c
            ,digital_certificate_8_middle_name__c as digital_certificate_8_middle_name_c
            ,incident__c as incident_c
            ,to_timestamp_tz(automationdatetime__c ,'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') as automation_date_time_c
            ,case_resolution__c as case_resolution_c
            ,escalatethiscase__c as escalate_this_case_c
            ,mortgagereferenceid__c as mortgage_reference_id_c
            ,numberofimpactedusers__c as number_of_impacted_users_c
            ,isautomationbypassed__c as is_automation_bypassed_c
            ,contact_last_name__c as contact_last_name_c
            ,contact_middle_name__c as contact_middle_name_c
            ,fi_customer_number__c as fi_customer_number_c
            ,in_flight_transaction__c as in_flight_transaction_c
            ,jurisdiction__c as jurisdiction_c
            ,lodgement_status__c as lodgement_status_c
            ,reference_number__c as reference_number_c
            ,legacy_id__c as legacy_id_c
            ,contactfullname__c as contact_full_name_c
            ,cast(identifiedinternally__c as boolean) as identified_internally_c
            ,to_date(digital_certificate_expiry_date__c , 'yyyy-mm-dd') as digital_certificate_expiry_date_c
            ,external_survey_invitation_link__c as external_survey_invitation_link_c
            ,to_date(srp_due_date__c , 'yyyy-mm-dd') as srp_due_date_c
            ,srp_invitationid__c as srp_invitation_id_c
            ,srp_review_outcome__c as srp_review_outcome_c
            ,srp_survey_invite__c as srp_survey_invite_c
            ,destination_page_url__c as destination_page_url_c
            ,origin_page_url__c as origin_page_url_c
            ,cast(parent_incident_closed__c as boolean) as parent_incident_closed_c
            ,cast(reminder_sent__c as boolean) as reminder_sent_c
            ,jira_ticket__c as jira_ticket_c
            ,root_cause_detail__c as root_cause_detail_c
            ,root_cause__c as root_cause_c
            ,sev__c as sev_c
            ,slack_link__c as slack_link_c
            ,user__c as user_c
            ,latest_survey_score__c as latest_survey_score_c
            ,all_survey_response__c as all_survey_response_c
            --   ,SRP_RESPONSE__C as SRP_RESPONSE_C -- not readable from salesforce
            --   ,SURVEY_INVITATION__C as SURVEY_INVITATION_C -- not readable from salesforce
            --   ,SRP_RESPONSE_LOOKUP__C as SRP_RESPONSE_LOOKUP_C -- not readable from salesforce
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