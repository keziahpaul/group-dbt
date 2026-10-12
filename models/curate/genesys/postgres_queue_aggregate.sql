{{
  config(
    materialized = 'incremental',
    unique_key = 'key'
    )
}}
{#- This is for "voice" queues only. If you need to add more queues or media types, you
    will need to adjust the CTE and WHERE clauses accordingly and run a --full-refresh
 -#}

WITH state_queue_abbrev AS (
    SELECT queue_name, key_text
    FROM ( 
        VALUES
        ('ACT', 'ACT'),
        ('NSW', 'NSW'),
        ('NT', 'NT'),
        ('Other', 'other'),
        ('QLD', 'QLD'),
        ('SA', 'SA'),
        ('Tasmania', 'TAS'),
        ('Victoria', 'VIC'),
        ('WA', 'WA')
    ) AS v(queue_name, key_text)
)
SELECT
    CONCAT(sqa.key_text, TO_VARCHAR(aqi.created_date, 'yyyymmdd')) AS key,
    aqi.created_date,
    aqi.queue_name,
    aqi.nOffered_count AS total_interactions_received,
    aqi.tAnswered_count AS total_interactions_answered,
    aqi.tAbandon_count AS total_interactions_abandoned,
    aqi.oServiceLevel_ratio AS service_level,
    aqi.nOverSla_count AS interactions_over_sla,
    COALESCE(aqi.tAbandon_sum / NULLIFZERO(aqi.tAbandon_count) / 1000, 0)::number AS avg_abandon_time_sec,
    COALESCE(aqi.tAcw_sum / NULLIFZERO(aqi.tAcw_count) / 1000, 0)::number AS avg_post_call_work_time_sec,
    COALESCE(aqi.tHandle_sum / NULLIFZERO(aqi.tHandle_count) / 1000, 0)::number AS avg_handle_time_sec,
    COALESCE(aqi.tWait_sum / NULLIFZERO(aqi.tWait_count) / 1000, 0)::number AS avg_queue_wait_time_sec,
    COALESCE(aqi.tTalkComplete_sum / NULLIFZERO(aqi.tTalkComplete_count) / 1000, 0)::number AS avg_talk_time_sec,
    avg_queue_wait_time_sec AS avg_wait_sec,
    aqi.nTransferred_count AS interactions_transferred,
    (aqi.tAbandon_max / 1000)::number AS longest_abandon_time_sec,
    (aqi.tWait_max / 1000)::number AS longest_wait_time_sec,
    IFF(aqi.nOffered_count = 0, 0, (aqi.tAbandon_count / aqi.nOffered_count))::number(38,4) AS interactions_abandoned,
    IFF(aqi.nOffered_count = 0, 0, (aqi.tAnswered_count / aqi.nOffered_count))::number(38,4) AS interactions_answered,
    (aqi.tWait_sum / 1000)::number AS queue_wait_time_sec,
    (aqi.tAbandon_sum / 1000)::number AS total_abandon_time_sec,
    (aqi.tAcw_sum / 1000)::number AS total_post_call_work_time_sec,
    (aqi.tHandle_sum / 1000)::number AS total_handle_time_sec,
    aqi.nOutbound_count AS total_outbound,
    aqi.tTalkComplete_count AS total_talk_complete,
    (aqi.tTalkComplete_sum / 1000)::number AS total_talk_time_sec,
    queue_wait_time_sec AS total_wait_sec
FROM {{ ref('cg_queue_aggregate') }} aqi
JOIN state_queue_abbrev AS sqa ON aqi.queue_name = sqa.queue_name
WHERE aqi.media_type = 'voice'
{%- if is_incremental() %}
  AND aqi.created_date > COALESCE((SELECT MAX(created_date) FROM {{ this }}), '1900-01-01')
{%- endif %}
