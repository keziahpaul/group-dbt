{{
  config(
    materialized = 'incremental',
    unique_key = '"Issue Key"'
    )
}}
with latest_network_record as (
    select
        i.id,
        max(iff(get(get(get(i.customfields, 'customfield_10577'), 0), 'value')::string = 'Yes', i.extracted, NULL)) as last_network_incident_at,
        min(i.extracted) as first_inserted_at,
        max(i.extracted) as last_inserted_at
    from {{ ref('vw_issues_new') }} i
    join {{ ref('vw_projects') }} p on i.project = p.id
    where p.key = 'PPS'
    group by 1
    -- at least a network issue at some point
    having last_network_incident_at is not null
    {%- if is_incremental() %}
       and last_inserted_at = (select max(extracted) from {{ ref('vw_issues_new') }})
    {%- endif %}
)
select
    v.key as "Issue Key",
    v.summary as "Summary",
    get(get(get(v.customfields, 'customfield_10582'), 0), 'value')::string as "Network Member",
    to_timestamp_tz(get(v.customfields, 'customfield_10580')::string, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM')::timestamp as "Network Incident Created",
    to_timestamp_tz(get(v.customfields, 'customfield_10581')::string, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM')::timestamp as "Network Incident Resolved",
    get(v.customfields, 'customfield_10583')::number as "Impacted Workspaces",
    get(v.customfields, 'customfield_10578')::number as "Settlement Failed or Rescheduled",
    get(v.customfields, 'customfield_10579')::number as "Total Scheduled Settlement",
    get(v.customfields, 'customfield_10062')::string as "Root Cause Details",
    get(get(v.customfields, 'customfield_10037'), 'value')::string as "Severity",
    get(get(v.customfields, 'customfield_10145'), 'value')::string as "Triage Analysis",
    get(get(get(v.customfields, 'customfield_10146'), 0), 'value')::string as "Possible Root Cause",
    l.last_inserted_at as "updated_at",
    l.first_inserted_at as "inserted_at"
from {{ ref('vw_issues_new') }} as v
inner join latest_network_record as l on v.id = l.id and v.extracted = l.last_network_incident_at
