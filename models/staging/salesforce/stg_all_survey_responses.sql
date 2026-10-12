
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_all_survey_responses__c') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
            id as id
            ,ownerid as owner_id
            ,cast(isdeleted as boolean) as is_deleted
            ,name as name
            ,to_timestamp_tz(createddate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            ,createdbyid as created_by_id
            ,to_timestamp_tz(lastmodifieddate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            ,lastmodifiedbyid as last_modified_by_id
            ,to_timestamp_tz(systemmodstamp ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            ,to_timestamp_tz(lastvieweddate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            ,to_timestamp_tz(lastreferenceddate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            ,am_comments__c as am_comments_c
            ,cast(csat__c as float) as csat_c
            ,cast(cstat_am__c as float) as cstat_am_c
            ,customer_priorities__c as customer_priorities_c
            ,customer_support_verbatim__c as customer_support_verbatim_c
            ,cast(importance_currency__c as float) as importance_currency_c
            ,pexapositives__c as pexapositives_c
            ,pexaimprovements__c as pexaimprovements_c
            ,related_case__c as related_case_c
            ,related_contact__c as related_contact_c
            ,survey_business_name__c as survey_business_name_c
            ,exchange_subscriber_id__c as exchange_subscriber_id_c
            ,exchange_survey_type__c as exchange_survey_type_c
            ,exchange_user_id__c as exchange_user_id_c
            ,inmomentresponse_id__c as inmoment_response_id_c
            ,journey__c as journey_c
            ,survey_id__c as survey_id_c
            ,cast(personalised_experience__c as float) as personalised_experience_c
            ,cast(receive_value_by_using_pexa__c as float) as receive_value_by_using_pexa_c
            ,cast(pexa_exchange_value__c as float) as pexa_exchange_value_c
            ,cast(service_experience__c as float) as service_experience_c
            ,cast(experience_expectations__c as float) as experience_expectations_c
            ,cast(plan_to_user_additional_products__c as float) as plan_to_user_additional_products_c
            ,cast(am_shares_continious_learnings__c as float) as am_shares_continious_learnings_c
            ,cast(pexa_source_account__c as float) as pexa_source_account_c
            ,cast(finding_new_ways_to_obtain_clients__c as float) as finding_new_ways_to_obtain_clients_c
            ,cast(represent_a_property_developer__c as float) as represent_a_property_developer_c
            ,cast(timely_insights_market_trends__c as float) as timely_insights_market_trends_c
            ,cast(insights_on_industyr_best_practice__c as float) as insights_on_industyr_best_practice_c
            ,cast(access_to_online_training_materials__c as float) as access_to_online_training_materials_c
            ,cast(climate_and_environmental_data__c as float) as climate_and_environmental_data_c
            ,cast(api_productivity_interest__c as float) as api_productivity_interest_c
            ,cast(pexa_rep_in_your_state__c as float) as pexa_rep_in_your_state_c
            ,cast(growing_your_business__c as float) as growing_your_business_c
            ,cast(call_support_for_help__c as float) as call_support_for_help_c
            ,cast(expanding_your_professional_network__c as float) as expanding_your_professional_network_c
            ,cast(continued_pd__c as float) as continued_pd_c
            ,cast(am_interest_in_business_needs__c as float) as am_interest_in_business_needs_c
            ,cast(am_responds_in_timely_manner__c as float) as am_responds_in_timely_manner_c
            ,cast(am_shares_relevant_insights__c as float) as am_shares_relevant_insights_c
            ,cast(am_easy_to_deal__c as float) as am_easy_to_deal_c
            ,cast(am_provides_solutions__c as float) as am_provides_solutions_c
            ,cast(am_focused_on_delivering_better_outcomes__c as float) as am_focused_on_delivering_better_outcomes_c
            ,send_lead_interest__c as send_lead_interest_c
            ,related_opportunity__c as related_opportunity_c
            ,workspace_id__c as workspace_id_c
            ,survey_gateway__c as survey_gateway_c
            ,cast(survey_gateway_id__c as float) as survey_gateway_id_c
            ,cast(digital_audit__c as float) as digital_audit_c
            ,to_timestamp_tz(checkpoint_date__c ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as checkpoint_date_c
            ,checkpoint_set__c as checkpoint_set_c
            ,cast(international_money_transfers__c as float) as international_money_transfers_c
            ,cast(invitation_to_webinars_and_events__c as float) as invitation_to_webinars_and_events_c
            ,contact_satisfaction__c as contact_satisfaction_c
            ,type_of_contact__c as type_of_contact_c
            ,cast(am_dissatisfied_bottom_2__c as float) as am_dissatisfied_bottom_2_c
            ,cast(am_neutral__c as float) as am_neutral_c
            ,cast(am_satisfied_top_2__c as float) as am_satisfied_top_2_c
            ,to_timestamp_tz(begintime__c ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as begin_time_c
            ,to_timestamp_tz(lastmodtime__c ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_mod_time_c
            ,cast(lastreesponsescheduledflowcheck__c as boolean) as last_reesponse_scheduled_flow_check_c
            ,status__c as status_c
            ,survey_response_payload__c as survey_response_payload_c
            ,cast(information_on_demographics__c as float) as information_on_demographics_c
            ,related_account__c as related_account_c
            ,cast(create_case__c as boolean) as create_case_c
            ,am_proactive__c as am_proactive_c
            ,cast(am_satisfaction__c as float) as am_satisfaction_c
            ,cast(pexa_exchange_fee_is_value__c as float) as pexa_exchange_fee_is_value_c
            ,what_could_pexa_do_better__c as what_could_pexa_do_better_c
            ,why_do_you_feel_this_way__c as why_do_you_feel_this_way_c
            ,survey_owner_name_formula__c as survey_owner_name_formula_c
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