with source as (
    select *
    from {{ ref('stg_ledger') }}
)

select
    id,
    sink_created_on,
    sink_modified_on,
    is_budget_control_enabled,
    sys_data_state_code,
    accounting_currency,
    budget_exchange_rate_type,
    chart_of_accounts,
    default_exchange_rate_type,
    description,
    fiscal_calendar,
    name,
    primary_for_legal_entity,
    reporting_currency,
    reporting_currency_exchange_rate_type,
    most_recent_year_end_close,
    modified_date_time,
    modified_by,
    modified_transaction_id,
    created_date_time,
    created_by,
    created_transaction_id,
    data_area_id,
    recversion,
    partition,
    sysrowversion,
    rec_id,
    table_id,
    version_number,
    created_on,
    modified_on,
    is_delete,
    inserted_at,
    inserted_at as effective_to
from source
