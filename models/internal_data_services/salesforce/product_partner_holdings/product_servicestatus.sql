{{
    config(
        materialized='incremental',
        unique_key='id',
        merge_exclude_columns = ['inserted_at'],
        on_schema_change='append_new_columns'
    )
}}
With exchange_output As (
    Select
        e.subscriber_id,
        'PEXA Exchange' As product_name,
        e.first_transaction_date__c,
        e.last_transaction_date__c,
        e.total_transactionsl12m__c,
        e.transfer_transactions_l12m__c,
        e.workspace_revenue_l12m__c,
        null As registrationinvite_link_sent__c,
        null As api_call_types_used__c,
        null As ps_status_c,
        null As product_utilisation_c,
        null As product_master_registration_id_c,
        null As date_registered_c,
        null As total_revenue_c,
        null As settled_turnover_c,
        null As total_volume_buyer_cfy__c,
        null As total_volume_seller_cfy__c,
        null As registration_am_c,
        null As registration_am_email_c,
        null As send_integration_opt_in_c,
        null As pexa_commission_c,
        null As mobile_signing_transition_status__c,
        null As mobile_signing_transition_date__c,
        null As mobile_signing_contact__c,
        null As authoriser_exchange_user_id__c,
        e.src_delta_extract_ts
    From {{ ref('exchange_holdings') }} As e
    {% if is_incremental() %}
    where e.src_delta_extract_ts > (select coalesce(max(src_delta_extract_ts),  '{{ var('base_date') }}') from {{ this }} where product_Name ='PEXA Exchange')
    {% endif %}
),

pexa_projects_output As (
    Select
        p.subscriber_id,
        'PEXA Projects' As product_name,
        null As first_transaction_date__c,
        p.ws_last_created_date::date As last_transaction_date__c,
        null As total_transactionsl12m__c,
        null As transfer_transactions_l12m__c,
        null As workspace_revenue_l12m__c,
        null As registrationinvite_link_sent__c,
        null As api_call_types_used__c,
        null As ps_status_c,
        null As product_utilisation_c,
        null As product_master_registration_id_c,
        null As date_registered_c,
        null As total_revenue_c,
        null As settled_turnover_c,
        null As total_volume_buyer_cfy__c,
        null As total_volume_seller_cfy__c,
        null As registration_am_c,
        null As registration_am_email_c,
        null As send_integration_opt_in_c,
        null As pexa_commission_c,
        null As mobile_signing_transition_status__c,
        null As mobile_signing_transition_date__c,
        null As mobile_signing_contact__c,
        null As authoriser_exchange_user_id__c,
        p.src_delta_extract_ts
    From {{ ref('pexa_projects_holdings') }} As p
    {% if is_incremental() %}
    where p.src_delta_extract_ts > (select coalesce(max(src_delta_extract_ts),  '{{ var('base_date') }}') from {{ this }} where product_Name ='PEXA Projects')
    {% endif %}
),

mobile_signing_output As (
    Select
        m.subscriber_id,
        'Mobile Signing' As product_name,
        null As first_transaction_date__c,
        null As last_transaction_date__c,
        null As total_transactionsl12m__c,
        null As transfer_transactions_l12m__c,
        null As workspace_revenue_l12m__c,
        null As registrationinvite_link_sent__c,
        null As api_call_types_used__c,
        null As ps_status_c,
        null As product_utilisation_c,
        null As product_master_registration_id_c,
        null As date_registered_c,
        null As total_revenue_c,
        null As settled_turnover_c,
        null As total_volume_buyer_cfy__c,
        null As total_volume_seller_cfy__c,
        null As registration_am_c,
        null As registration_am_email_c,
        null As send_integration_opt_in_c,
        null As pexa_commission_c,
        initcap(m.status) As mobile_signing_transition_status__c,
        m.created_date As mobile_signing_transition_date__c,
        m.created_by As mobile_signing_contact__c,
        m.authoriser_exchange_user_id As authoriser_exchange_user_id__c,
        m.src_delta_extract_ts
    From {{ ref('mobile_signing') }} As m
    {% if is_incremental() %}
    where m.src_delta_extract_ts > (select coalesce(max(src_delta_extract_ts),  '{{ var('base_date') }}') from {{ this }} where product_Name ='Mobile Signing')
    {% endif %}
),

final_output As (
    Select * From exchange_output
    Union All
    Select * From pexa_projects_output
    Union All
    Select * From mobile_signing_output
    Order By 2, 1
)

Select
    replace(concat(f.subscriber_id, '-', f.product_name), ' ', '') As id,
    coalesce(id, '{{ env_var('DBT_DEFAULT_ACCOUNT') }}') As account_id,
    f.subscriber_id,
    f.product_name,
    f.first_transaction_date__c,
    f.last_transaction_date__c,
    f.total_transactionsl12m__c,
    f.transfer_transactions_l12m__c,
    f.workspace_revenue_l12m__c,
    f.registrationinvite_link_sent__c,
    f.api_call_types_used__c,
    f.ps_status_c,
    f.product_utilisation_c,
    f.product_master_registration_id_c,
    f.date_registered_c,
    f.total_revenue_c,
    f.settled_turnover_c,
    f.total_volume_buyer_cfy__c,
    f.total_volume_seller_cfy__c,
    f.registration_am_c,
    f.registration_am_email_c,
    f.send_integration_opt_in_c,
    f.pexa_commission_c,
    f.mobile_signing_transition_status__c,
    f.mobile_signing_transition_date__c,
    f.mobile_signing_contact__c,
    f.authoriser_exchange_user_id__c,
    convert_timezone('Australia/Sydney', f.src_delta_extract_ts) As src_delta_extract_ts,
    {{ var('inserted_at') }} As inserted_at,
    {{ var('updated_at') }} As updated_at
From final_output As f
Left Join {{ ref('vw_account') }} As a
    On f.subscriber_id::varchar = a.ps_external_id_c
