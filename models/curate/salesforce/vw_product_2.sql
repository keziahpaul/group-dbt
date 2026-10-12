with 

source as ( 

    select * from {{ ref('product2') }}

)
    select
        id,
        name,
        product_code,
        description,
        is_active,
        created_date,
        created_by_id,
        last_modified_date,
        last_modified_by_id,
        system_modstamp,
        family,
        external_id,
        display_url,
        quantity_unit_of_measure,
        is_deleted,
        is_archived,
        last_viewed_date,
        last_referenced_date,
        stock_keeping_unit,
        effective_from,
        effective_to,
        inserted_at,
        updated_at  

    from source
    where effective_to::date = '{{var('active_date')}}'::date