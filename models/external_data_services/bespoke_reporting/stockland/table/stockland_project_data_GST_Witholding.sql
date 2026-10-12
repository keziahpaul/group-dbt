{{
  config(
    materialized = 'incremental',
    incremental_strategy = 'append'
  )
}}

WITH stockland AS (
    SELECT DISTINCT
        p.workspace_id,
        p.reference
    FROM {{ source('exchange_share', 'vw_participants') }} p
    INNER JOIN {{ source('exchange_share', 'vw_subscribers') }} s
        ON s.subscriber_id = p.subscriber_id
    WHERE s.subscriber_id IN (
        23727, 23638, 22988, 22987, 22400,
        1412651, 1700340, 1730940, 2218092,
        2591412, 3018996
    )
),

gst_lineitem AS (
    SELECT
        workspace_id,
        LISTAGG(gst_lineitem, '; ')
            WITHIN GROUP (ORDER BY workspace_id,gst_lineitem) AS gst_lineitem
    FROM (
        SELECT
            s.workspace_id,
            CASE
                WHEN ss.settlement_category_id = 32 THEN 'MANUAL'
                WHEN ss.settlement_category_id = 41 THEN 'AUTO'
                ELSE NULL
            END AS gst_lineitem
        FROM stockland
        INNER JOIN {{ source('exchange_share', 'vw_settlements') }} s
            ON s.workspace_id = stockland.workspace_id
        INNER JOIN {{ source('exchange_share', 'vw_settlement_schedules') }} ss
            ON ss.settlement_id = s.settlement_id
           AND ss.settlement_category_id IN (32, 41)
        GROUP BY
            s.workspace_id,
            CASE
                WHEN ss.settlement_category_id = 32 THEN 'MANUAL'
                WHEN ss.settlement_category_id = 41 THEN 'AUTO'
                ELSE NULL
            END
    ) foo
    GROUP BY workspace_id
),

member AS (
    SELECT
        g.workspace_id,
        s.name AS subscriber,
        p.reference AS stockland_reference,
        s.subscriber_id,
        wr.name AS workspace_role,
        g.transfer_id,
        g.payment_reference,
        g.gst_data,
        g.form_type,
        g.document_status,
        g.verification_status,
        g.gst_withholding_amount
    FROM stockland
    INNER JOIN {{ source('exchange_share', 'vw_gst') }} g
        ON g.workspace_id = stockland.workspace_id
    INNER JOIN {{ source('exchange_share', 'vw_participants') }} p
        ON g.participant_id = p.participant_id
    INNER JOIN {{ source('exchange_share', 'vw_workspace_roles') }} wr
        ON p.workspace_role_id = wr.workspace_role_id
    INNER JOIN {{ source('exchange_share', 'vw_subscribers') }} s
        ON p.subscriber_id = s.subscriber_id
),
 source as
(SELECT
    stockland.reference AS stockland_reference,
    'a' || t1.payment_reference AS prn,
     TO_JSON(
        PARSE_JSON(t1.gst_data):vendors[0].abn
    ) AS vendor_abn,
    t1.document_status AS form1_status,
    t1.gst_withholding_amount,
    t2.document_status AS form2_status,
    gl.gst_lineitem

FROM stockland
INNER JOIN {{ source('exchange_share', 'vw_workspaces') }} w
    ON stockland.workspace_id = w.workspace_id
INNER JOIN member t1
    ON stockland.workspace_id = t1.workspace_id
   AND t1.form_type = 'GST_FORM_1'
LEFT JOIN member t2
    ON stockland.workspace_id = t2.workspace_id
   AND t2.form_type = 'GST_FORM_2'
LEFT JOIN gst_lineitem gl
    ON gl.workspace_id = stockland.workspace_id
)
select distinct stockland_reference,
    prn,
    vendor_abn,
    form1_status,
    gst_withholding_amount,
    form2_status,
    gst_lineitem,
   HASH(
        stockland_reference,prn,vendor_abn,form1_status,gst_withholding_amount,form2_status,gst_lineitem
    ) AS hash,
    {{ var('inserted_at') }} AS inserted_at,
    {{ var('updated_at') }} AS updated_at
FROM source
{%- if is_incremental() %}
WHERE HASH(
        stockland_reference,prn,vendor_abn,form1_status,gst_withholding_amount,form2_status,gst_lineitem
    )
 NOT IN (SELECT hash FROM {{ this }})
{%- endif %}


