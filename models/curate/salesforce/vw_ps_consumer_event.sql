with 

source as ( 

    select * from {{ ref('ps_consumerevent') }}

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
        ps_consumer_c,
        ps_consumer_offer_c,
        ps_event_type_c,
        ps_property_c,
        effective_from,
        effective_to,
        inserted_at,
        updated_at  

    from source
    where effective_to::date = '{{var('active_date')}}'::date