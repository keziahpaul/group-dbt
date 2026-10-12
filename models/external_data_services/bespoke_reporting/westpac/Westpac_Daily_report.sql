

WITH daily_lodgements AS (
    select 
        lodgement_id
        ,date1
        ,transaction_type
        ,status
        ,workspace_id
    from {{ source('exchange_share', 'vw_lodgements') }}
    where date1 BETWEEN ({{ get_previous_weekday(var('local_current_date')) }}) AND {{ var('local_current_date') }}
        AND (transaction_type IS NULL OR transaction_type NOT IN ('CONSENT', 'NOMINATION'))
        AND status IN ('CLOSED', 'LODGED')
),


workgroups AS (
    SELECT
        wg_ws.workspace_id AS workspace_id,
        wg.subscriber_id AS subscriber_id,
        LISTAGG(wg.NAME, ' | ') WITHIN GROUP (ORDER BY wg.NAME) AS workgroup
    FROM daily_lodgements l
    INNER JOIN {{ source('exchange_share', 'vw_workgroup_workspaces') }} wg_ws
        ON wg_ws.workspace_id = l.workspace_id
    INNER JOIN {{ source('exchange_share', 'vw_workgroups') }} wg
        ON wg.workgroup_id = wg_ws.workgroup_id
    WHERE wg.subscriber_id IN (1079, 621)
    GROUP BY wg_ws.workspace_id, wg.subscriber_id
),

title AS (
    SELECT
        p.workspace_id,
        LISTAGG(p.land_identifier, ', ') WITHIN GROUP (ORDER BY p.land_identifier) AS title_references
    FROM daily_lodgements l
    INNER JOIN {{ source('exchange_share', 'vw_propertys') }} p
        ON l.workspace_id = p.workspace_id
    GROUP BY p.workspace_id
)

SELECT
    (DATE_TRUNC('month', DATEADD('month', 1, l.date1)) - INTERVAL '1 day')::date AS END_OF_MONTH,
    DATEADD('day', 6, DATE_TRUNC('week', l.date1))::date AS END_OF_WEEK,
    l.date1::date AS "DATE",
    s.name AS subscriber_name,
    st.name AS subscriber_type,
    w.jurisdiction,
    CASE
        WHEN l.transaction_type IN ('DM', 'WCDM') THEN 'Refinance'
        WHEN l.transaction_type IN ('NOMINATION') THEN 'Nomination'
        WHEN l.transaction_type LIKE ('%T%') THEN 'Transfer'
        WHEN l.transaction_type IN ('D', 'CD', 'WCD') THEN 'Standalone Discharge'
        WHEN l.transaction_type IN ('M', 'CM', 'WCM') THEN 'Standalone Mortgage'
        ELSE 'Other'
    END AS transaction_type,
    w.number1 AS workspace_number,
    wr.name AS Role,
    d.document_id,
    wrkgp.workgroup,
    part.reference AS subscriber_reference,
    title.title_references
FROM {{ source('exchange_share', 'vw_documents') }} d
    INNER JOIN daily_lodgements l
        ON d.lodgement_id = l.lodgement_id
    INNER JOIN {{ source('exchange_share', 'vw_workspaces') }} w
        ON l.workspace_id = w.workspace_id
    INNER JOIN {{ source('exchange_share', 'vw_subscribers') }} s
        ON d.created_by_susbscriber_id = s.subscriber_id
        AND s.subscriber_id IN (1079, 621)
        AND s.subscriber_type_id = 1
    INNER JOIN {{ source('exchange_share', 'vw_subscriber_types') }} st
        ON s.subscriber_type_id = st.subscriber_type_id
    INNER JOIN {{ source('exchange_share', 'vw_workspace_roles') }} wr
        ON d.created_by_role_id = wr.workspace_role_id
    INNER JOIN {{ source('exchange_share', 'vw_participants') }} part
        ON s.subscriber_id = part.subscriber_id
        AND d.created_by_role_id = part.workspace_role_id
        AND w.workspace_id = part.workspace_id
        AND part.status = 'ACTIVE'
    INNER JOIN workgroups wrkgp
        ON part.workspace_id = wrkgp.workspace_id
        AND part.subscriber_id = wrkgp.subscriber_id
    INNER JOIN title
        ON part.workspace_id = title.workspace_id
WHERE part.subscriber_id IN (1079, 621)
    AND d.document_type_id NOT IN (3, 4, 10, 23)


