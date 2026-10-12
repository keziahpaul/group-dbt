{{ config(
    materialized='incremental',
    incremental_strategy='append',
    on_schema_change='append_new_columns'
) }}
{% set source_name= source('sendfx_raw', 'vw_ext_pbi_pexa_client_incomplete_applications') %}

SELECT
        metadata_filename,
        Business_Name   ,
        Registrations_status  ,
        Boomerang_Reason_or_Docs_Required  ,
        Domain_Email_Address  ,
        Full_Name  ,
        Registration_Account_Manager  ,
        Registration_Account_Manager_Email  ,
        Master_Registration_ID,
        Registration_ID,
        to_date(Day_of_Lead_Created_Date_AEST,'YYYY-MM-DD HH24:MI:SS.FF7') as  Day_of_Lead_Created_Date_AEST ,
        to_timestamp(ETL_INSERT_DATE_UTC,'YYYY-MM-DD HH24:MI:SS.FF7') as ETL_INSERT_DATE_UTC,
        CONVERT_TIMEZONE('Australia/Sydney', to_timestamp(ETL_INSERT_DATE_UTC,'YYYY-MM-DD HH24:MI:SS.FF7')) AS ETL_INSERT_DATE_AEST,
    {{ var('inserted_at') }} AS inserted_at
FROM {{ source('sendfx_raw', 'vw_ext_pbi_pexa_client_incomplete_applications') }}
 {% if is_incremental() %}
    where metadata_filename in {{ daily_refresh_stage(this,source_name) }}
{% endif %}

