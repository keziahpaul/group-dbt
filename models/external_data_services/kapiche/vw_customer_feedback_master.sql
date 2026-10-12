select

    CREATION_DATE as "Creationdate",
    CSAT_RATING as "CSAT Rating",
    CSAT_COMMENT as "CSAT Comment",
    SUBSCRIBER_ID as "Subscriber ID",
    SUBSCRIBER_NAME as "Subscriber Name",
    ACCOUNT_MANAGEMENT_SEGMENT as "Account Management Segment",
    CUSTOMER_SEGMENT as "Customer Segment",
    SUBSCRIBER_STATE as "Subscriber State",
    CUSTOMER_TYPE as "Customer Type",
    ACCOUNT_OWNER as "Account Owner",
    SRC_DELTA_EXTRACT_TS --This is for file unload

from {{ ref('customer_feedback_master') }}

where
    CUSTOMER_TYPE is not NULL
    and INSERTED_AT
    = (select max(INSERTED_AT) from {{ ref('customer_feedback_master') }})
