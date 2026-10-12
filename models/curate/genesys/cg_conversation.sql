{{
  config(
    materialized = 'incremental',
    unique_key = 'conversation_id',
    )
}}
WITH src AS (
    SELECT
        FILTER(payload:participants, a -> a:purpose IN ('customer', 'external', 'agent', 'user'))[0]:sessions[0]:mediaType::string AS media_type,
        TRANSFORM(FILTER(payload:participants, a -> a:purpose IN ('agent', 'user')), a VARIANT -> a:userId) AS users,
        FILTER(payload:participants, a -> a:purpose IN ('customer', 'external', 'voicemail'))[0]:participantName::string AS remote,
        CONVERT_TIMEZONE('Australia/Melbourne', TO_TIMESTAMP_TZ(payload:conversationStart)) AS date,
        (to_timestamp_tz(payload:conversationEnd) - TO_TIMESTAMP_TZ(payload:conversationStart))::number(38,3) AS duration,
        payload:originatingDirection::string AS direction,
        ARRAY_COMPACT(TRANSFORM(FILTER(payload:participants, a -> a:purpose IN ('agent', 'user')), a -> FILTER(a:sessions[0]:segments, s -> s:segmentType = 'wrapup')[0]:queueId))[0]::string AS queue_id,
        -- only take the first found code
        ARRAY_COMPACT(TRANSFORM(FILTER(payload:participants, a -> a:purpose IN ('agent', 'user')), a -> FILTER(a:sessions[0]:segments, s -> s:segmentType = 'wrapup')[0]:wrapUpCode))[0]::string as wrap_up,
        id AS conversation_id,
        (REDUCE(FILTER(payload:participants, p -> p:purpose IN ('agent', 'user')), 0, (r, a) -> r + COALESCE(FILTER(a:sessions[0]:metrics, m -> m:name = 'tTalkComplete')[0]:value::number, 0)) / 1000)::number(38,3) AS total_talk,
        (REDUCE(FILTER(payload:participants, p -> p:purpose IN ('agent', 'user')), 0, (r, a) -> r + COALESCE(FILTER(a:sessions[0]:metrics, m -> m:name = 'tHeldComplete')[0]:value::number, 0)) / 1000)::number(38,3) AS total_hold,
        (REDUCE(FILTER(payload:participants, p -> p:purpose IN ('agent', 'user')), 0, (r, a) -> r + COALESCE(FILTER(a:sessions[0]:metrics, m -> m:name = 'tAcw')[0]:value::number, 0)) / 1000)::number(38,3) AS total_acw,
        (REDUCE(FILTER(payload:participants, p -> p:purpose IN ('agent', 'user')), 0, (r, a) -> r + COALESCE(FILTER(a:sessions[0]:metrics, m -> m:name = 'tHandle')[0]:value::number, 0)) / 1000)::number(38,3) AS total_handle,
        -- only take the first found note
        COALESCE(ARRAY_COMPACT(TRANSFORM(FILTER(payload:participants, a -> a:purpose IN ('agent', 'user')), a -> FILTER(a:sessions[0]:segments, s -> s:segmentType = 'wrapup')[0]:wrapUpNote))[0]::string, 'NO') AS wrap_up_notes,
        extracted
    FROM {{ ref("conversation") }}
    {%- if is_incremental() %}
    WHERE extracted > COALESCE((SELECT MAX(extracted) from {{ this }}), '1900-01-01')
    {%- endif %}
    QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY extracted DESC) = 1
),
user_ids AS (
    SELECT
        src.conversation_id,
        f.value::string AS user_id
    FROM src, LATERAL FLATTEN(INPUT => users) f
),
users AS (
    SELECT
        f.conversation_id,
        LISTAGG(DISTINCT COALESCE(u.payload:name, f.user_id), '; ') WITHIN GROUP ( ORDER BY COALESCE(u.payload:name, f.user_id)) AS users
    FROM user_ids f
    LEFT JOIN {{ ref("rg_user") }} u ON u.id = f.user_id
    GROUP BY f.conversation_id
)
SELECT
    src.media_type,
    users.users,
    src.remote,
    src.date,
    src.duration,
    src.direction,
    q.payload:name::string AS queue_name,
    COALESCE(w.payload:name, src.wrap_up) AS wrap_up,
    src.conversation_id,
    src.total_talk,
    src.total_hold,
    src.total_acw,
    src.total_handle,
    src.wrap_up_notes,

    src.extracted
FROM src
LEFT JOIN {{ ref("queue") }} q ON q.id = src.queue_id
LEFT JOIN users ON src.conversation_id = users.conversation_id
LEFT JOIN {{ ref("wrap_up_code") }} w ON w.id = src.wrap_up
