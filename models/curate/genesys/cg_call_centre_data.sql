{{
  config(
    materialized = 'incremental',
    unique_key = ['queue_id', 'interval_start']
    )
}}

WITH queue_data AS (
    SELECT
        queue_id,
        queue_name,
        created_date AS interval_start,
        created_date + interval '1 day' AS interval_end,
        FALSE AS interval_complete,
        media_type,
        '' AS filters,
        NULLIFZERO(noffered_count) AS offer,
        NULLIFZERO(tAnswered_count) AS answer,
        NULLIFZERO(tAnswered_count / NULLIFZERO(nOffered_count))::float AS answer_prc,
        NULLIFZERO(nTransferred_count) AS transfer,
        NULLIFZERO(tAbandon_count) AS abandon,
        NULLIFZERO(tAbandon_count / NULLIFZERO(nOffered_count))::float AS abandon_prc,
        NULLIFZERO(tAnswered_sum / NULLIFZERO(tAnswered_count) / 1000)::number(38,3) AS asa,
        NULLIFZERO(tAbandon_sum / NULLIFZERO(tAbandon_count) / 1000)::number(38,3) AS avg_abandon,
        NULLIFZERO(tAcw_sum / NULLIFZERO(tAcw_count) / 1000)::number(38,3) AS avg_acw,
        NULLIFZERO(tHandle_sum / NULLIFZERO(tHandle_count) / 1000)::number(38,3) AS avg_handle,
        NULLIFZERO(tHeldComplete_sum / NULLIFZERO(tHeldComplete_count) / 1000)::number(38,3) AS avg_hold,
        NULLIFZERO(tTalkComplete_sum / NULLIFZERO(tTalkComplete_count) / 1000)::number(38,3) AS avg_talk,
        NULLIFZERO(tWait_sum / NULLIFZERO(tWait_count) / 1000)::number(38,3) AS avg_wait,
        NULLIFZERO(tAbandon_max / 1000)::number(38,3) AS max_abandon,
        NULLIFZERO(tWait_max / 1000)::number(38,3) AS max_wait,
        NULLIFZERO(tAcw_sum / 1000)::number(38,3) AS total_acw,
        NULLIFZERO(tHeldComplete_sum / 1000)::number(38,3) AS total_hold,
        NULLIFZERO(tTalkComplete_sum / 1000)::number(38,3) AS total_talk,
        NULLIFZERO(oservicelevel_target)::number(5, 4) AS service_level_target_prc,
        NULLIFZERO(oservicelevel_ratio)::float AS service_level_prc,
        NULLIFZERO(noversla_count) AS over_sla
    FROM {{ ref('cg_queue_aggregate') }}
    WHERE media_type = 'voice'
      AND queue_name IN ('ACT', 'NSW', 'Victoria', 'QLD', 'SA', 'Other', 'WA', 'Tasmania')
    {%- if is_incremental() %}
      AND created_date > COALESCE((SELECT MAX(interval_start) FROM {{ this }}), '1900-01-01')
    {%- endif %}
),
global_data AS (
    SELECT
        '' AS queue_id,
        '' AS queue_name,
        created_date AS interval_start,
        created_date + interval '1 day' AS interval_end,
        FALSE AS interval_complete,
        '' AS media_type,
        '' AS filters,
        NULLIFZERO(noffered_count) AS offer,
        NULLIFZERO(tAnswered_count) AS answer,
        NULLIFZERO(tAnswered_count / NULLIFZERO(nOffered_count))::float AS answer_prc,
        NULLIFZERO(nTransferred_count) AS transfer,
        NULLIFZERO(tAbandon_count) AS abandon,
        NULLIFZERO(tAbandon_count / NULLIFZERO(nOffered_count))::float AS abandon_prc,
        NULLIFZERO(tAnswered_sum / NULLIFZERO(tAnswered_count) / 1000)::number(38,3) AS asa,
        NULLIFZERO(tAbandon_sum / NULLIFZERO(tAbandon_count) / 1000)::number(38,3) AS avg_abandon,
        NULLIFZERO(tAcw_sum / NULLIFZERO(tAcw_count) / 1000)::number(38,3) AS avg_acw,
        NULLIFZERO(tHandle_sum / NULLIFZERO(tHandle_count) / 1000)::number(38,3) AS avg_handle,
        NULLIFZERO(tHeldComplete_sum / NULLIFZERO(tHeldComplete_count) / 1000)::number(38,3) AS avg_hold,
        NULLIFZERO(tTalkComplete_sum / NULLIFZERO(tTalkComplete_count) / 1000)::number(38,3) AS avg_talk,
        NULLIFZERO(tWait_sum / NULLIFZERO(tWait_count) / 1000)::number(38,3) AS avg_wait,
        NULLIFZERO(tAbandon_max / 1000)::number(38,3) AS max_abandon,
        NULLIFZERO(tWait_max / 1000)::number(38,3) AS max_wait,
        NULLIFZERO(tAcw_sum / 1000)::number(38,3) AS total_acw,
        NULLIFZERO(tHeldComplete_sum / 1000)::number(38,3) AS total_hold,
        NULLIFZERO(tTalkComplete_sum / 1000)::number(38,3) AS total_talk,
        NULLIFZERO(oservicelevel_target)::number(5, 4) AS service_level_target_prc,
        NULLIFZERO(oservicelevel_ratio)::float AS service_level_prc,
        NULLIFZERO(noversla_count) AS over_sla
    FROM {{ ref('cg_global_queue_aggregate') }}
    WHERE media_type = 'voice'
      AND created_date IN (SELECT DISTINCT interval_start FROM queue_data)
    {%- if is_incremental() %}
      AND created_date > COALESCE((SELECT MAX(interval_start) FROM {{ this }}), '1900-01-01')
    {%- endif %}
)
SELECT * FROM queue_data
UNION ALL
SELECT * FROM global_data
