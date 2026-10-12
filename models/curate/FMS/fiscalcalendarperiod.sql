with source as (
    select *
    from {{ ref('stg_fiscalcalendarperiod') }}
)

select
    id,
    sink_created_on,
    sink_modified_on,
    month,
    quarter,
    type,
    sys_data_state_code,
    description,
    end_date,
    fiscal_calendar,
    fiscal_calendar_year,
    name,
    short_name,
    start_date,
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
