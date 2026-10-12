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
    ,	is_deleted
    ,	name
    ,	created_date
    ,	created_by_id
    ,	last_modified_date
    ,	last_modified_by_id
    ,	system_modstamp
    ,	last_viewed_date
    ,	last_referenced_date
    ,	ps_subscription_c
    ,	ps_product_service_name_c
    ,	ps_ragicon_c
    ,	ps_rag_status_c
    ,	ps_status_c
    ,	account_c
    ,	do_not_talk_to_me_about_this_product_c
    ,	product_notes_c
    ,	reason_c
    ,	date_registered_c
    ,	product_registration_id_c
    ,	all_other_volume_immot_last_fy_c
    ,	all_other_volume_im_mot_current_fy_c
    ,	all_other_volume_im_mot_last_fy_minus_1_c
    ,	incoming_revenue_current_fy_c
    ,	incoming_revenue_last_fy_minus_1_c
    ,	incoming_revenue_last_fy_c
    ,	institution_revenue_current_fy_c
    ,	institution_revenue_last_fy_minus_1_c
    ,	institution_revenue_last_fy_c
    ,	outgoing_revenue_current_fy_c
    ,	outgoing_revenue_last_fy_minus_1_c
    ,	outgoing_revenue_last_fy_c
    ,	refinance_volume_immot_last_fy_c
    ,	refinance_volume_im_mot_current_fy_c
    ,	refinance_volume_im_mot_last_fy_minus_1_c
    ,	standalones_volume_immot_last_fy_c
    ,	standalones_volume_im_mot_current_fy_c
    ,	standalones_volume_im_mot_last_fy_minus_1_c
    ,	total_transaction_volume_current_fy_c
    ,	total_transaction_volume_last_fy_minus_1_c
    ,	total_transaction_volume_last_fy_c
    ,	transfer_volume_immot_last_fy_c
    ,	transfer_volume_im_mot_current_fy_c
    ,	transfer_volume_im_mot_last_fy_minus_1_c
    ,	external_id_c
    ,	total_workspace_revenue_current_fy_c
    ,	last_transaction_date_c
    ,	first_transaction_date_c
    ,	subscriber_id_c
    ,	all_other_volume_im_current_fy_c
    ,	all_other_volume_im_last_fy_c
    ,	all_other_volume_im_last_fy_minus_1_c
    ,	all_other_volume_mot_current_fy_c
    ,	all_other_volume_mot_last_fy_1_c
    ,	all_other_volume_mot_last_fy_c
    ,	refinance_volume_im_current_fy_c
    ,	refinance_volume_im_last_fy_minus_1_c
    ,	refinance_volume_im_last_fy_c
    ,	refinance_volume_mot_current_fy_c
    ,	refinance_volume_mot_last_fy_1_c
    ,	refinance_volume_mot_last_fy_c
    ,	standalones_volume_im_current_fy_c
    ,	standalones_volume_im_last_fy_minus_1_c
    ,	standalones_volume_im_last_fy_c
    ,	standalones_volume_mot_current_fy_c
    ,	standalones_volume_mot_last_fy_1_c
    ,	standalones_volume_mot_last_fy_c
    ,	total_exchange_reveneu_pfy_c
    ,	total_exchange_revenue_current_fy_c
    ,	total_non_exchange_revenue_cfy_c
    ,	total_non_exchange_revenue_pfy_c
    ,	total_non_exchange_volume_c
    ,	total_non_exchange_c
    ,	total_revenu_pfy_c
    ,	total_revenue_c
    ,	total_volume_pfy_c
    ,	total_volume_c
    ,	transfer_volume_im_current_fy_c
    ,	transfer_volume_im_last_fy_minus_1_c
    ,	transfer_volume_im_last_fy_c
    ,	transfer_volume_mot_current_fy_c
    ,	transfer_volume_mot_last_fy_1_c
    ,	transfer_volume_mot_last_fy_c
    ,	foreign_properties_all_time_c
    ,	pexa_commission_c
    ,	registration_am_c
    ,	send_registration_opt_in_c
    ,	settled_turnover_c
    ,	total_volume_buyer_cfy_c
    ,	total_volume_seller_cfy_c
    ,	total_transaction_volume_currentfy_c
    ,	total_workspace_revenue_currentfy_c
    ,	transfer_volume_im_mot_currentfy_c
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_ps_productservicestatus' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
