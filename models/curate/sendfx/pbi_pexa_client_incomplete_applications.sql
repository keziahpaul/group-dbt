{{ config(
    materialized='scd_materialization',
    incremental_strategy='scd2_transformation',
    primary_key = [ 'Registration_ID', 'Master_Registration_ID'],
    scd2_ignore_columns = ['ETL_INSERT_DATE_UTC'],
    source_delta_column = "inserted_at",
    source_scd_effective_column = "ETL_INSERT_DATE_AEST",
    target_delta_column = "src_delta_extract_ts",
    handle_deletes=true
)}}

SELECT
        Business_Name   ,
        Registrations_status  ,
        Boomerang_Reason_or_Docs_Required  ,
        Domain_Email_Address  ,
        Full_Name  ,
        Registration_Account_Manager  ,
        Registration_Account_Manager_Email  ,
        Master_Registration_ID,
        Registration_ID,
        Day_of_Lead_Created_Date_AEST  ,
        ETL_INSERT_DATE_UTC  ,
        ETL_INSERT_DATE_AEST,
        inserted_at
FROM {{ ref('stg_pbi_pexa_client_incomplete_applications') }}