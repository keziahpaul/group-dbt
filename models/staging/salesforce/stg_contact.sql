
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_contact') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
            id as id
            ,cast(isdeleted as boolean) as is_deleted
            ,masterrecordid as master_record_id
            ,accountid as account_id
            ,cast(ispersonaccount as boolean) as is_person_account
            ,lastname as last_name
            ,firstname as first_name
            ,salutation as salutation
            ,middlename as middle_name
            ,suffix as suffix
            ,name as name
            ,otherstreet as other_street
            ,othercity as other_city
            ,otherstate as other_state
            ,otherpostalcode as other_postal_code
            ,othercountry as other_country
            ,otherstatecode as other_state_code
            ,othercountrycode as other_country_code
            ,cast(otherlatitude as float) as other_latitude
            ,cast(otherlongitude as float) as other_longitude
            ,othergeocodeaccuracy as other_geocode_accuracy
            ,otheraddress as other_address
            ,mailingstreet as mailing_street
            ,mailingcity as mailing_city
            ,mailingstate as mailing_state
            ,mailingpostalcode as mailing_postal_code
            ,mailingcountry as mailing_country
            ,mailingstatecode as mailing_state_code
            ,mailingcountrycode as mailing_country_code
            ,cast(mailinglatitude as float) as mailing_latitude
            ,cast(mailinglongitude as float) as mailing_longitude
            ,mailinggeocodeaccuracy as mailing_geocode_accuracy
            ,mailingaddress as mailing_address
            ,phone as phone
            ,fax as fax
            ,mobilephone as mobile_phone
            ,homephone as home_phone
            ,otherphone as other_phone
            ,assistantphone as assistant_phone
            ,reportstoid as reports_to_id
            ,email as email
            ,title as title
            ,department as department
            ,assistantname as assistant_name
            ,leadsource as lead_source
            ,to_date(birthdate ,'YYYY-MM-DD') as birthdate
            ,description as description
            ,ownerid as owner_id
            ,cast(hasoptedoutofemail as boolean) as has_opted_out_of_email
            ,cast(hasoptedoutoffax as boolean) as has_opted_out_of_fax
            ,cast(donotcall as boolean) as do_not_call
            ,to_timestamp_tz(createddate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            ,createdbyid as created_by_id
            ,to_timestamp_tz(lastmodifieddate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            ,lastmodifiedbyid as last_modified_by_id
            ,to_timestamp_tz(systemmodstamp ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            ,to_date(lastactivitydate ,'YYYY-MM-DD') as last_activity_date
            ,to_timestamp_tz(lastcurequestdate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_curequest_date
            ,to_timestamp_tz(lastcuupdatedate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_cuupdate_date
            ,to_timestamp_tz(lastvieweddate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            ,to_timestamp_tz(lastreferenceddate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            ,emailbouncedreason as email_bounced_reason
            ,to_timestamp_tz(emailbounceddate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as email_bounced_date
            ,cast(isemailbounced as boolean) as is_email_bounced
            ,photourl as photo_url
            ,jigsaw as jigsaw
            ,jigsawcontactid as jigsaw_contact_id
            ,pronouns as pronouns
            ,genderidentity as gender_identity
            ,ps_alcoholicpreferences__c as ps_alcoholic_preferences_c
            ,ps_bio__c as ps_bio_c
            ,ps_businessphonewashresults__c as ps_business_phone_wash_results_c
            ,ps_communicationtype__c as ps_communication_type_c
            ,to_date(ps_dateofvoi__c ,'YYYY-MM-DD') as ps_dateof_voi_c
            ,ps_reoccuringmeetings__c as ps_reoccuring_meetings_c
            ,ps_directreports__c as ps_direct_reports_c
            ,ps_linkedin__c as ps_linked_in_c
            ,ps_surveyparticipation__c as ps_survey_participation_c
            ,ps_mobilephonewashresults__c as ps_mobile_phone_wash_results_c
            ,ps_nonalcoholicpreferences__c as ps_non_alcoholic_preferences_c
            ,ps_outagenotifications__c as ps_outage_notifications_c
            ,to_date(ps_pexacertifieddate__c ,'YYYY-MM-DD') as ps_pexacertified_date_c
            ,ps_pexacertifiedstatus__c as ps_pexacertified_status_c
            ,ps_phonenumberslaswashedresults__c as ps_phone_numbers_las_washed_results_c
            ,ps_reportingmanager__c as ps_reporting_manager_c
            ,cast(ps_sameasentityaddress__c as boolean) as ps_same_as_entity_address_c
            ,ps_secondaryemail__c as ps_secondary_email_c
            ,ps_voicomplete__c as ps_voicomplete_c
            ,ps_voiprovider__c as ps_voiprovider_c
            ,ps_whattheylike__c as ps_what_they_like_c
            ,ps_contactmodule__c as ps_contact_module_c
            ,ps_externalid__c as ps_external_id_c
            ,ps_events__c as ps_events_c
            ,ps_dietaryrequirements__c as ps_dietary_requirements_c
            ,ps_method__c as ps_method_c
            ,ps_pexadivision__c as ps_pexadivision_c
            ,ps_relationshipstatus__c as ps_relationship_status_c
            ,ps_business_unit_area__c as ps_business_unit_area_c
            ,preferred_name__c as preferred_name_c
            ,sf18_contact_id__c as sf18_contact_id_c
            ,disc_profile__c as disc_profile_c
            ,communication_notifications__c as communication_notifications_c
            ,pexa_client_gift__c as pexa_client_gift_c
            ,ps_consumerid__c as ps_consumer_id_c
            ,to_timestamp_tz(ps_emailsubscriptionupdated__c ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_email_subscription_updated_c
            ,cast(ps_offeroptout__c as boolean) as ps_offer_opt_out_c
            ,to_timestamp_tz(ps_offersubscriptionupdated__c ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_offer_subscription_updated_c
            ,ps_organisation__c as ps_organisation_c
            ,to_timestamp_tz(ps_registrationdate__c ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_registration_date_c
            ,ps_registrationstatus__c as ps_registration_status_c
            ,cast(ps_smsoptout__c as boolean) as ps_smsopt_out_c
            ,to_timestamp_tz(ps_smssubscriptionupdated__c ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_smssubscription_updated_c
            ,to_timestamp_tz(ps_termsaccepteddate__c ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_terms_accepted_date_c
            ,ps_termsconditionsversion__c as ps_terms_conditions_version_c
            ,contact_data_score__c as contact_data_score_c
            ,contact_quality__c as contact_quality_c
            ,contacts_status__c as contacts_status_c
            ,secret_question_1_answer__c as secret_question_1_answer_c
            ,secret_question_1__c as secret_question_1_c
            ,secret_question_2_answer__c as secret_question_2_answer_c
            ,secret_question_2__c as secret_question_2_c
            ,contact_frequency__c as contact_frequency_c
            ,exchange_subscriber_id__c as exchange_subscriber_id_c
            ,to_date(date_last_survey_sent__c ,'YYYY-MM-DD') as date_last_survey_sent_c
            ,cast(primary_subscriber_manager__c as boolean) as primary_subscriber_manager_c
            ,to_timestamp_tz(exchange_last_login__c ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as exchange_last_login_c
            ,cast(contact_exchange_access__c as boolean) as contact_exchange_access_c
            ,subscriber_id__c as subscriber_id_c
            ,capacity_for_signing__c as capacity_for_signing_c
            ,role__c as role_c
            ,cast(survey_opt_out__c as boolean) as survey_opt_out_c
            ,cast(authorised_signatory__c as boolean) as authorised_signatory_c
            ,cast(finance_contact__c as boolean) as finance_contact_c
            ,pexa_payment_authorisers1__c as pexa_payment_authorisers_1_c
            ,cast(pexa_payment_authorisers__c as boolean) as pexa_payment_authorisers_c
            ,cast(primary_signatory__c as boolean) as primary_signatory_c
            ,cast(public_contact__c as boolean) as public_contact_c
            ,cast(requires_additional_digital_certificate__c as boolean) as requires_additional_digital_certificate_c
            ,cast(subscriber_manager__c as boolean) as subscriber_manager_c
            ,cast(trust_account_owners__c as boolean) as trust_account_owners_c
            ,subscriber_role__c as subscriber_role_c
            ,access_to_help_centre__c as access_to_help_centre_c
            ,account_category__c as account_category_c
            ,would_you_like_contact_from_the_gm__c as would_you_like_contact_from_the_gm_c
            ,opt_in_for_future_research__c as opt_in_for_future_research_c
            ,cast(ceo_c_levels_comms_ceo_or_execs_only__c as boolean) as ceo_c_levels_comms_ceo_or_execs_only_c
            ,cast(cyber_contacts__c as boolean) as cyber_contacts_c
            ,cast(event_and_webinar_inivites__c as boolean) as event_and_webinar_inivites_c
            ,cast(external_bridge_call_eimc__c as boolean) as external_bridge_call_eimc_c
            ,cast(incident_reporting_sev_1__c as boolean) as incident_reporting_sev_1_c
            ,cast(incident_reporting_sev_2_sev_3__c as boolean) as incident_reporting_sev_2_sev_3_c
            ,cast(pdg_report__c as boolean) as pdg_report_c
            ,cast(pricing_updates__c as boolean) as pricing_updates_c
            ,cast(primary_key_contact__c as boolean) as primary_key_contact_c
            ,cast(product_updates__c as boolean) as product_updates_c
            ,cast(senior_management_comms_i_e_dan_o_neil__c as boolean) as senior_management_comms_i_e_dan_o_neil_c
            ,cast(senior_management_incident_c_levels__c as boolean) as senior_management_incident_c_levels_c
            ,cast(exchange_user_last_login_count_c__c as float) as exchange_user_last_login_count_c_c
            ,division__c as division_c
            ,marketoid__c as marketo_id_c
            ,nationality__c as nationality_c
            -- , individualid as individual_id. -- NOT readable from salesforce
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