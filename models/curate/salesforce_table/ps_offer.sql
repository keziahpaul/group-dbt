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
    ,	ps_provider_c
    ,	ps_daysfrom_settlement_c
    ,	ps_expiry_date_c
    ,	ps_external_offer_id_c
    ,	ps_fulfillment_endpoint_c
    ,	ps_fulfillment_type_c
    ,	ps_handover_description_c
    ,	ps_handover_footer_c
    ,	ps_handover_header_c
    ,	ps_handover_image_c
    ,	ps_handover_logo_c
    ,	ps_handover_title_c
    ,	ps_jurisdiction_c
    ,	ps_offer_badge_c
    ,	ps_offer_logo_c
    ,	ps_postcode_c
    ,	ps_property_classification_c
    ,	ps_settlement_status_c
    ,	ps_start_date_c
    ,	ps_status_c
    ,	ps_user_role_c
    ,	ps_version_c
    ,	provider_name_c
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_ps_offer' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
