SELECT
    c.id                       AS case_id,                   {#- string #}
    c.account_id               AS account_id,                {#- string #}
    c.case_number              AS case_number,               {#- string #}
    c.subject                  AS subject,                   {#- string #}
    c.parent_id                AS parent_case_id,            {#- string #}
    c.owner_id                 AS owner_id,                  {#- string #}
    c.type                     AS case_record_type,          {#- string #}
    c.origin                   AS case_origin,               {#- string #}
    c.created_date             AS created_date,              {#- timestamp_tz #}
    c.sub_category_c           AS sub_category,              {#- string #}
    c.sub_sub_category_c       AS sub_sub_category,          {#- string #}
    c.first_call_resolution_c  AS first_call_resolution,     {#- string #}
    c.record_type_id           AS case_type_id,              {#- string #}
    cl.label                   AS case_type_name,            {#- string #}
    c.closed_date              AS closed_date,               {#- timestamp_tz #}
    c.description              AS description,               {#- string #}
    c.reason                   AS case_reason,               {#- string #}
    c.status                   AS case_status,               {#- string #}
    t.id                       AS task_id,                   {#- string #}
    t.record_type_id           AS task_type_id,              {#- string #}
    tl.label                   AS task_type_name,            {#- string #}
    t.subject                  AS task_subject,              {#- string #}
    t.activity_date            AS task_activity_date,        {#- date #}
    t.call_object              AS call_object_id,            {#- string #}
    t.call_duration_in_seconds AS call_duration_in_seconds,  {#- number #}
    t.call_type                AS call_type,                 {#- string #}
    t.completed_date_time      AS completed_date_time,       {#- timestamp_tz #}
    t.description              AS task_description,          {#- string #}
    t.is_closed                AS is_closed,                 {#- boolean #}
    t.is_high_priority         AS is_high_priority,          {#- boolean #}
    t.status                   AS task_status,               {#- string #}
    t.task_subtype             AS task_subtype               {#- string #}
FROM {{ ref('vw_case') }} c
JOIN {{ ref('vw_task') }} t ON t.what_id = c.id
LEFT JOIN {{ ref('e_case_lookup') }} cl ON cl.id = c.record_type_id
LEFT JOIN {{ ref('e_task_lookup') }} tl ON tl.id = t.record_type_id
WHERE c.case_owner_name_c <> 'Spam'
