{{
  config(
    materialized = 'incremental',
    unique_key = 'issue_id'
    )
}}
with latest_snapshot as (
    select
        i.id,
        min(i.extracted) as first_inserted_at,
        max(i.extracted) as last_inserted_at
    from {{ ref('vw_issues_new') }} i
    join {{ ref('vw_projects') }} p on i.project = p.id
    where p.key = 'PPS'
    group by 1
    {%- if is_incremental() %}
    having last_inserted_at = (select max(extracted) from {{ ref('vw_issues_new') }})
    {%- endif %}
)
select
    v.id as issue_id,
    v.issuetype:name::string as issuetype_name,
    v.subtasks,
    v.created,
    v.resolutiondate,
    v.key,
    v.status:name::STRING as status_name,
    l.last_inserted_at as "updated_at",
    l.first_inserted_at as "inserted_at"
FROM {{ ref('vw_issues_new') }} v
inner join latest_snapshot as l on v.id = l.id and v.extracted = l.last_inserted_at
