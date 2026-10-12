
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_account') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
            Id as id
            ,CAST(IsDeleted AS BOOLEAN) as is_deleted
            ,MasterRecordId as master_record_id
            ,Name as name
            ,LastName as last_name
            ,FirstName as first_name
            ,Salutation as salutation
            ,MiddleName as middle_name
            ,Suffix as suffix
            ,Type as type
            ,RecordTypeId as record_type_id
            ,ParentId as parent_id
            ,BillingStreet as billing_street
            ,BillingCity as billing_city
            ,BillingState as billing_state
            ,BillingPostalCode as billing_postal_code
            ,BillingCountry as billing_country
            ,BillingStateCode as billing_state_code
            ,BillingCountryCode as billing_country_code
            ,CAST(BillingLatitude AS FLOAT) as billing_latitude
            ,CAST(BillingLongitude AS FLOAT) as billing_longitude
            ,BillingGeocodeAccuracy as billing_geocode_accuracy
            ,BillingAddress as billing_address
            ,ShippingStreet as shipping_street
            ,ShippingCity as shipping_city
            ,ShippingState as shipping_state
            ,ShippingPostalCode as shipping_postal_code
            ,ShippingCountry as shipping_country
            ,ShippingStateCode as shipping_state_code
            ,ShippingCountryCode as shipping_country_code
            ,CAST(ShippingLatitude AS FLOAT) as shipping_latitude
            ,CAST(ShippingLongitude AS FLOAT) as shipping_longitude
            ,ShippingGeocodeAccuracy as shipping_geocode_accuracy
            ,ShippingAddress as shipping_address
            ,Phone as phone
            ,Fax as fax
            ,AccountNumber as account_number
            ,Website as website
            ,PhotoUrl as photo_url
            ,Sic as sic
            ,Industry as industry
            ,CAST(AnnualRevenue AS NUMBER) as annual_revenue
            ,CAST(NumberOfEmployees AS NUMBER) as number_of_employees
            ,Ownership as ownership
            ,TickerSymbol as ticker_symbol
            ,Description as description
            ,Rating as rating
            ,Site as site
            ,OwnerId as owner_id
            ,to_timestamp_tz(CreatedDate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            ,CreatedById as created_by_id
            ,to_timestamp_tz(LastModifiedDate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            ,LastModifiedById as last_modified_by_id
            ,to_timestamp_tz(SystemModstamp ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            ,to_date(LastActivityDate ,'YYYY-MM-DD') as last_activity_date
            ,to_timestamp_tz(LastViewedDate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            ,to_timestamp_tz(LastReferencedDate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            ,SourceSystemIdentifier as source_system_identifier
            ,CAST(IsCustomerPortal AS BOOLEAN) as is_customer_portal
            ,PersonContactId as person_contact_id
            ,CAST(IsPersonAccount AS BOOLEAN) as is_person_account
            ,PersonMailingStreet as person_mailing_street
            ,PersonMailingCity as person_mailing_city
            ,PersonMailingState as person_mailing_state
            ,PersonMailingPostalCode as person_mailing_postal_code
            ,PersonMailingCountry as person_mailing_country
            ,PersonMailingStateCode as person_mailing_state_code
            ,PersonMailingCountryCode as person_mailing_country_code
            ,CAST(PersonMailingLatitude AS FLOAT) as person_mailing_latitude
            ,CAST(PersonMailingLongitude AS FLOAT) as person_mailing_longitude
            ,PersonMailingGeocodeAccuracy as person_mailing_geocode_accuracy
            ,PersonMailingAddress as person_mailing_address
            ,PersonOtherStreet as person_other_street
            ,PersonOtherCity as person_other_city
            ,PersonOtherState as person_other_state
            ,PersonOtherPostalCode as person_other_postal_code
            ,PersonOtherCountry as person_other_country
            ,PersonOtherStateCode as person_other_state_code
            ,PersonOtherCountryCode as person_other_country_code
            ,CAST(PersonOtherLatitude AS FLOAT) as person_other_latitude
            ,CAST(PersonOtherLongitude AS FLOAT) as person_other_longitude
            ,PersonOtherGeocodeAccuracy as person_other_geocode_accuracy
            ,PersonOtherAddress as person_other_address
            ,PersonMobilePhone as person_mobile_phone
            ,PersonHomePhone as person_home_phone
            ,PersonOtherPhone as person_other_phone
            ,PersonAssistantPhone as person_assistant_phone
            ,PersonEmail as person_email
            ,PersonTitle as person_title
            ,PersonDepartment as person_department
            ,PersonAssistantName as person_assistant_name
            ,PersonLeadSource as person_lead_source
            ,to_date(PersonBirthdate ,'YYYY-MM-DD') as person_birthdate
            ,CAST(PersonHasOptedOutOfEmail AS BOOLEAN) as person_has_opted_out_of_email
            ,CAST(PersonHasOptedOutOfFax AS BOOLEAN) as person_has_opted_out_of_fax
            ,CAST(PersonDoNotCall AS BOOLEAN) as person_do_not_call
            ,to_timestamp_tz(PersonLastCURequestDate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as person_last_curequest_date
            ,to_timestamp_tz(PersonLastCUUpdateDate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as person_last_cuupdate_date
            ,PersonEmailBouncedReason as person_email_bounced_reason
            ,to_timestamp_tz(PersonEmailBouncedDate ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as person_email_bounced_date
            ,PersonPronouns as person_pronouns
            ,PersonGenderIdentity as person_gender_identity
            ,Jigsaw as jigsaw
            ,JigsawCompanyId as jigsaw_company_id
            ,AccountSource as account_source
            ,SicDesc as sic_desc
            ,PS_ABN__c as ps_abn_c
            ,PS_ACN__c as ps_acn_c
            ,PS_ASXReferenceCode__c as ps_asxreference_code_c
            ,PS_AccountManagementSegment__c as ps_account_management_segment_c
            ,PS_AccountPlanQuipDocumentUrl__c as ps_account_plan_quip_document_url_c
            ,to_date(PS_ActivationDate__c ,'YYYY-MM-DD') as ps_activation_date_c
            ,PS_Information_Broker_Other__c as ps_information_broker_other_c
            ,PS_AwardsWon__c as ps_awards_won_c
            ,PS_BestPracticeGroups__c as ps_best_practice_groups_c
            ,PS_BusinessUnitName__c as ps_business_unit_name_c
            ,PS_Channel__c as ps_channel_c
            ,PS_Information_Broker__c as ps_information_broker_c
            ,PS_CustomerSegmentLevel0__c as ps_customer_segment_level_0_c
            ,SF18AccountID__c as sf18_account_id_c
            ,PEXA_Shareholder__c as pexa_shareholder_c
            ,Event_Participation__c as event_participation_c
            ,PS_Overall_Health_of_Account_Status__c as ps_overall_healthof_account_status_c
            ,PS_Engagement__c as ps_engagement_c
            ,PS_EntityType__c as ps_entity_type_c
            ,PS_ExternalDocumentsQuipDocumentUrl__c as ps_external_documents_quip_document_url_c
            ,PS_ExternalID__c as ps_external_id_c
            ,PS_FICategory__c as ps_ficategory_c
            ,PS_FinancialYear__c as ps_financial_year_c
            ,PS_FocusandStructureofBusiness__c as ps_focusand_structureof_business_c
            ,CAST(PS_IndustryMarketShare__c AS FLOAT) as ps_industry_market_share_c
            ,PS_IndustryPartnerTypeOther__c as ps_industry_partner_type_other_c
            ,PS_IndustryPartnerType__c as ps_industry_partner_type_c
            ,PS_InformationEvenings__c as ps_information_evenings_c
            ,PS_InstitutionType__c as ps_institution_type_c
            ,CAST(PS_IsAssignedAccountPlanQuipDocument__c AS BOOLEAN) as ps_is_assigned_account_plan_quip_document_c
            ,CAST(PS_IsAssignedExternalDocQuipDocument__c AS BOOLEAN) as ps_is_assigned_external_doc_quip_document_c
            ,PS_LegalEntityName__c as ps_legal_entity_name_c
            ,PS_Likelihood__c as ps_likelihood_c
            ,PS_Operational1__c as ps_operational_1_c
            ,PS_Operational2__c as ps_operational_2_c
            ,PS_Operational3__c as ps_operational_3_c
            ,PS_OtherIndicators__c as ps_other_indicators_c
            ,to_date(PS_PEXACertifiedDate__c ,'YYYY-MM-DD') as ps_pexacertified_date_c
            ,PS_PEXACertifiedStatus__c as ps_pexacertified_status_c
            ,CAST(PS_PEXAMarketShare__c AS FLOAT) as ps_pexamarket_share_c
            ,PS_PMSOther__c as ps_pmsother_c
            ,PS_PMS__c as ps_pms_c
            ,PS_PanelLawyer__c as ps_panel_lawyer_c
            ,CAST(PS_PeopleinvolvedinProperty__c AS FLOAT) as ps_peopleinvolvedin_property_c
            ,Contact_Frequency__c as contact_frequency_c
            ,PS_QuipFolderUrl__c as ps_quip_folder_url_c
            ,PS_RAGEngagement__c as ps_rag_engagement_c
            ,PS_RAGLikelihood__c as ps_rag_likelihood_c
            ,PS_RAGStatus__c as ps_rag_status_c
            ,CAST(PS_SizeofLoanBook__c AS FLOAT) as ps_sizeof_loan_book_c
            ,Industry_Engagement__c as industry_engagement_c
            ,Engagement_preference__c as engagement_preference_c
            ,Contract_Status__c as contract_status_c
            ,PS_Strategic1__c as ps_strategic_1_c
            ,PS_Strategic2__c as ps_strategic_2_c
            ,PS_Strategic3__c as ps_strategic_3_c
            ,PS_Symposiums__c as ps_symposiums_c
            ,to_timestamp_tz(PS_SystemBypassValidationDatetime__c ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_system_bypass_validation_datetime_c
            ,Behavioural_Segment__c as behavioural_segment_c
            ,PS_TrusteeofaTrust__c as ps_trusteeofa_trust_c
            ,CMT_Member__c as cmt_member_c
            ,Current_Contract_Rate__c as current_contract_rate_c
            ,PS_CustomerSegmentLevel1__c as ps_customer_segment_level_1_c
            ,PS_CustomerSegmentLevel2__c as ps_customer_segment_level_2_c
            ,PS_CustomerStatus__c as ps_customer_status_c
            ,PS_OverallHealthofAccount__c as ps_overall_healthof_account_c
            ,PS_Status__c as ps_status_c
            ,Remortgage_Volume_Estimate__c as remortgage_volume_estimate_c
            ,Sales_Purchase_Volume_Estimate__c as sales_purchase_volume_estimate_c
            ,Competitor__c as competitor_c
            ,Company_Number_UK__c as company_number_uk_c
            ,Panel_Details__c as panel_details_c
            ,How_will_the_company_execute_agreements__c as how_will_the_company_execute_agreements_c
            ,CAST(Send_FX_Rego__c AS BOOLEAN) as send_fx_rego_c
            ,Financial_Institution_Type__c as financial_institution_type_c
            ,How_many_property_transactions_per_month__c as how_many_property_transactions_per_month_c
            ,How_will_the_partnership_execute_the_ag__c as how_will_the_partnership_execute_the_ag_c
            ,Other_organisation_type__c as other_organisation_type_c
            ,Subscriber_Manager__c as subscriber_manager_c
            ,What_type_is_your_trustee__c as what_type_is_your_trustee_c
            ,subscription_id__c as subscription_id_c
            ,to_date(Last_SRP_Survey_Completed__c ,'YYYY-MM-DD') as last_srp_survey_completed_c
            ,to_date(Last_SRP_Survey_Invite__c ,'YYYY-MM-DD') as last_srp_survey_invite_c
            ,Account_Category__c as account_category_c
            ,Financial_Account_Used__c as financial_account_used_c
            ,CAST(Train_the_Trainer_Org__c AS BOOLEAN) as train_the_trainer_org_c
            ,Operational_Details__c as operational_details_c
            ,API_Roadmap_and_gaps__c as api_roadmap_and_gaps_c
            ,Associate__c as associate_c
            ,PA_NTPM__c as pa_ntpm_c
            ,CAST(Relationship_Manager_Budget_YTD__c AS FLOAT) as relationship_manager_budget_ytd_c
            ,CAST(Revenue_Target__c AS FLOAT) as revenue_target_c
            ,CAST(SOT__c AS FLOAT) as sot_c
            ,CAST(Tracker__c AS FLOAT) as tracker_c
            ,Tracker_for_Broker__c as tracker_for_broker_c
            ,PS_PrimarySourceofBusiness__c as ps_primary_sourceof_business_c
            ,PS_AlcoholicPreferences__pc as ps_alcoholic_preferences_pc
            ,PS_Bio__pc as ps_bio_pc
            ,PS_BusinessPhoneWashResults__pc as ps_business_phone_wash_results_pc
            ,PS_CommunicationType__pc as ps_communication_type_pc
            ,to_date(PS_DateofVOI__pc ,'YYYY-MM-DD') as ps_dateof_voi_pc
            ,PS_ReoccuringMeetings__pc as ps_reoccuring_meetings_pc
            ,PS_DirectReports__pc as ps_direct_reports_pc
            ,PS_LinkedIn__pc as ps_linked_in_pc
            ,PS_SurveyParticipation__pc as ps_survey_participation_pc
            ,PS_MobilePhoneWashResults__pc as ps_mobile_phone_wash_results_pc
            ,PS_NonAlcoholicPreferences__pc as ps_non_alcoholic_preferences_pc
            ,PS_OutageNotifications__pc as ps_outage_notifications_pc
            ,to_date(PS_PEXACertifiedDate__pc ,'YYYY-MM-DD') as ps_pexacertified_date_pc
            ,PS_PEXACertifiedStatus__pc as ps_pexacertified_status_pc
            ,PS_PhoneNumbersLasWashedResults__pc as ps_phone_numbers_las_washed_results_pc
            ,PS_ReportingManager__pc as ps_reporting_manager_pc
            ,CAST(PS_SameAsEntityAddress__pc AS BOOLEAN) as ps_same_as_entity_address_pc
            ,PS_SecondaryEmail__pc as ps_secondary_email_pc
            ,PS_VOIComplete__pc as ps_voicomplete_pc
            ,PS_VOIProvider__pc as ps_voiprovider_pc
            ,PS_WhatTheyLike__pc as ps_what_they_like_pc
            ,PS_ContactModule__pc as ps_contact_module_pc
            ,PS_ExternalID__pc as ps_external_id_pc
            ,PS_Events__pc as ps_events_pc
            ,PS_DietaryRequirements__pc as ps_dietary_requirements_pc
            ,PS_Method__pc as ps_method_pc
            ,PS_PEXADivision__pc as ps_pexadivision_pc
            ,PS_RelationshipStatus__pc as ps_relationship_status_pc
            ,PS_Business_Unit_Area__pc as ps_business_unit_area_pc
            ,Preferred_Name__pc as preferred_name_pc
            ,SF18_Contact_Id__pc as sf18_contact_id_pc
            ,DISC_Profile__pc as disc_profile_pc
            ,Communication_Notifications__pc as communication_notifications_pc
            ,PEXA_Client_Gift__pc as pexa_client_gift_pc
            ,PS_ConsumerId__pc as ps_consumer_id_pc
            ,to_timestamp_tz(PS_EmailSubscriptionUpdated__pc ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_email_subscription_updated_pc
            ,CAST(PS_OfferOptOut__pc AS BOOLEAN) as ps_offer_opt_out_pc
            ,to_timestamp_tz(PS_OfferSubscriptionUpdated__pc ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_offer_subscription_updated_pc
            ,PS_Organisation__pc as ps_organisation_pc
            ,to_timestamp_tz(PS_RegistrationDate__pc ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_registration_date_pc
            ,PS_RegistrationStatus__pc as ps_registration_status_pc
            ,CAST(PS_SMSOptOut__pc AS BOOLEAN) as ps_smsopt_out_pc
            ,to_timestamp_tz(PS_SMSSubscriptionUpdated__pc ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_smssubscription_updated_pc
            ,to_timestamp_tz(PS_TermsAcceptedDate__pc ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as ps_terms_accepted_date_pc
            ,PS_TermsConditionsVersion__pc as ps_terms_conditions_version_pc
            ,Contact_Data_Score__pc as contact_data_score_pc
            ,Contact_Quality__pc as contact_quality_pc
            ,Contacts_Status__pc as contacts_status_pc
            ,Secret_Question_1_Answer__pc as secret_question_1_answer_pc
            ,Secret_Question_1__pc as secret_question_1_pc
            ,Secret_Question_2_Answer__pc as secret_question_2_answer_pc
            ,Secret_Question_2__pc as secret_question_2_pc
            ,Contact_Frequency__pc as contact_frequency_pc
            ,Exchange_Subscriber_ID__pc as exchange_subscriber_id_pc
            ,to_date(Date_Last_Survey_Sent__pc ,'YYYY-MM-DD') as date_last_survey_sent_pc
            ,CAST(Primary_Subscriber_Manager__pc AS BOOLEAN) as primary_subscriber_manager_pc
            ,to_timestamp_tz(Exchange_Last_Login__pc ,'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as exchange_last_login_pc
            ,CAST(Contact_Exchange_Access__pc AS BOOLEAN) as contact_exchange_access_pc
            ,Subscriber_ID__pc as subscriber_id_pc
            ,Capacity_for_signing__pc as capacity_for_signing_pc
            ,Role__pc as role_pc
            ,CAST(Survey_Opt_Out__pc AS BOOLEAN) as survey_opt_out_pc
            ,CAST(Authorised_Signatory__pc AS BOOLEAN) as authorised_signatory_pc
            ,CAST(Finance_contact__pc AS BOOLEAN) as finance_contact_pc
            ,PEXA_Payment_Authorisers1__pc as pexa_payment_authorisers_1_pc
            ,CAST(PEXA_Payment_Authorisers__pc AS BOOLEAN) as pexa_payment_authorisers_pc
            ,CAST(Primary_Signatory__pc AS BOOLEAN) as primary_signatory_pc
            ,CAST(Public_contact__pc AS BOOLEAN) as public_contact_pc
            ,CAST(Requires_Additional_Digital_Certificate__pc AS BOOLEAN) as requires_additional_digital_certificate_pc
            ,CAST(Subscriber_Manager__pc AS BOOLEAN) as subscriber_manager_pc
            ,CAST(Trust_Account_Owners__pc AS BOOLEAN) as trust_account_owners_pc
            ,Subscriber_Role__pc as subscriber_role_pc
            ,Access_to_help_centre__pc as access_to_help_centre_pc
            ,Account_Category__pc as account_category_pc
            ,Would_you_like_contact_from_the_GM__pc as would_you_like_contact_from_the_gm_pc
            ,Opt_in_for_future_research__pc as opt_in_for_future_research_pc
            ,CAST(CEO_C_Levels_Comms_CEO_or_Execs_only__pc AS BOOLEAN) as ceo_c_levels_comms_ceo_or_execs_only_pc
            ,CAST(Cyber_Contacts__pc AS BOOLEAN) as cyber_contacts_pc
            ,CAST(Event_and_Webinar_Inivites__pc AS BOOLEAN) as event_and_webinar_inivites_pc
            ,CAST(External_Bridge_Call_EIMC__pc AS BOOLEAN) as external_bridge_call_eimc_pc
            ,CAST(Incident_Reporting_Sev_1__pc AS BOOLEAN) as incident_reporting_sev_1_pc
            ,CAST(Incident_Reporting_Sev_2_Sev_3__pc AS BOOLEAN) as incident_reporting_sev_2_sev_3_pc
            ,CAST(PDG_Report__pc AS BOOLEAN) as pdg_report_pc
            ,CAST(Pricing_Updates__pc AS BOOLEAN) as pricing_updates_pc
            ,CAST(Primary_Key_Contact__pc AS BOOLEAN) as primary_key_contact_pc
            ,CAST(Product_Updates__pc AS BOOLEAN) as product_updates_pc
            ,CAST(Senior_Management_Comms_i_e_Dan_O_Neil__pc AS BOOLEAN) as senior_management_comms_i_e_dan_o_neil_pc
            ,CAST(Senior_Management_Incident_C_levels__pc AS BOOLEAN) as senior_management_incident_c_levels_pc
            ,CAST(Exchange_User_Last_Login_Count_c__pc AS FLOAT) as exchange_user_last_login_count_c_pc
            ,Division__pc as division_pc
            ,MarketoID__pc as marketo_id_pc
            ,Acc_Owner_email_formula__c as Acc_Owner_email_formula_c
            ,Acc_Owner_name_formula__c as Acc_Owner_name_formula_c
            ,account_name_formula__c as account_name_formula_c
            ,email_domains_for_associated_domains__c as email_domains_for_associated_domains_c
            ,key_contact_name__c as key_contact_name_c
            ,nationality__pc as nationality_pc
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