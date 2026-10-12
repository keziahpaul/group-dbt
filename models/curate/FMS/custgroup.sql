with source as (
    select *
    from {{ ref('stg_custgroup') }}
)

select
    id,
    sink_created_on,
    sink_modified_on,
    price_include_sales_tax,
    is_public_sector_it,
    sys_data_state_code,
    bank_cust_paymid_table,
    clearing_period,
    cust_group,
    default_dimension,
    name,
    paym_term_id,
    tax_group_id,
    tax_period_payment_code_pl,
    cust_write_off_ref_rec_id,
    cust_account_num_seq,
    accounting_currency_exchange_rate_type,
    reporting_currency_exchange_rate_type,
    modified_date_time,
    modified_by,
    modified_transaction_id,
    created_date_time,
    created_by,
    created_transaction_id,
    data_area_id,
    recversion,
    partition,
    sys_row_version,
    rec_id,
    table_id,
    version_number,
    created_on,
    modified_on,
    is_delete,
    inserted_at,
    inserted_at as effective_to
from source
