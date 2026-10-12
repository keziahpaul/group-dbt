{{
    config(
        materialized='incremental',
        unique_key='id',
        merge_exclude_columns = ['inserted_at']
    )
}}
With
{%if is_incremental()%}
target_max_timestamp as 
(
    select max(src_delta_extract_ts) as last_load_max_timestamp from {{this}}
),
{%endif%}
nontransfer_document_types as 
(
    select dt.value1 as document_type
    from {{ source('exchange_share','vw_document_types') }} dt
    WHERE
    dt.value1 in ('Mortgage','Discharge of Mortgage', 'Caveat', 'Settlement Notice', 'Removal of Settlement Notice', 'Withdrawal of Caveat', 'Priority Notice',
    'Withdrawal of Priority Notice', 'Extension of Priority Notice','National Mortgage', 'Survivorship',  'Encumbrance', 'Discharge of Encumbrance','Transmission',
    'Transmission Direct to Beneficiary','Residual Document','Transfer by Third Party', 'Transfer of Interest', 'Lease','Surrender of Lease','Change of Name')
)
,
nontransfer_transactions as (
SELECT 
    concat(concat(d.document_id, s.subscriber_id), wr.workspace_role_id) as id,
    s.subscriber_id,
    d.document_id,
    l.date1 AS date_lodged,
    dt.value1 AS document_type,
    'nontransfer' as doc_group,
    CASE
      WHEN l.transaction_type IS NOT NULL THEN l.transaction_type
      WHEN '5' IN (SELECT document_type_id FROM {{ source('exchange_share', 'vw_documents') }}  WHERE lodgement_id=l.lodgement_id) THEN 'TRANSFER'
      WHEN l.transaction_type IS NULL THEN 'OTHERS'
    END AS transaction_type,
    wr.workspace_role_id,
    w.workspace_id,
    greatest_ignore_nulls(s.inserted_at,d.inserted_at,l.inserted_at,dt.inserted_at) as src_delta_extract_ts
FROM {{ source('exchange_share', 'vw_documents') }}  d
    INNER JOIN {{ source('exchange_share', 'vw_document_types') }} dt ON dt.document_type_id=d.document_type_id
    INNER JOIN {{ source('exchange_share', 'vw_lodgements') }}  l ON d.lodgement_id=l.lodgement_id
    INNER JOIN {{ source('exchange_share', 'vw_workspaces') }}  w ON l.workspace_id=w.workspace_id
    INNER JOIN {{ source('exchange_share', 'vw_users') }} u ON u.user_id=d.created_by
    INNER JOIN {{ source('exchange_share', 'vw_subscribers') }} s ON u.subscriber_id=s.subscriber_id
    INNER JOIN {{ source('exchange_share', 'vw_subscriber_types') }} st ON s.subscriber_type_id=st.subscriber_type_id
    INNER JOIN {{ source('exchange_share', 'vw_workspace_roles') }} wr ON wr.workspace_role_id=d.created_by_role_id
WHERE
    dt.value1 in (select document_type from nontransfer_document_types)
    AND (l.transaction_type IS NULL OR l.transaction_type NOT IN ('CONSENT','NOMINATION'))
    AND l.status IN ('CLOSED','LODGED')
    AND d.dealing_number IS NOT NULL
    AND st.CATEGORY IN ('PRINCIPAL' , 'REPRESENTATIVE')

{% if is_incremental()%}
    and (   s.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or d.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or l.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or dt.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
        )
{%endif%}
)
,active_participants as (
    select 
        distinct subscriber_id,
        workspace_role_id, 
        workspace_id
    from {{ source('exchange_share', 'vw_participants')}}
    WHERE status='ACTIVE'
)
, 
transactions as (
select trn.id,
    trn.subscriber_id,
    trn.document_id,
    trn.date_lodged,
    trn.document_type,
    trn.doc_group,
    trn.transaction_type,
    trn.src_delta_extract_ts
from nontransfer_transactions trn
inner join active_participants part on part.subscriber_id=trn.subscriber_id
    AND part.workspace_role_id=trn.workspace_role_id
    AND part.workspace_id=trn.workspace_id
    
UNION ALL 

SELECT 
     concat(concat(d.document_id, s.subscriber_id), wr.workspace_role_id) as id,
    s.subscriber_id,
    d.document_id,
    l.date1 AS date_lodged,
    dt.value1 AS document_type,
    'transfer' as doc_group,
    CASE
      WHEN l.transaction_type IS NOT NULL THEN l.transaction_type
      WHEN '5' IN (SELECT document_type_id FROM {{ source('exchange_share', 'vw_documents') }}  WHERE lodgement_id=l.lodgement_id) THEN 'TRANSFER'
      WHEN l.transaction_type IS NULL THEN 'OTHERS'
    END AS transaction_type,
    greatest_ignore_nulls(s.inserted_at,d.inserted_at,l.inserted_at,dt.inserted_at) as src_delta_extract_ts
    FROM {{ source('exchange_share', 'vw_documents') }} d
    INNER JOIN {{ source('exchange_share', 'vw_document_types') }} dt ON dt.document_type_id=d.document_type_id
    INNER JOIN {{ source('exchange_share', 'vw_lodgements') }}  l ON d.lodgement_id=l.lodgement_id
    INNER JOIN {{ source('exchange_share', 'vw_workspaces') }}  w ON l.workspace_id=w.workspace_id
    CROSS JOIN {{ source('exchange_share', 'vw_subscribers') }} s
    INNER JOIN {{ source('exchange_share', 'vw_subscriber_types') }} st ON s.subscriber_type_id=st.subscriber_type_id
    CROSS JOIN {{ source('exchange_share', 'vw_workspace_roles') }} wr
    INNER JOIN {{ source('exchange_share', 'vw_participants') }} as part ON wr.workspace_role_id=part.workspace_role_id AND part.workspace_id=w.workspace_id AND part.subscriber_id=s.subscriber_id
    INNER JOIN
    (SELECT pp.participant_id,
            listagg(org.NAME,', ' ) WITHIN GROUP (ORDER BY org.NAME) AS org_parties,
            listagg(person.full_name,', ' ) WITHIN GROUP (ORDER BY person.full_name) AS person_parties
      FROM {{ source('exchange_share', 'vw_participant_partys') }} pp
      LEFT JOIN {{ source('exchange_share', 'vw_persons') }} person ON pp.party_id=person.party_id
      LEFT JOIN {{ source('exchange_share', 'vw_organisations') }} org ON pp.party_id=org.party_id
      WHERE pp.party_id IN (
          SELECT gp.party_id FROM {{ source('exchange_share', 'vw_transfers') }}  t,
          {{ source('exchange_share', 'vw_transfer_tenancies') }} tt,
          {{ source('exchange_share', 'vw_tenancy_groups') }} tg,
          {{ source('exchange_share', 'vw_proprietor_groups') }} pg,
          {{ source('exchange_share', 'vw_group_proprietors') }} gp
          WHERE tt.transfer_id=t.transfer_id
          AND tt.tenancy_detail_id=tg.tenancy_detail_id
          AND tg.proprietor_group_id=pg.proprietior_group_id
          AND pg.proprietior_group_id=gp.proprietor_group_id
          UNION ALL
          SELECT tp.party_id FROM {{ source('exchange_share', 'vw_transfers') }} t,
          {{ source('exchange_share', 'vw_transfer_transferors') }} tt,
          {{ source('exchange_share', 'vw_transferor_partys') }} tp
          WHERE t.transfer_id=tt.transfer_id
          AND tt.transferor_id=tp.transferor_id
    ) GROUP BY pp.participant_id) party_names ON party_names.participant_id=part.participant_id
    WHERE
    dt.value1 in ('Transfer')
    AND (l.transaction_type IS NULL OR l.transaction_type NOT IN ('CONSENT','NOMINATION'))
    AND l.status IN ('CLOSED','LODGED')
    AND d.dealing_number IS NOT NULL
    AND part.status='ACTIVE'

{% if is_incremental()%}
    and (   s.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or d.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or l.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or dt.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
        )
{%endif%}
)

select id,
    subscriber_id,
    document_id,
    date_lodged,
    document_type,
    doc_group,
    transaction_type,
    CONVERT_TIMEZONE('Australia/Sydney',src_delta_extract_ts) as src_delta_extract_ts,
    {{ var('inserted_at') }} as inserted_at,
    {{ var('updated_at') }} as updated_at
 from transactions