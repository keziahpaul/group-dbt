with source as (
    select *
    from {{ ref('stg_dimensionhierarchy') }}
)

select
    id,
    sink_created_on,
    sink_modified_on,
    is_draft,
    is_system_generated,
    structure_type,
    focus_state,
    focus_is_automatic_update_sim_it,
    focus_state_sim_it,
    sys_data_state_code,
    delete_dversion,
    description,
    draft_description,
    draft_name,
    hashkey,
    name,
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
