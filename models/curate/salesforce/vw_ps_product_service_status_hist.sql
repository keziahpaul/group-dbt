with 

source as ( 

    select * from {{ ref('ps_productservicestatus') }}

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
        ps_subscription_c,
        ps_product_service_name_c,
        ps_rag_status_c,
        ps_status_c,
        account_c,
        do_not_talk_to_me_about_this_product_c,
        product_notes_c,
        reason_c,
        date_registered_c,
        product_registration_id_c,
        all_other_volume_immot_last_fy_c,
        all_other_volume_im_mot_current_fy_c,
        all_other_volume_im_mot_last_fy_minus_1_c,
        incoming_revenue_current_fy_c,
        incoming_revenue_last_fy_minus_1_c,
        incoming_revenue_last_fy_c,
        institution_revenue_current_fy_c,
        institution_revenue_last_fy_minus_1_c,
        institution_revenue_last_fy_c,
        outgoing_revenue_current_fy_c,
        outgoing_revenue_last_fy_minus_1_c,
        outgoing_revenue_last_fy_c,
        refinance_volume_immot_last_fy_c,
        refinance_volume_im_mot_current_fy_c,
        refinance_volume_im_mot_last_fy_minus_1_c,
        standalones_volume_immot_last_fy_c,
        standalones_volume_im_mot_current_fy_c,
        standalones_volume_im_mot_last_fy_minus_1_c,
        total_transaction_volume_current_fy_c,
        total_transaction_volume_last_fy_minus_1_c,
        total_transaction_volume_last_fy_c,
        transfer_volume_immot_last_fy_c,
        transfer_volume_im_mot_current_fy_c,
        transfer_volume_im_mot_last_fy_minus_1_c,
        external_id_c,
        total_workspace_revenue_current_fy_c,
        last_transaction_date_c,
        first_transaction_date_c,
        effective_from,
        effective_to,
        inserted_at,
        updated_at  

    from source
   