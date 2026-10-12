{% set source_stage ="'@' ~ env_var('DBT_GROUP_RAW_DB') ~ '.' ~ env_var('DBT_KAPICHE_SCHEMA') ~ '.' ~ env_var('DBT_KAPICHE_STAGE')" %}
{% set target_stage ="'@' ~ env_var('DBT_GROUP_RAW_DB') ~ '.' ~ env_var('DBT_KAPICHE_SCHEMA') ~ '.' ~ env_var('DBT_KAPICHE_S3_ARCHIVE_STAGE')" %}

{{
  config(
    materialized = 'from_external_stage',
    stage_name = env_var('DBT_GROUP_RAW_DB') + "." + env_var('DBT_KAPICHE_SCHEMA') + "." + env_var('DBT_KAPICHE_STAGE') + "/" + env_var('DBT_KAPICHE_FILE_LOCATION'),
    stage_file_format = env_var('DBT_GROUP_RAW_DB') + "." + env_var('DBT_KAPICHE_SCHEMA') + ".CSV_FILE_FORMAT",
    schema_name = env_var('DBT_KAPICHE_SCHEMA'),
    post_hook="{{copy_from_src_to_target(" ~ source_stage ~ "," ~ target_stage ~ ")}}"
  )
}}

select     
    $1::VARCHAR(16777216) as "_airbyte_raw_id",
    $2::VARCHAR(16777216) as "_airbyte_extracted_at",
    $3::VARCHAR(16777216) as "_airbyte_meta",
    $4::VARCHAR(16777216) as "_airbyte_generate_id",
    $5::VARCHAR(16777216) as "Account Managenment Segment",
    $6::VARCHAR(16777216) as "Account Owner",
    $7::VARCHAR(16777216) as "CSAT Comment",
    $8::VARCHAR(16777216) as "CSAT Rating",
    $9::VARCHAR(16777216) as "Creationdate",
    $10::VARCHAR(16777216) as "Customer Segment",
    $11::VARCHAR(16777216) as "Customer Type",
    $12::VARCHAR(16777216) as "Sentiment:CSAT Comment",
    $13::VARCHAR(16777216) as "Subscriber ID",
    $14::VARCHAR(16777216) as "Subscriber Name",
    $15::VARCHAR(16777216) as "Subscriber State",
    $16::VARCHAR(16777216) as "Theme__",
    $17::VARCHAR(16777216) as "document_id__"
FROM {{ pexa_one_data_au_dbt_common_lib.external_stage() }} 
