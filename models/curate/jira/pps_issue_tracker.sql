{{
  config(
    materialized = 'incremental',
    unique_key = 'issue_id'
  )
}}
with latest_snapshot as (
    select
        i.id,
        max(i.updated_at) as last_inserted_at
    FROM {{ref('cj_issues')}} i
    JOIN {{ref('cj_projects')}} p ON i.project_id = p.id
    where p.key = 'PPS'
    {%- if is_incremental() %}
      and i.updated_at > (select max(updated_at) from {{ this }})
    {%- endif %}
    group by 1
),
parents as (
    select i.parent_issue_id, max(pi.updated_at) as updated_at
    from latest_snapshot l
    join {{ref('cj_issues')}} i on l.id = i.id
    join {{ref('cj_issues')}} pi on i.parent_issue_id = pi.id
    where i.parent_issue_id is not null
    group by 1
)
select
    v.id as issue_id,
    it.name as issuetype_name,
    v.subtasks,
    v.created,
    v.updated,
    v.resolutiondate,
    v.key,
    s.name as status_name,
    
    pv.id as parent_id,
    pv.key as parent_key,
    pv.summary as parent_summary,
    pv.issuetype_id as parent_issuetype_id,
    pv.priority_id as parent_priority_id,
    pv.status_id as parent_status_id,
    pv.statuscategory_id as parent_statuscategory_id,

    l.last_inserted_at as updated_at
FROM {{ ref('cj_issues') }} v
inner join latest_snapshot as l on v.id = l.id and v.updated_at = l.last_inserted_at
join {{ ref('cj_issuetypes') }} as it on v.issuetype_id = it.id
join {{ ref('cj_statuses') }} as s on v.status_id = s.id
left join parents p on v.parent_issue_id = p.parent_issue_id
left join {{ ref('cj_issues') }} pv on p.parent_issue_id = pv.id and p.updated_at = pv.updated_at
