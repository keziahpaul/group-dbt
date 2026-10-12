{{
    config(
        materialized='incremental',
        unique_key='id',
        merge_exclude_columns = ['inserted_at']
    )
}}
with
{%if is_incremental()%}
target_max_timestamp as 
(
    select max(src_delta_extract_ts) as last_load_max_timestamp from {{this}}
),
{%endif%}
relevant_document_types as 
(
    select dt.value1 as document_type
    from {{ source('exchange_share', 'vw_document_types') }} dt
    WHERE
    dt.value1 in ('Mortgage','Discharge of Mortgage', 'Caveat', 'Settlement Notice', 'Removal of Settlement Notice', 'Withdrawal of Caveat', 'Priority Notice',
    'Withdrawal of Priority Notice', 'Extension of Priority Notice','National Mortgage', 'Survivorship',  'Encumbrance', 'Discharge of Encumbrance','Transmission',
    'Transmission Direct to Beneficiary','Residual Document','Transfer by Third Party', 'Transfer of Interest', 'Lease','Surrender of Lease','Change of Name','Transfer')
),
revenue AS
(
    SELECT *
    FROM {{ source('exchange_share', 'vw_sales_procurement_journal') }}   sj
    WHERE sj.fee_type = 'PX_SALE'
    AND sj.doc_type IN (select document_type from relevant_document_types  )
    and exception_flag = False
    {% if is_incremental()%}
    and sj.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
    {%endif%}
),
final_output as (
SELECT
    concat(concat(p.participant_id, d.document_id), case when sj.subs_billing_entity != s.subscriber_id then 1 else 0 end) id,
    CASE WHEN dt.value1 IN ('National Mortgage','Discharge of Mortgage') THEN sc.subscriber_id
        ELSE s.subscriber_id END AS subscriber_id,
    l.date1 AS datetime_lodged,
    d.document_id AS document_id,
    dt.value1 AS document_type,
    CASE
        WHEN l.transaction_type IS NOT NULL THEN l.transaction_type
        WHEN '5' IN (SELECT document_type_id FROM {{ source('exchange_share', 'vw_documents') }} WHERE lodgement_id=l.lodgement_id) THEN 'TRANSFER'
        WHEN l.transaction_type IS NULL THEN 'OTHERS'
    END AS transaction_type,

    sj.subscriber_role AS workspace_role,
    sj.subs_billing_entity AS billing_subscriber_id,
    sj.pexa_fee_net,
    sj.pexa_fee_gst,
    sj.pexa_fee_total,
    greatest_ignore_nulls(s.inserted_at,d.inserted_at,l.inserted_at,dt.inserted_at,sj.inserted_at) as src_delta_extract_ts
FROM {{ source('exchange_share', 'vw_documents') }} d
    INNER JOIN {{ source('exchange_share', 'vw_document_types') }} dt ON dt.document_type_id=d.document_type_id
    INNER JOIN {{ source('exchange_share', 'vw_lodgements') }} l ON l.lodgement_id = d.lodgement_id
    INNER JOIN {{ source('exchange_share', 'vw_workspaces') }} w ON w.workspace_id = l.workspace_id
    INNER JOIN {{ source('exchange_share', 'vw_users') }} u ON u.user_id=d.created_by
    INNER JOIN {{ source('exchange_share', 'vw_subscribers') }} sc ON u.subscriber_id=sc.subscriber_id
    INNER JOIN {{ source('exchange_share', 'vw_subscriber_types') }} stc ON sc.subscriber_type_id=stc.subscriber_type_id
    LEFT JOIN revenue sj ON d.document_id = sj.pexa_doc_id
    LEFT JOIN {{ source('exchange_share', 'vw_workspace_roles') }} wr ON wr.NAME = sj.subscriber_role
    LEFT JOIN {{ source('exchange_share', 'vw_subscribers') }} s ON s.subscriber_id = sj.subscriber_id
    LEFT JOIN {{ source('exchange_share', 'vw_subscribers') }} sb ON sb.subscriber_id = sj.subs_billing_entity
    LEFT JOIN {{ source('exchange_share', 'vw_subscriber_types') }} st ON s.subscriber_type_id=st.subscriber_type_id
    LEFT JOIN {{ source('exchange_share', 'vw_subscriber_types') }} stb ON sb.subscriber_type_id=stb.subscriber_type_id
    LEFT JOIN {{ source('exchange_share', 'vw_participants') }} p ON p.workspace_id=w.workspace_id AND p.subscriber_id=s.subscriber_id AND p.workspace_role_id=wr.workspace_role_id
   
WHERE dt.value1 in (select document_type from relevant_document_types  )
    AND (l.transaction_type IS NULL OR l.transaction_type NOT IN ('CONSENT','NOMINATION'))
    AND l.status IN ('CLOSED','LODGED')
    AND (p.status = 'ACTIVE' OR p.status IS NULL)
{% if is_incremental()%}
    and (   s.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or d.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or l.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or dt.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or sj.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
        )
{%endif%}
),

max_src_delta_extract as 
(
    select id, max(CONVERT_TIMEZONE('Australia/Sydney',src_delta_extract_ts)) as max_src_delta_extract_ts
    from final_output
    group by id
)

select  f.id , 
        subscriber_id,
        document_id,
        datetime_lodged,
        document_type,
        transaction_type,
        workspace_role,
        billing_subscriber_id,
        pexa_fee_net,
        pexa_fee_gst,
        pexa_fee_total,
        max_src_delta_extract_ts as src_delta_extract_ts,
        {{ var('inserted_at') }} as inserted_at,
        {{ var('updated_at') }} as updated_at
from final_output f
join max_src_delta_extract m
on f.id = m.id
GROUP BY f.id, 
        subscriber_id,
        datetime_lodged,
        document_id,
        document_type,
        transaction_type,
        workspace_role,
        billing_subscriber_id,
        pexa_fee_net,
        pexa_fee_gst,
        pexa_fee_total,
        max_src_delta_extract_ts,
        {{ var('inserted_at') }},
        {{ var('updated_at') }}

