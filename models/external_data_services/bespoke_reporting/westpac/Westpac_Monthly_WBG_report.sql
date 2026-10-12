with workspaces as
(
    SELECT L.settlement_id,
        CAST(L.date1 AS DATE) AS lodgement_date,
        w.workspace_id,
        w.number1 AS workspace_number,
        w.jurisdiction,
        L.transaction_type,
        L.express_refi_flag,
        P.participant_id,
        P.subscriber_id,
        S.NAME AS subscriber,
        WR.NAME AS workspace_role,
        TRIM(P.REFERENCE) AS reference
    FROM {{ source('exchange_share', 'vw_lodgements') }} L
        INNER JOIN {{ source('exchange_share', 'vw_workspaces') }} w ON w.workspace_id = L.workspace_id
        INNER JOIN {{ source('exchange_share', 'vw_participants') }} P ON P.workspace_id = L.workspace_id
        INNER JOIN {{ source('exchange_share', 'vw_subscribers') }} S ON S.subscriber_id = P.subscriber_id
        INNER JOIN {{ source('exchange_share', 'vw_workspace_roles') }} WR ON WR.workspace_role_id = P.workspace_role_id
    WHERE P.subscriber_id IN (1079, 621)
        AND P.workspace_role_id in (1,5)
        AND P.status = 'ACTIVE'
        AND L.date1 BETWEEN date_trunc('month', {{ var('local_current_date') }} - interval '1 month') AND  date_trunc('month', {{ var('local_current_date') }} )
        AND L.transaction_type NOT IN ('SN','WSN','WC','C','CONSENT','NOMINATION')
),
workgroups as
(
    SELECT wg_ws.workspace_id AS workspace_id,
        wg.subscriber_id AS subscriber_id,
        LISTAGG(wg.NAME, ' | ') WITHIN GROUP (order by wg.NAME) AS workgroup
    FROM {{ source('exchange_share', 'vw_workgroup_workspaces') }} wg_ws
        INNER JOIN {{ source('exchange_share', 'vw_workgroups') }} wg ON wg.workgroup_id=wg_ws.workgroup_id
    WHERE EXISTS (SELECT * FROM workspaces WHERE workspaces.workspace_id = wg_ws.workspace_id)
    GROUP BY wg_ws.workspace_id, wg.subscriber_id
),
parties as
(
    SELECT P.workspace_id,
        pp.participant_id,
        LISTAGG(party, ' | ') WITHIN GROUP (order by P.workspace_id,pp.participant_id) AS party
    FROM {{ source('exchange_share', 'vw_partys') }} P
        INNER JOIN {{ source('exchange_share', 'vw_participant_partys') }} pp ON pp.party_id = P.party_id
        INNER JOIN {{ source('exchange_share', 'vw_party_roles') }} pr ON pr.party_id = P.party_id AND pr.workspace_role_id IN (1,5)
        LEFT JOIN (
            SELECT party_id,full_name AS party FROM {{ source('exchange_share', 'vw_persons') }} person
                UNION ALL
            SELECT party_id,NAME FROM {{ source('exchange_share', 'vw_organisations') }} org
        ) party ON P.party_id=party.party_id
    WHERE EXISTS (SELECT * FROM workspaces WHERE workspaces.workspace_id = P.workspace_id)
    GROUP BY P.workspace_id,
        pp.participant_id
)
-- RETURNS WBC AND SGB in MOT
SELECT
    lodgement_date,
    cast(s.date1 as date) as settlement_date,
    wbg_mot.jurisdiction,
    wbg_mot.workspace_id,
    wbg_mot.workspace_number,
    case when wbg_mot.transaction_type in ('DM','WCDM') then 'Refinance'
        when wbg_mot.transaction_type like ('%T%') then 'Transfer'
        when wbg_mot.transaction_type in ('D','CD','WCD') then 'Standalone Discharge'
        when wbg_mot.transaction_type in ('M','CM','WCM') then 'Standalone Mortgage'
        else 'Other' end as transaction_type,
    workgroup,
    wbg_mot.express_refi_flag,
    wbg_mot.subscriber_id as mot_subscriber_id,
    wbg_mot.workspace_role as mot_workspace_role,
    wbg_mot.subscriber as mot_subscriber,
    mot_party.party AS mot_party,
    wbg_mot.reference as mot_reference,
    im_workspace_role,
    im_subscriber,
    im_party.party AS im_party,
    category_name AS "CATEGORY_NAME (IN FSS)",
    account_name,
    bsb,
    account_number,
    round(amount,2) as amount
FROM (select * from workspaces where workspace_role = 'MORTGAGEE_ON_TITLE') wbg_mot
LEFT JOIN (
    SELECT P.participant_id,
        P.workspace_id,
        P.subscriber_id AS im_subscriber_id,
        S.NAME AS im_subscriber,
        WR.NAME AS      im_workspace_role,
        TRIM(P.REFERENCE) AS im_reference
    FROM {{ source('exchange_share', 'vw_participants') }} P
            INNER JOIN {{ source('exchange_share', 'vw_subscribers') }} S ON S.subscriber_id = P.subscriber_id
            INNER JOIN {{ source('exchange_share', 'vw_workspace_roles') }} WR ON WR.workspace_role_id = P.workspace_role_id
    WHERE P.workspace_role_id = 5
        AND P.status = 'ACTIVE'
) other_im ON other_im.workspace_id = wbg_mot.workspace_id
LEFT JOIN (
    SELECT S.settlement_id,
        CAST(S.date1 AS DATE) AS settlement_date,
        sc.NAME AS category_name,
        A.holder AS account_name,
        A.bsb,
        A.number1 AS account_number,
        SUM(ss.amount)/100 AS amount
    FROM {{ source('exchange_share', 'vw_settlements') }} S
        INNER JOIN {{ source('exchange_share', 'vw_settlement_schedules') }} ss ON ss.settlement_id = S.settlement_id
        INNER JOIN {{ source('exchange_share', 'vw_settlement_categories') }} sc ON sc.settlement_category_id = ss.settlement_category_id
        INNER JOIN {{ source('exchange_share', 'vw_accounts') }} A ON ss.account_id = A.account_id
    WHERE ss.settlement_category_id IN (6)
    GROUP BY S.settlement_id,
        CAST(S.date1 AS DATE),
        sc.NAME,
        A.holder,
        A.bsb,
        A.number1
) ss ON ss.settlement_id = wbg_mot.settlement_id
LEFT JOIN parties mot_party ON mot_party.participant_id = wbg_mot.participant_id
LEFT JOIN parties im_party ON im_party.participant_id = other_im.participant_id
LEFT JOIN workgroups wg ON wg.workspace_id = wbg_mot.workspace_id AND wg.subscriber_id = wbg_mot.subscriber_id
LEFT JOIN {{ source('exchange_share', 'vw_settlements') }} s on s.settlement_id = wbg_mot.settlement_id
UNION ALL
-- RETURNS WBC AND SGB in IM
SELECT
    lodgement_date,
    cast(s.date1 as date) as settlement_date,
    wbg_im.jurisdiction,
    wbg_im.workspace_id,
    wbg_im.workspace_number,
    case when wbg_im.transaction_type in ('DM','WCDM') then 'Refinance'
        when wbg_im.transaction_type like ('%T%') then 'Transfer'
        when wbg_im.transaction_type in ('D','CD','WCD') then 'Standalone Discharge'
        when wbg_im.transaction_type in ('M','CM','WCM') then 'Standalone Mortgage'
        else 'Other' end as transaction_type,
    workgroup,
    wbg_im.express_refi_flag,
    NULL as mot_subscriber_id,
    mot_workspace_role,
    mot_subscriber,
    mot_party.party AS mot_party,
    NULL as mot_reference,
    wbg_im.workspace_role as im_workspace_role,
    wbg_im.subscriber as im_subscriber,
    im_party.party AS im_party,
    category_name AS "CATEGORY_NAME (IN FSS)",
    account_name,
    bsb,
    account_number,
    round(amount,2) as amount
FROM (select * from workspaces where workspace_role = 'INCOMING_MORTGAGEE') wbg_im
LEFT JOIN (
    SELECT P.participant_id,
        P.workspace_id,
        P.subscriber_id AS mot_subscriber_id,
        S.NAME AS mot_subscriber,
        WR.NAME AS mot_workspace_role,
        TRIM(P.REFERENCE) AS mot_reference
    FROM {{ source('exchange_share', 'vw_participants') }} P
            INNER JOIN {{ source('exchange_share', 'vw_subscribers') }} S ON S.subscriber_id = P.subscriber_id
            INNER JOIN {{ source('exchange_share', 'vw_workspace_roles') }} WR ON WR.workspace_role_id = P.workspace_role_id
    WHERE P.workspace_role_id = 1
        AND P.status = 'ACTIVE'
) other_mot ON other_mot.workspace_id = wbg_im.workspace_id
LEFT JOIN (
    SELECT S.settlement_id,
        CAST(S.date1 AS DATE) AS settlement_date,
        sc.NAME AS category_name,
        A.holder AS account_name,
        A.bsb,
        A.number1 AS account_number,
        SUM(ss.amount)/100 AS amount
    FROM {{ source('exchange_share', 'vw_settlements') }} S
        INNER JOIN {{ source('exchange_share', 'vw_settlement_schedules') }} ss ON ss.settlement_id = S.settlement_id
        INNER JOIN {{ source('exchange_share', 'vw_settlement_categories') }} sc ON sc.settlement_category_id = ss.settlement_category_id
        INNER JOIN {{ source('exchange_share', 'vw_accounts') }} A ON ss.account_id = A.account_id
    WHERE ss.settlement_category_id IN (1)
    GROUP BY S.settlement_id,
        CAST(S.date1 AS DATE),
        sc.NAME,
        A.holder,
        A.bsb,
        A.number1
) ss ON ss.settlement_id = wbg_im.settlement_id
LEFT JOIN parties mot_party ON mot_party.participant_id = other_mot.participant_id
LEFT JOIN parties im_party ON im_party.participant_id = wbg_im.participant_id
LEFT JOIN workgroups wg ON wg.workspace_id = wbg_im.workspace_id AND wg.subscriber_id = wbg_im.subscriber_id
LEFT JOIN {{ source('exchange_share', 'vw_settlements') }} s on s.settlement_id = wbg_im.settlement_id

