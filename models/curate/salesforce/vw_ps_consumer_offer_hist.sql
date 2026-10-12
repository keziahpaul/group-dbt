with 

source as ( 

    select * from {{ ref('ps_consumeroffer') }}

)

    select
        id,
        is_deleted,
        name,
        created_date,
        created_by_id,
        last_modified_date,
        last_modified_by_id,
        system_modstamp,
        ps_offer_c,
        ps_consumer_c,
        offer_status_c,
        effective_from,
        effective_to,
        inserted_at,
        updated_at  

    from source
    