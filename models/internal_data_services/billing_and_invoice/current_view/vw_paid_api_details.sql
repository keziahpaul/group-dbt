select
    subscriber_id
    , subscriber_name
    , subscriber_status
    , subscriber_type
    , workspace_id
    , settlement_date
    , workspace_status
    , api_description
    , integrator_name
    , request_date
    , count_api_calls
    , subscriber_reference
    , workspace_role
    , transaction_type
    , webhook_notification_count
    , webhook_registration_id
    , webhook_uri
    , event_type
    , source
    , src_delta_extract_ts
    , inserted_at
    , updated_at
from {{ ref('paid_api_details') }}

