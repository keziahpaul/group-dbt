with 

source as ( 

    select * from {{ ref('ps_jurisdiction') }}

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
        last_activity_date,
        last_viewed_date,
        last_referenced_date,
        ps_activation_date_c,
        ps_contact_c,
        ps_lrcode_c,
        ps_stamp_duty_code_c,
        ps_state_c,
        ps_status_c,
        ps_subscription_c,
        ps_withdrawn_date_c,
        ps_withdrawn_reason_c,
        conveyancers_triennia_licence_expiry_date_c,
        conveyancers_triennial_licence_date_c,
        conveyancers_triennial_licence_name_c,
        conveyancers_triennial_licence_number_c,
        conveyancers_triennial_licence_type_c,
        current_jurisdiction_c,
        future_jurisdictions_c,
        jurisdiction_type_c,
        account_name_c,
        act_c,
        current_jurisdiction_del_c,
        future_jurisdictions_del_c,
        nsw_c,
        nt_c,
        qld_c,
        related_application_c,
        sa_c,
        state_c,
        tas_c,
        vic_c,
        wa_c,
        effective_from,
        effective_to,
        inserted_at,
        updated_at  

    from source
    where effective_to::date = '{{var('active_date')}}'::date