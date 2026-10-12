with 

source as ( 

    select * from {{ ref('ps_offer') }}

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
        last_viewed_date,
        last_referenced_date,
        ps_provider_c,
        ps_daysfrom_settlement_c,
        ps_expiry_date_c,
        ps_external_offer_id_c,
        ps_fulfillment_endpoint_c,
        ps_fulfillment_type_c,
        ps_handover_description_c,
        ps_handover_footer_c,
        ps_handover_header_c,
        ps_handover_image_c,
        ps_handover_logo_c,
        ps_handover_title_c,
        ps_jurisdiction_c,
        ps_offer_badge_c,
        ps_offer_logo_c,
        ps_postcode_c,
        ps_property_classification_c,
        ps_settlement_status_c,
        ps_start_date_c,
        ps_user_role_c,
        ps_version_c,
        effective_from,
        effective_to,
        inserted_at,
        updated_at  

    from source
    where effective_to::date = '{{var('active_date')}}'::date