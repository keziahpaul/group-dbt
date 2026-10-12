{{ config (
    materialized='scd_materialization',
    incremental_strategy='scd2_transformation',
    primary_key=['id'],
    source_delta_column = "inserted_at",
    source_scd_effective_column = "system_modstamp_aest",
    scd2_ignore_columns =['row_num','deleted_at'],
    target_delta_column = "src_delta_extract_ts",
    handle_deletes=true, 
    src_delete_identifier ='is_deleted',
    deleted_at_identifier='deleted_at',
    src_timestamp_grain ='second',
    target_ignore_columns=["row_num","deleted_at"]
)  
}}

select
    id
    ,	owner_id
    ,	is_deleted
    ,	name
    ,	created_date
    ,	created_by_id
    ,	last_modified_date
    ,	last_modified_by_id
    ,	system_modstamp
    ,	last_viewed_date
    ,	last_referenced_date
    ,	am_comments_c
    ,	csat_c
    ,	cstat_am_c
    ,	customer_priorities_c
    ,	customer_support_verbatim_c
    ,	importance_currency_c
    ,	pexapositives_c
    ,	pexaimprovements_c
    ,	related_case_c
    ,	related_contact_c
    ,	survey_business_name_c
    ,	exchange_subscriber_id_c
    ,	exchange_survey_type_c
    ,	exchange_user_id_c
    ,	inmoment_response_id_c
    ,	journey_c
    ,	survey_id_c
    ,	personalised_experience_c
    ,	receive_value_by_using_pexa_c
    ,	pexa_exchange_value_c
    ,	service_experience_c
    ,	experience_expectations_c
    ,	plan_to_user_additional_products_c
    ,	am_shares_continious_learnings_c
    ,	pexa_source_account_c
    ,	finding_new_ways_to_obtain_clients_c
    ,	represent_a_property_developer_c
    ,	timely_insights_market_trends_c
    ,	insights_on_industyr_best_practice_c
    ,	access_to_online_training_materials_c
    ,	climate_and_environmental_data_c
    ,	api_productivity_interest_c
    ,	pexa_rep_in_your_state_c
    ,	growing_your_business_c
    ,	call_support_for_help_c
    ,	expanding_your_professional_network_c
    ,	continued_pd_c
    ,	am_interest_in_business_needs_c
    ,	am_responds_in_timely_manner_c
    ,	am_shares_relevant_insights_c
    ,	am_easy_to_deal_c
    ,	am_provides_solutions_c
    ,	am_focused_on_delivering_better_outcomes_c
    ,	send_lead_interest_c
    ,	related_opportunity_c
    ,	workspace_id_c
    ,	survey_gateway_c
    ,	survey_gateway_id_c
    ,	digital_audit_c
    ,	checkpoint_date_c
    ,	checkpoint_set_c
    ,	international_money_transfers_c
    ,	invitation_to_webinars_and_events_c
    ,	contact_satisfaction_c
    ,	type_of_contact_c
    ,	am_dissatisfied_bottom_2_c
    ,	am_neutral_c
    ,	am_satisfied_top_2_c
    ,	begin_time_c
    ,	last_mod_time_c
    ,	last_reesponse_scheduled_flow_check_c
    ,	status_c
    ,	survey_response_payload_c
    ,	information_on_demographics_c
    ,	related_account_c
    ,	create_case_c
    ,	am_proactive_c
    ,	am_satisfaction_c
    ,	pexa_exchange_fee_is_value_c
    ,	what_could_pexa_do_better_c
    ,	why_do_you_feel_this_way_c
    ,	survey_owner_name_formula_c
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_all_survey_responses' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
