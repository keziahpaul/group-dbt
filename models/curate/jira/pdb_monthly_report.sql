{{
  config(
    materialized = 'incremental',
    unique_key = ['report_month'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['report_month']
    )
}}
SELECT
    report_month,
    sum(iff(fields_created >= report_month, 1, 0)) AS new_defects,
    sum(iff(fields_resolutiondate >= report_month AND fields_status_name in ('Closed', 'Resolved'), 1, 0)) AS resolved,
    sum(iff(latest_dormant >= report_month AND fields_status_name = 'Dormant', 1, 0)) AS dormant,
    sum(iff(updated >= report_month AND fields_reactivated_flag, 1, 0)) AS reactivated,
    sum(iff(fields_status_name NOT in ('Closed', 'Resolved', 'Dormant', 'Done'), 1, 0)) AS backlog,
    sum(iff(updated >= report_month, 1, 0)) AS issues_updated
FROM {{ref('pdb_issue_tracker')}}
WHERE fields_issuetype_name = 'Defect'
{%- if is_incremental() %}
  AND report_month >= (SELECT max(report_month) FROM {{ this }})
{% endif -%}
GROUP BY 1
ORDER BY 1