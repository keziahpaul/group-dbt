{{
  config(
    materialized = 'incremental',
    incremental_strategy = 'append'
  )
}}

WITH stockland AS (
    SELECT
        s.subscriber_id,
        s.name AS subscriber_name,
        p.workspace_id,
        p.pexa_projects_id,
        TRIM(p.reference) AS reference
    FROM {{ source('exchange_share', 'vw_subscribers') }} s
    INNER JOIN {{ source('exchange_share', 'vw_participants') }} p
        ON p.subscriber_id = s.subscriber_id
    WHERE s.name LIKE 'STOCKLAND %'
       OR s.subscriber_id IN (1412651, 1700340, 1730940, 2218092, 2591412, 3018996)
),

invitations AS (
    SELECT
        i.invitation_id AS Invitation_ID,
        i.workspace_id AS Workspace_ID,
        i.status AS Status,
        i.from_subscriber_id AS Sender_SubID,
        i.to_subscriber_id AS Receiver_SubID,
        inv_to.name AS Receiver,
        i.workspace_role_id,
        ROW_NUMBER() OVER (
            PARTITION BY i.workspace_id, i.to_subscriber_id
            ORDER BY i.invitation_id DESC
        ) AS COUNTER
    FROM {{ source('exchange_share', 'vw_invitations') }} i
    LEFT JOIN {{ source('exchange_share', 'vw_subscribers') }} inv_to
        ON inv_to.subscriber_id = i.to_subscriber_id
    WHERE i.workspace_id IN (SELECT workspace_id FROM stockland)
),

IP_Invite_Grouped AS (
    SELECT
        inv1.workspace_id,
        inv1.status AS IP_Invite_Status,
        inv1.Receiver_SubID,
        ip.settle_acceptance_status
    FROM invitations inv1
    LEFT JOIN {{ source('exchange_share', 'vw_participants') }} ip
        ON ip.workspace_id = inv1.workspace_id
        AND inv1.Receiver_SubID = ip.subscriber_id
        AND ip.workspace_role_id = 2
        AND ip.status = 'ACTIVE'
    WHERE inv1.workspace_role_id = 2
      AND inv1.COUNTER = 1
),

IM_Invite_Grouped AS (
    SELECT
        inv2.workspace_id,
        inv2.status AS IM_Invite_Status,
        inv2.Receiver_SubID,
        im.settle_acceptance_status
    FROM invitations inv2
    LEFT JOIN {{ source('exchange_share', 'vw_participants') }} im
        ON im.workspace_id = inv2.workspace_id
        AND inv2.Receiver_SubID = im.subscriber_id
        AND im.workspace_role_id = 5
        AND im.status = 'ACTIVE'
    WHERE inv2.workspace_role_id = 5
      AND inv2.COUNTER = 1
),

POT_Invite_Grouped AS (
    SELECT
        w.workspace_id,
        w.number1,
        pot.settle_acceptance_status
    FROM {{ source('exchange_share', 'vw_workspaces') }} w
    LEFT JOIN {{ source('exchange_share', 'vw_participants') }} pot
        ON pot.workspace_id = w.workspace_id
        AND pot.workspace_role_id = 4
        AND pot.status = 'ACTIVE'
),

workings AS (
    SELECT
        w.number1 AS WorkspaceID,
        stockland.reference AS SubscriberReference,
        w.status AS WorkspaceStatus,
        l.status AS LodgementStatus,
        s.status AS FinancialSettlementStatus,
        TO_DATE(TO_CHAR(s.date1, 'DD/MM/YYYY'), 'DD/MM/YYYY') AS SettlementDate,
        TO_CHAR(s.date1, 'HH12:MIAM') AS SettlementTimeAEST,
        ipg.Receiver_SubID AS IPSubscriberID,
        ipg.IP_Invite_Status AS IPInvitationStatus,
        CASE
            WHEN ipg.settle_acceptance_status IS NOT NULL AND s.date1 IS NULL THEN 'PENDING'
            ELSE ipg.settle_acceptance_status
        END AS IPSettlementBookingStatus,
        img.Receiver_SubID AS IMSubscriberID,
        img.IM_Invite_Status AS IMInvitationStatus,
        CASE
            WHEN img.settle_acceptance_status IS NOT NULL AND s.date1 IS NULL THEN 'PENDING'
            ELSE img.settle_acceptance_status
        END AS IMSettlementBookingStatus,
        CASE
            WHEN s.date1 IS NULL THEN 'PENDING'
            ELSE pot.settle_acceptance_status
        END AS POTSettlementBookingStatus,
        ss.VendorFunds,
        stockland.pexa_projects_id AS PexaProjectID
    FROM stockland
    INNER JOIN {{ source('exchange_share', 'vw_workspaces') }} w
        ON stockland.workspace_id = w.workspace_id
    LEFT JOIN (
        SELECT
            l.workspace_id,
            l.status,
            l.transaction_type
        FROM {{ source('exchange_share', 'vw_lodgements') }} l
        INNER JOIN {{ source('exchange_share', 'vw_documents') }} d
            ON d.lodgement_id = l.lodgement_id
        WHERE d.document_type_id NOT IN (3, 4)
    ) l
        ON l.workspace_id = w.workspace_id
    LEFT JOIN {{ source('exchange_share', 'vw_settlements') }} s
        ON s.workspace_id = w.workspace_id
    LEFT JOIN IP_Invite_Grouped ipg
        ON ipg.workspace_id = w.workspace_id
    LEFT JOIN IM_Invite_Grouped img
        ON img.workspace_id = w.workspace_id
    LEFT JOIN POT_Invite_Grouped pot
        ON pot.workspace_id = w.workspace_id
    LEFT JOIN (
        SELECT
            ss.settlement_id,
            SUM(CASE WHEN ss.amount IS NULL THEN NULL ELSE ss.amount END) / 100 AS VendorFunds
        FROM {{ source('exchange_share', 'vw_settlement_schedules') }} ss
        WHERE ss.settlement_category_id = 7
        GROUP BY ss.settlement_id
    ) ss
        ON ss.settlement_id = s.settlement_id
    WHERE (l.transaction_type IN ('WCTM', 'DT', 'WCT', 'T', 'WCDT', 'TM', 'DTM', 'WCDTM') OR l.transaction_type IS NULL)
)

, source_records AS (
    SELECT DISTINCT
        WorkspaceID,
        SubscriberReference,
        WorkspaceStatus,
        LodgementStatus,
        FinancialSettlementStatus,
        TO_CHAR(SettlementDate, 'DD/MM/YYYY') AS SettlementDate,
        SettlementTimeAEST,
        CASE
            WHEN SettlementDate IS NULL THEN 'PENDING'
            WHEN IPSettlementBookingStatus = 'PENDING' OR IMSettlementBookingStatus = 'PENDING' OR POTSettlementBookingStatus = 'PENDING' THEN 'PENDING'
            WHEN IPSettlementBookingStatus = 'ACCEPTED' AND POTSettlementBookingStatus = 'ACCEPTED' AND SettlementDate IS NOT NULL THEN 'ACCEPTED'
            WHEN IMSettlementBookingStatus = 'ACCEPTED' AND POTSettlementBookingStatus = 'ACCEPTED' AND SettlementDate IS NOT NULL THEN 'ACCEPTED'
            WHEN IPSettlementBookingStatus = 'ACCEPTED' AND IMSettlementBookingStatus = 'ACCEPTED' AND POTSettlementBookingStatus = 'ACCEPTED' AND SettlementDate IS NOT NULL THEN 'ACCEPTED'
            ELSE 'PENDING'
        END AS SettlementBookingStatus,
        IPSubscriberID,
        IPInvitationStatus,
        IPSettlementBookingStatus,
        IMSubscriberID,
        IMInvitationStatus,
        IMSettlementBookingStatus,
        VendorFunds,
        POTSettlementBookingStatus,
        PexaProjectID
    FROM workings
)

SELECT
    s.WorkspaceID,
    s.SubscriberReference,
    s.WorkspaceStatus,
    s.LodgementStatus,
    s.FinancialSettlementStatus,
    s.SettlementDate,
    s.SettlementTimeAEST,
    s.SettlementBookingStatus,
    s.IPSubscriberID,
    s.IPInvitationStatus,
    s.IPSettlementBookingStatus,
    s.IMSubscriberID,
    s.IMInvitationStatus,
    s.IMSettlementBookingStatus,
    s.VendorFunds,
    s.POTSettlementBookingStatus,
    s.PexaProjectID,
    HASH(
        s.WorkspaceID, s.SubscriberReference, s.WorkspaceStatus, s.LodgementStatus,
        s.FinancialSettlementStatus, s.SettlementDate, s.SettlementTimeAEST,
        s.SettlementBookingStatus, s.IPSubscriberID, s.IPInvitationStatus,
        s.IPSettlementBookingStatus, s.IMSubscriberID, s.IMInvitationStatus,
        s.IMSettlementBookingStatus, s.VendorFunds, s.POTSettlementBookingStatus,
        s.PexaProjectID
    ) AS hash,
    {{ var('inserted_at') }} AS inserted_at,
    {{ var('updated_at') }} AS updated_at
FROM source_records s
{%- if is_incremental() %}
WHERE HASH(
    s.WorkspaceID, s.SubscriberReference, s.WorkspaceStatus, s.LodgementStatus,
    s.FinancialSettlementStatus, s.SettlementDate, s.SettlementTimeAEST,
    s.SettlementBookingStatus, s.IPSubscriberID, s.IPInvitationStatus,
    s.IPSettlementBookingStatus, s.IMSubscriberID, s.IMInvitationStatus,
    s.IMSettlementBookingStatus, s.VendorFunds, s.POTSettlementBookingStatus,
    s.PexaProjectID
) NOT IN (SELECT hash FROM {{ this }})
{%- endif %}
