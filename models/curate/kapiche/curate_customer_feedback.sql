{{ config(
    materialized='scd_materialization',
    incremental_strategy='scd2_transformation',
    primary_key = ['document_id'],
    source_delta_column = "inserted_at",
    source_scd_effective_column = "src_file_last_modified_date",
    target_delta_column = "src_delta_extract_ts"
) }}

with

source as (

    select * from {{ ref('customer_feedback') }}

)

select
    "_airbyte_raw_id" as airbyte_raw_id,
    "_airbyte_meta" as airbyte_meta,
    "_airbyte_generate_id" as airbyte_generate_id,
    nullif("Account Managenment Segment", '(No Value)') as account_managenment_segment,
    nullif("Account Owner", '(No Value)') as account_owner,
    "CSAT Comment" as csat_comment,
    "CSAT Rating" as csat_rating,
    nullif("Customer Segment", '(No Value)') as customer_segment,
    "Customer Type" as customer_type,
    "Sentiment:CSAT Comment" as sentiment_csat_comment,
    nullif("Subscriber Name", '(No Value)') as subscriber_name,
    nullif("Subscriber State", '(No Value)') as subscriber_state,
    CAST("document_id__" as NUMBER) as document_id,
    "Theme__" as theme,
    CAST("_airbyte_extracted_at" as NUMBER) as airbyte_extracted_at,
    CAST("Creationdate" as TIMESTAMP_NTZ(9)) as creation_date,
    TRY_CAST("Subscriber ID" as NUMBER) as subscriber_id,
    src_file_last_modified_date,
    {{ var("inserted_at") }} as inserted_at
from source
