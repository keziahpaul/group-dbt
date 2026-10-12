with source as (
    select *
    from {{ ref('stg_dimensionfocusbalance') }}
)

select
    id,
    sink_created_on,
    sink_modified_on,
    fiscal_calendar_period_type,
    is_system_generated_ultimo,
    posting_layer,
    sys_data_state_code,
    accounting_date,
    credit_accounting_currency_amount,
    credit_reporting_currency_amount,
    debit_accounting_currency_amount,
    debit_reporting_currency_amount,
    focus_dimension_hierarchy,
    focus_ledger_dimension,
    ledger,
    quantity,
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
