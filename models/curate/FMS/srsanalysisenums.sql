with source as (
    select *
    from {{ ref('stg_srsanalysisenums') }}
)

select
    id,
    sink_created_on,
    sink_modified_on,
    enum_item_label,
    enum_item_name,
    enum_item_value,
    enum_name,
    language_id,
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
