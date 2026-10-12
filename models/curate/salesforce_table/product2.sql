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
    ,	name
    ,	product_code
    ,	description
    ,	is_active
    ,	created_date
    ,	created_by_id
    ,	last_modified_date
    ,	last_modified_by_id
    ,	system_modstamp
    ,	family
    ,	external_data_source_id
    ,	external_id
    ,	display_url
    ,	quantity_unit_of_measure
    ,	is_deleted
    ,	is_archived
    ,	last_viewed_date
    ,	last_referenced_date
    ,	stock_keeping_unit	
    ,   CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
    ,   row_num
    ,   deleted_at
    ,   inserted_at
from {{ ref('stg_product2' ) }} 
where ((is_deleted != True) or (is_deleted = True and row_num=1))
  and {{ is_newer('inserted_at', 'src_delta_extract_ts') }}
