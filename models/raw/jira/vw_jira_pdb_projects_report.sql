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
        max(i.extracted) as last_inserted_at,
        max(case when i.status:id = '10249' then i.extracted end) as latest_dormant, -- 'Dormant'
        max(case when i.status:id = '10061' then i.extracted end) as latest_assigned -- 'Assigned'
    from {{ ref('vw_issues_new') }} i
    join {{ ref('vw_projects') }} p on i.project = p.id
    where p.key = 'PDB'
    group by 1
    {%- if is_incremental() %}
    having last_inserted_at = (select max(extracted) from {{ ref('vw_issues_new') }})
    {%- endif %}
)
select
    v.id as issue_id,
    v.key::STRING as key,
    v.assignee as fields_assignee,
    v.created::TIMESTAMP as fields_created,
    v.customfields:customfield_10049::STRING as fields_customfield_10049, -- Resolution Details
    v.customfields:customfield_10110::STRING as fields_customfield_10110, -- External Responses
    v.customfields:customfield_10111::STRING as fields_customfield_10111, -- Externally Raised Change?
    v.customfields:customfield_10113::STRING as fields_customfield_10113, -- External CR Number
    v.customfields:customfield_10115::STRING as fields_customfield_10115, -- External Proposed Priority
    v.customfields:customfield_10236::STRING as fields_customfield_10236, -- Target Resolution Date
    v.customfields:customfield_10260::STRING as fields_customfield_10260, -- Incidents
    v.customfields:customfield_11358::STRING as fields_customfield_11358, -- Time to resolution
    v.customfields:customfield_11405::STRING as fields_customfield_11405, -- Time to close after resolution
    v.issuetype:name::STRING as fields_issuetype_name,
    v.resolution::STRING as fields_resolution,
    v.resolutiondate::TIMESTAMP as fields_resolutiondate,
    v.status:name::STRING as fields_status_name,
    v.customfields:customfield_10037:value::string as severity,  -- Severity
    l.latest_dormant,
    l.latest_assigned,
    coalesce(l.latest_dormant, l.last_inserted_at) < coalesce(l.latest_assigned, l.first_inserted_at) as fields_reactivated_flag,
    -- latest Dormant date (or last_inserted_at) is before latest Assigned date (or first_inserted_at)
    l.last_inserted_at as "updated_at",
    l.first_inserted_at as "inserted_at"
FROM {{ ref('vw_issues_new') }} v
inner join latest_snapshot as l on v.id = l.id and v.extracted = l.last_inserted_at
