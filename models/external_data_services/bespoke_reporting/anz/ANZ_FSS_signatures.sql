SELECT
    S.WORKSPACE_ID,
    S.DATE1 AS SETTLEMENT_DATE,
    U.USERNAME,
    U.FIRST_NAME,
    U.LAST_NAME,
    SG.DATE1 AS SIGNATURE_DATE
FROM {{ source('exchange_share','vw_settlements') }} AS S
INNER JOIN {{ source('exchange_share','vw_participants') }} AS P
    ON S.WORKSPACE_ID = P.WORKSPACE_ID
    AND P.SUBSCRIBER_ID = '601'
    AND P.STATUS = 'ACTIVE'
INNER JOIN {{ source('exchange_share','vw_documents') }} AS D
    ON S.SETTLEMENT_ID = D.SETTLEMENT_ID
    AND D.DOCUMENT_TYPE_ID = 8
INNER JOIN {{ source('exchange_share','vw_document_signatures') }} AS DS
    ON D.DOCUMENT_ID = DS.DOCUMENT_ID
INNER JOIN {{ source('exchange_share','vw_signatures') }} AS SG
    ON DS.SIGNATURE_ID = SG.SIGNATURE_ID
    AND SG.WORKSPACE_ROLE_ID = P.WORKSPACE_ROLE_ID
INNER JOIN {{ source('exchange_share','vw_users') }} AS U
    ON SG.USER_ID = U.USER_ID
    AND U.SUBSCRIBER_ID = '601'
WHERE
    s.date1 BETWEEN  {{ var('local_current_date') }} - INTERVAL '7 DAYS' AND {{ var('local_current_date') }}
    AND S.TYPE1 = 'TRANSFER'
