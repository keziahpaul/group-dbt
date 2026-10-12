
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_opportunity') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
            id as id
            , CAST(isdeleted as BOOLEAN) as is_deleted
            , accountid as account_id
            , recordtypeid as record_type_id
            , CAST(isprivate as BOOLEAN) as is_private
            , name as name
            , description as description
            , stagename as stage_name
            , CAST(amount as NUMBER) as amount
            , CAST(probability as FLOAT) as probability
            , CAST(expectedrevenue as NUMBER) as expected_revenue
            , CAST(totalopportunityquantity as FLOAT) as total_opportunity_quantity
            , to_date(closedate, 'YYYY-MM-DD') as close_date
            , type as type
            , nextstep as next_step
            , leadsource as lead_source
            , CAST(isclosed as BOOLEAN) as is_closed
            , CAST(iswon as BOOLEAN) as is_won
            , forecastcategory as forecast_category
            , forecastcategoryname as forecast_category_name
            , campaignid as campaign_id
            , CAST(hasopportunitylineitem as BOOLEAN) as has_opportunity_line_item
            , ownerid as owner_id
            , to_timestamp_tz(createddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            , createdbyid as created_by_id
            , to_timestamp_tz(lastmodifieddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            , lastmodifiedbyid as last_modified_by_id
            , to_timestamp_tz(systemmodstamp, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            , to_date(lastactivitydate, 'YYYY-MM-DD') as last_activity_date
            , CAST(pushcount as NUMBER) as push_count
            , to_timestamp_tz(laststagechangedate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_stage_change_date
            , CAST(fiscalquarter as NUMBER) as fiscal_quarter
            , CAST(fiscalyear as NUMBER) as fiscal_year
            , fiscal as fiscal
            , contactid as contact_id
            , to_timestamp_tz(lastvieweddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_viewed_date
            , to_timestamp_tz(lastreferenceddate, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_referenced_date
            , CAST(hasopenactivity as BOOLEAN) as has_open_activity
            , CAST(hasoverduetask as BOOLEAN) as has_overdue_task
            , lastamountchangedhistoryid as last_amount_changed_history_id
            , lastclosedatechangedhistoryid as last_close_date_changed_history_id
            , CAST(budget_confirmed__c as BOOLEAN) as budget_confirmed_c
            , CAST(discovery_completed__c as BOOLEAN) as discovery_completed_c
            , CAST(roi_analysis_completed__c as BOOLEAN) as roi_analysis_completed_c
            , ps_acln__c as ps_acln_c
            , loss_reason__c as loss_reason_c
            , CAST(ps_demonstrationcompleted__c as BOOLEAN) as ps_demonstration_completed_c
            , to_date(ps_expirylapsingdate__c, 'YYYY-MM-DD') as ps_expiry_lapsing_date_c
            , CAST(ps_leadvalueifknown__c as NUMBER) as ps_lead_valueifknown_c
            , ps_lossreason__c as ps_loss_reason_c
            , CAST(ps_mouissued__c as BOOLEAN) as ps_mouissued_c
            , CAST(ps_moureturned__c as BOOLEAN) as ps_moureturned_c
            , CAST(ps_mousigned__c as BOOLEAN) as ps_mousigned_c
            , ps_nonadi__c as ps_non_adi_c
            , ps_onboardingid__c as ps_onboarding_id_c
            , ps_operatingmodelpreference__c as ps_operating_model_preference_c
            , ps_opportunityrecordtypename__c as ps_opportunity_record_type_name_c
            , ps_otherreason__c as ps_other_reason_c
            , CAST(ps_sharedsalescollateral__c as BOOLEAN) as ps_shared_sales_collateral_c
            , ps_subscriber_id__c as ps_subscriber_id_c
            , ps_subscriptionname__c as ps_subscription_name_c
            , primary_contact__c as primary_contact_c
            , win_reason__c as win_reason_c
            , salesperformanceopportunity__c as sales_performance_opportunity_c
            , product_name__c as product_name_c
            , account_tier__c as account_tier_c
            , new_owner__c as new_owner_c
            , to_date(new_properties__c, 'YYYY-MM-DD') as new_properties_c
            , properties__c as properties_c
            , workspace_id__c as workspace_id_c 
            --  , CONTRACTID as CONTRACT_ID.  -- not readable from salesforce
            --  , SYNCEDQUOTEID as SYNCED_QUOTE_ID  -- not readable from salesforce
            --  , PRICEBOOK2ID as PRICEBOOK_2_ID -- not readable from salesforce
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