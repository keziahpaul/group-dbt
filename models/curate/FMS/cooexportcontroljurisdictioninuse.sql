with source as (
    select *
    from {{ ref('stg_cooexportcontroljurisdictioninuse') }}
)

select
    id,
    sink_created_on,
    sink_modified_on,
    is_active,
    skip_sales_order_check,
    skip_sales_quotation_check,
    sys_data_state_code,
    jurisdiction,
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
