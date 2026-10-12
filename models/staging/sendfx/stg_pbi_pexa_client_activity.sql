{{ config(
    materialized='incremental',
    incremental_strategy='append',
    on_schema_change='append_new_columns'
) }}
{% set source_name= source('sendfx_raw', 'vw_ext_pbi_pexa_client_activity') %}

SELECT
    metadata_filename,
    abn_acn,
    affiliate_branch,
    affiliate_employee,
    business_name,
    domain_email_address,
    full_name,
    master_registration_id,
    purpose,
    registration_account_manager,
    registration_account_manager_email,
    registration_created_source,
    registration_id,
    state,
    TO_DATE(day_of_lead_created_date_aest, 'YYYY-MM-DD HH24:MI:SS.FF7') AS day_of_lead_created_date_aest,
    TO_DATE(day_of_registration_date_aest, 'YYYY-MM-DD HH24:MI:SS.FF7') AS day_of_registration_date_aest,
    TO_DATE(max_trade_settled_for_accounting_date, 'YYYY-MM-DD HH24:MI:SS.FF7') AS max_trade_settled_for_accounting_date,
    TO_DATE(min_trade_settled_for_accounting_date, 'YYYY-MM-DD HH24:MI:SS.FF7') AS min_trade_settled_for_accounting_date,
    TO_BOOLEAN(NULLIF(TRIM(registrations_pexa_opt_in_flag), '')) AS registrations_pexa_opt_in_flag,
    TO_TIMESTAMP(registrations_pexa_opt_in_date_aest, 'YYYY-MM-DD HH24:MI:SS.FF7') AS registrations_pexa_opt_in_date_aest,
    TO_TIMESTAMP(etl_insert_date_utc, 'YYYY-MM-DD HH24:MI:SS.FF7') AS etl_insert_date_utc,
    CONVERT_TIMEZONE('Australia/Sydney', TO_TIMESTAMP(etl_insert_date_utc, 'YYYY-MM-DD HH24:MI:SS.FF7')) AS etl_insert_date_aest,
    {{ var('inserted_at') }} AS inserted_at
FROM {{ source('sendfx_raw', 'vw_ext_pbi_pexa_client_activity') }}
{% if is_incremental() %}
    where metadata_filename in {{ daily_refresh_stage(this,source_name) }}
{% endif %}
