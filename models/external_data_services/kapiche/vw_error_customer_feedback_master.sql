select
    related_account_c,
    csat_comment as "CSAT Comment",
    subscriber_id as "Subscriber ID",
    customer_type as "Customer Type",
    inserted_at

from {{ ref('customer_feedback_master') }}

where
    customer_type is NULL

