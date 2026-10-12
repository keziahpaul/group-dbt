WITH LP AS (
    SELECT DISTINCT
        S.WORKSPACE_ID,
        S.SETTLEMENT_ID,
        SUM(SS.AMOUNT) AS AMOUNT,
        SC.NAME AS AMOUNT_TYPE,
        DATE_TRUNC('day', S.DATE1) AS SETTLEMENT_DATE,
        SS.PARTICIPANT_ID,
        P.SUBSCRIBER_ID,
        P.LEGAL_ENTITY_NAME,
        P.PARTY_NAME,
        P.SUBSCRIBER_REF,
        P.WORKSPACE_ROLE
    FROM {{ source('exchange_share','vw_settlement_schedules') }} AS SS
    INNER JOIN {{ source('exchange_share','vw_settlement_categories') }} AS SC
        ON SS.SETTLEMENT_CATEGORY_ID = SC.SETTLEMENT_CATEGORY_ID
    INNER JOIN {{ source('exchange_share','vw_settlements') }} AS S
        ON SS.SETTLEMENT_ID = S.SETTLEMENT_ID
    INNER JOIN (
        SELECT
            P.WORKSPACE_ID,
            P.PARTICIPANT_ID,
            P.SUBSCRIBER_ID,
            R.NAME AS WORKSPACE_ROLE,
            S.LEGAL_ENTITY_NAME,
            P.REFERENCE AS SUBSCRIBER_REF,
            PR.PARTY_NAME
        FROM {{ source('exchange_share','vw_participants') }} AS P
        INNER JOIN {{ source('exchange_share','vw_workspace_roles') }} AS R
            ON P.WORKSPACE_ROLE_ID = R.WORKSPACE_ROLE_ID
        INNER JOIN {{ source('exchange_share','vw_subscribers') }} AS S
            ON S.SUBSCRIBER_ID = P.SUBSCRIBER_ID
        INNER JOIN {{ source('exchange_share','vw_subscriber_types') }} AS T
            ON S.SUBSCRIBER_TYPE_ID = T.SUBSCRIBER_TYPE_ID
        INNER JOIN (
            SELECT
                PP.PARTICIPANT_ID,
                ORG.NAME AS PARTY_NAME
            FROM {{ source('exchange_share','vw_participant_partys') }} AS PP
            INNER JOIN {{ source('exchange_share','vw_organisations') }} AS ORG
                ON PP.PARTY_ID = ORG.PARTY_ID
        ) AS PR ON P.PARTICIPANT_ID = PR.PARTICIPANT_ID
        WHERE P.STATUS = 'ACTIVE'
        AND R.NAME IN ('INCOMING_MORTGAGEE', 'MORTGAGEE_ON_TITLE')
    ) AS P ON S.WORKSPACE_ID = P.WORKSPACE_ID
        AND SS.PARTICIPANT_ID = P.PARTICIPANT_ID
    WHERE s.date1 BETWEEN {{ var('local_current_date') }} - INTERVAL '7 DAYS' 
        AND {{ var('local_current_date') }}
    AND s.status IN ('DISBURSED')
    AND sc.name IN ('Loan Payout', 'Loan Proceeds')
    GROUP BY s.workspace_id, s.settlement_id, sc.name, DATE_TRUNC('day', s.date1), 
        ss.participant_id, p.subscriber_id, p.legal_entity_name, p.party_name, 
        p.subscriber_ref, p.workspace_role
),

T AS (
    SELECT
        DATE_TRUNC('day', L.DATE1) AS DATE_LODGED,
        W.WORKSPACE_ID,
        W.JURISDICTION,
        DT.VALUE1 AS DOCUMENT_TYPE,
        CASE
            WHEN L.TRANSACTION_TYPE IS NOT NULL THEN L.TRANSACTION_TYPE
            WHEN '5' IN (
                SELECT DOCUMENT_TYPE_ID
                FROM {{ source('exchange_share','vw_documents') }}
                WHERE LODGEMENT_ID = L.LODGEMENT_ID
            ) THEN 'TRANSFER'
            WHEN L.TRANSACTION_TYPE IS NULL THEN 'OTHERS'
        END AS TRANSACTION_TYPE,
        WR.NAME AS WORKSPACE_ROLE,
        L.STATUS,
        PART.REFERENCE AS SUBSCRIBER_REF
    FROM {{ source('exchange_share','vw_documents') }} AS D
    INNER JOIN {{ source('exchange_share','vw_document_types') }} AS DT
        ON D.DOCUMENT_TYPE_ID = DT.DOCUMENT_TYPE_ID
    INNER JOIN {{ source('exchange_share','vw_lodgements') }} AS L
        ON D.LODGEMENT_ID = L.LODGEMENT_ID
    INNER JOIN {{ source('exchange_share','vw_workspaces') }} AS W
        ON L.WORKSPACE_ID = W.WORKSPACE_ID
    INNER JOIN {{ source('exchange_share','vw_subscribers') }} AS S
        ON D.CREATED_BY_SUSBSCRIBER_ID = S.SUBSCRIBER_ID
    INNER JOIN {{ source('exchange_share','vw_subscriber_types') }} AS ST
        ON S.SUBSCRIBER_TYPE_ID = ST.SUBSCRIBER_TYPE_ID
    INNER JOIN {{ source('exchange_share','vw_workspace_roles') }} AS WR
        ON D.CREATED_BY_ROLE_ID = WR.WORKSPACE_ROLE_ID
    INNER JOIN {{ source('exchange_share','vw_participants') }} AS PART
        ON S.SUBSCRIBER_ID = PART.SUBSCRIBER_ID
        AND D.CREATED_BY_ROLE_ID = PART.WORKSPACE_ROLE_ID
        AND W.WORKSPACE_ID = PART.WORKSPACE_ID
    WHERE DT.VALUE1 IN ('Mortgage', 'National Mortgage', 'Discharge of Mortgage')
    AND (L.TRANSACTION_TYPE IS NULL OR L.TRANSACTION_TYPE NOT IN ('CONSENT', 'NOMINATION'))
    AND PART.STATUS = 'ACTIVE'
)

SELECT DISTINCT
    LP.WORKSPACE_ID,
    LP.SETTLEMENT_ID,
    LP.AMOUNT,
    LP.AMOUNT_TYPE,
    LP.SETTLEMENT_DATE,
    LP.PARTICIPANT_ID,
    LP.SUBSCRIBER_ID,
    LP.LEGAL_ENTITY_NAME,
    LP.PARTY_NAME,
    LP.SUBSCRIBER_REF,
    LP.WORKSPACE_ROLE,
    TITLE.TITLES,
    CASE
        WHEN T.WORKSPACE_ID IS NULL OR T.STATUS NOT IN ('CLOSED', 'LODGED')
        THEN 0 ELSE 1
    END AS MORTGAGE_DOC_LODGED,
    T.STATUS,
    T.DOCUMENT_TYPE,
    L.TRANSACTION_TYPE
FROM LP
LEFT JOIN T 
    ON LP.WORKSPACE_ID = T.WORKSPACE_ID
    AND LP.WORKSPACE_ROLE = T.WORKSPACE_ROLE
LEFT JOIN {{ source('exchange_share','vw_lodgements') }} AS L
    ON LP.SETTLEMENT_ID = L.SETTLEMENT_ID
INNER JOIN (
    SELECT
        P.WORKSPACE_ID,
        LISTAGG(P.LAND_IDENTIFIER, ', ') WITHIN GROUP (ORDER BY P.WORKSPACE_ID) AS TITLES
    FROM {{ source('exchange_share','vw_propertys') }} AS P
    GROUP BY P.WORKSPACE_ID
) AS TITLE ON LP.WORKSPACE_ID = TITLE.WORKSPACE_ID
WHERE LP.PARTY_NAME = 'AUSTRALIA AND NEW ZEALAND BANKING GROUP LIMITED'    