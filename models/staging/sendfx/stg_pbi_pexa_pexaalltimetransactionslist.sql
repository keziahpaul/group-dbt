{{ config(
    materialized='incremental',
    incremental_strategy='append'
) }}
{% set source_name= source('sendfx_raw', 'vw_ext_pbi_pexa_pexaalltimetransactionslist') %}
SELECT
    metadata_filename,
    ABN_ACN,
    Affiliate_Branch,
    Affiliate_Employee,
    BENEFICIARY_BANK_ACCOUNT_COUNTRY,
    Business_Name,
    TRIM(Buy_currency) AS Buy_currency,
    to_date(Completed_date_settlement_date,'YYYY-MM-DD HH24:MI:SS.FF7') as Completed_date_settlement_date,
    Conversion_id,
    to_date(Day_of_Lead_Created_Date_AEST,'YYYY-MM-DD HH24:MI:SS.FF7') as Day_of_Lead_Created_Date_AEST,
    to_date(Day_of_Registration_Date_AEST,'YYYY-MM-DD HH24:MI:SS.FF7') as Day_of_Registration_Date_AEST,
    Domain_Email_Address,
    Full_Name,
    Master_Registration_ID,
    cast(Pexa_commission as float) as Pexa_commission,
    Purpose,
    Registration_Account_Manager,
    Registration_Created_Source,
    Registration_ID,
    trim(Sell_currency) as Sell_currency,
    cast(Settled_revenue as float) as Settled_revenue,
    cast(Settled_turnover as float) as Settled_turnover,
    State,
    to_timestamp(ETL_INSERT_DATE_UTC,'YYYY-MM-DD HH24:MI:SS.FF7') as ETL_INSERT_DATE_UTC,
    CONVERT_TIMEZONE('Australia/Sydney', to_timestamp(ETL_INSERT_DATE_UTC,'YYYY-MM-DD HH24:MI:SS.FF7')) AS ETL_INSERT_DATE_AEST,
    {{ var('inserted_at') }} AS inserted_at
FROM {{ source('sendfx_raw', 'vw_ext_pbi_pexa_pexaalltimetransactionslist') }}
{% if is_incremental() %}
    where metadata_filename in {{ daily_refresh_stage(this,source_name) }}
{% endif %}
