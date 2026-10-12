{{
  config(
    materialized = 'incremental',
    unique_key = ['issue_id', 'report_month'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['issue_id', 'report_month']
    )
}}
WITH the_month AS (
    SELECT first_day, first_day + INTERVAL '1 month' AS after_last_day
    FROM (
{%- if is_incremental() %}
        SELECT
            date_trunc('month', current_date())
        UNION ALL
        SELECT
            date_trunc('month', current_date()) - INTERVAL '1 month'
{%- else %}
{{ dbt_utils.date_spine(
    datepart="month",
    start_date="cast('2025-01-01' as date)",
    end_date="(date_trunc('month', current_date()) + interval '1 month')"
   )
}}
{% endif -%}
    ) t(first_day)
),
latest_monthly_snapshot AS (
    SELECT
        m.first_day AS report_month,
        i.id,
        max(i.updated_at) AS updated_at, -- latest extract from JIRA
        min(i.created) AS created,       -- issue create date
        max(i.updated) AS updated,       -- issue update date
        max(CASE WHEN i.status_id = '10249' THEN i.updated END) AS latest_dormant,  -- 'Dormant'
        max(CASE WHEN i.status_id = '10249' AND i.updated < m.first_day THEN i.updated END) AS previous_dormant, -- 'Prev Mth Dormant'
        max(CASE WHEN i.status_id = '10061' THEN i.updated END) AS latest_assigned, -- 'Assigned'
        max(CASE WHEN i.status_id = '10061' AND i.updated < m.first_day THEN i.updated END) AS previous_assigned -- 'Prev Mth Assigned'
    FROM {{ref('cj_issues')}} i
    , the_month m
    WHERE i.updated < m.after_last_day
    GROUP BY 1, 2
)
SELECT
    l.report_month,
    v.id AS issue_id,
    v.key,
    u.displayname AS fields_assignee,
    v.created AS fields_created,
    v.customfields:customfield_10049::STRING AS fields_customfield_10049, -- Resolution Details
    v.customfields:customfield_10110::STRING AS fields_customfield_10110, -- External Responses
    v.customfields:customfield_10111::STRING AS fields_customfield_10111, -- Externally Raised Change?
    v.customfields:customfield_10113::STRING AS fields_customfield_10113, -- External CR Number
    v.customfields:customfield_10115::STRING AS fields_customfield_10115, -- External Proposed Priority
    v.customfields:customfield_10236::STRING AS fields_customfield_10236, -- Target Resolution Date
    v.customfields:customfield_10260::STRING AS fields_customfield_10260, -- Incidents
    v.customfields:customfield_11358::STRING AS fields_customfield_11358, -- Time to resolution
    v.customfields:customfield_11405::STRING AS fields_customfield_11405, -- Time to close after resolution
    to_date(v.customfields:customfield_10850::STRING, 'YYYY-MM-DD') AS fields_customfield_10850, -- Last Occurrence
    t.name AS fields_issuetype_name,
    r.name AS fields_resolution,
    v.resolutiondate AS fields_resolutiondate,
    s.name AS fields_status_name,
    v.customfields:customfield_10037:value::string AS severity, -- Severity
    COALESCE(l.previous_dormant, l.latest_dormant) AS latest_dormant,
    l.latest_assigned,
    l.latest_dormant IS NOT NULL AND l.latest_assigned IS NOT NULL AND l.latest_dormant < l.latest_assigned AND (l.previous_assigned IS NULL OR l.previous_assigned < l.latest_dormant) AS fields_reactivated_flag,
    v.updated
FROM {{ref('cj_issues')}} v
INNER JOIN latest_monthly_snapshot AS l ON v.id = l.id AND v.updated_at = l.updated_at AND v.updated = l.updated
INNER JOIN {{ref('cj_projects')}} p ON v.project_id = p.id
INNER JOIN {{ref('cj_issuetypes')}} t ON v.issuetype_id = t.id
INNER JOIN {{ref('cj_statuses')}} s ON v.status_id = s.id
LEFT JOIN {{ref('cj_resolutions')}} r ON v.resolution_id = r.id
LEFT JOIN {{ref('cj_users')}} u ON v.assignee_user_id = u.id
WHERE p.key = 'PDB'
{%- if is_incremental() %}
  AND v.updated >= (SELECT max(updated) FROM {{this}})
{%- endif %}
ORDER BY l.report_month, v.id