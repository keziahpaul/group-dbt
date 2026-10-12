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
    ,	account_c
    ,	contact_c
    ,	email_for_symantec_digital_certificate_c
    ,	obtain_digital_certificate_c
    ,	symantec_digital_certificate_c
    ,	related_application_c
    ,	requires_a_new_digital_certificate_c
    ,	symantec_digital_certificate_suitable_fo_c
    ,	requires_additional_digital_certificate_c
    ,	authorisor_email_c
    ,	authorisor_name_c
    ,	certificate_expiry_date_c
    ,	certificate_holder_type_c
    ,	certificate_status_c
    ,	certificate_type_c
    ,	city_c
    ,	date_form_received_c
    ,	date_ordered_c
    ,	date_requested_c
    ,	date_terminated_c
    ,	express_post_tracking_number_c
    ,	express_post_c
    ,	order_status_c
    ,	postcode_c
    ,	previous_digital_certificate_c
    ,	primary_certificate_c
    ,	re_ordered_c
    ,	reason_for_fee_waiver_c
    ,	reason_for_termination_c
    ,	state_c
    ,	street_1_c
    ,	street_2_c
    ,	street_3_c
    ,	subscriber_id_c
    ,	verizon_apply_charge_c
    ,	verizon_certificate_required_c
    ,	verizon_portal_status_c
    ,	email_for_symantec_digital_ceriticate_c
    ,	comments_c
    ,	legacy_id_c
    ,	pexa_symantec_c
    ,	email_for_digital_certificate_c_c
    ,	email_for_digital_certificate_c
    ,	sf18digitdigicert_c
    ,   CERTIFICATE_PROVIDER_C
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_digital_certificate' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
