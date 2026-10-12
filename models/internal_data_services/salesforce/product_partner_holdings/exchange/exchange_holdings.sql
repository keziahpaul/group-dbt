{{
    config(
        materialized='incremental',
        unique_key='subscriber_id',
        merge_exclude_columns = ['inserted_at']
    )
}}
With min_max_transaction_dates as
(
    select  SUBSCRIBER_ID,
    MIN(DATE_LODGED) AS First_Transaction_date,
    MAX(DATE_LODGED) AS Last_Transaction_date,
    MAX(src_delta_extract_ts) AS src_delta_extract_ts
    from {{ ref('transactions') }}
    GROUP BY SUBSCRIBER_ID
),
transactions_count as 
(
    select  t.SUBSCRIBER_ID,
    COUNT(t.DOCUMENT_ID) AS Total_Transactions,
    MAX(src_delta_extract_ts) AS src_delta_extract_ts
    from {{ ref('transactions') }} t
    where (DATEDIFF(month, date_lodged, current_date) <=12 and DATEDIFF(month, date_lodged, current_date) >=1)
    GROUP BY t.SUBSCRIBER_ID
),
workspace_revenue_excl as 
(
    select  w.SUBSCRIBER_ID,
    SUM(pexa_fee_total)/1.1 AS Workspace_revenue,
    MAX(src_delta_extract_ts) AS src_delta_extract_ts
    from   {{ ref('workspace_revenue') }} w 
    where (DATEDIFF(month, datetime_lodged, current_date) <=12 and DATEDIFF(month, datetime_lodged, current_date) >=1)
    GROUP BY w.SUBSCRIBER_ID
),
transfer_transactions_count as 
(
    select  SUBSCRIBER_ID,
    COUNT(DOCUMENT_ID)  AS Transfer_transactions,
    MAX(src_delta_extract_ts) AS src_delta_extract_ts
    from  {{ ref('transactions') }}
    where document_type ='Transfer'
    and (DATEDIFF(month, date_lodged, current_date) <=12 and DATEDIFF(month, date_lodged, current_date) >=1)
    GROUP BY SUBSCRIBER_ID
)

select 
    a.SUBSCRIBER_ID,
    First_Transaction_date::date AS first_transaction_date__c,
    Last_Transaction_date::date AS last_transaction_date__c,
    Total_Transactions AS total_transactionsl12m__c,
    Transfer_transactions AS transfer_transactions_l12m__c,
    Workspace_revenue AS Workspace_Revenue_L12M__c,
    greatest_ignore_nulls(a.src_delta_extract_ts,b.src_delta_extract_ts,c.src_delta_extract_ts,w.src_delta_extract_ts) as src_delta_extract_ts,
    {{ var('inserted_at') }} as inserted_at,
    {{ var('updated_at') }} as updated_at
from min_max_transaction_dates  a
left join transactions_count b
on a.SUBSCRIBER_ID=b.SUBSCRIBER_ID
left join transfer_transactions_count c
on a.SUBSCRIBER_ID=c.SUBSCRIBER_ID
left join workspace_revenue_excl w
on a.SUBSCRIBER_ID=w.SUBSCRIBER_ID
{%if is_incremental()%}
where greatest_ignore_nulls(a.src_delta_extract_ts,b.src_delta_extract_ts,c.src_delta_extract_ts,w.src_delta_extract_ts) > (select max(src_delta_extract_ts) from {{this}})
{%endif%}