{{ config(
    materialized='scd_materialization',
    incremental_strategy='scd2_transformation',
    primary_key = ['Registration_ID', 'Master_Registration_ID'],
    scd2_ignore_columns = ['ETL_INSERT_DATE_UTC'],
    source_delta_column = "inserted_at",
    source_scd_effective_column = "ETL_INSERT_DATE_AEST",
    target_delta_column = "src_delta_extract_ts",
    handle_deletes=true
) }}
select
    ABN_ACN,
    AFFILIATE_BRANCH,
    AFFILIATE_EMPLOYEE,
    BUSINESS_NAME,
    DAY_OF_LEAD_CREATED_DATE_AEST,
    DAY_OF_REGISTRATION_DATE_AEST,
    DOMAIN_EMAIL_ADDRESS,
    FULL_NAME,
    MASTER_REGISTRATION_ID,
    PURPOSE,
    REGISTRATION_ACCOUNT_MANAGER,
    REGISTRATION_ACCOUNT_MANAGER_EMAIL,
    REGISTRATION_CREATED_SOURCE,
    REGISTRATION_ID,
    STATE,
    MAX_TRADE_SETTLED_FOR_ACCOUNTING_DATE,
    MIN_TRADE_SETTLED_FOR_ACCOUNTING_DATE,
    REGISTRATIONS_PEXA_OPT_IN_FLAG,
    REGISTRATIONS_PEXA_OPT_IN_DATE_AEST,
    ETL_INSERT_DATE_UTC,
    ETL_INSERT_DATE_AEST,
    INSERTED_AT
from {{ ref('stg_pbi_pexa_client_activity') }}
