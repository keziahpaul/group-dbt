with latest_snapshot as (
    select
        v.issue_id,
        max(
            iff(
                parse_json(v.fields_customfield_10577)[0]:value = 'Yes',
                v.inserted_at,
                NULL
            )
        ) as max_inserted_at,
        min(v.inserted_at) as first_inserted_at,
        max(v.inserted_at) as last_inserted_at,
        iff(count(*) > 1, TRUE, FALSE) as has_previous_version
    from {{ ref('vw_issues') }} as v
    where
        v.fields_project_key = 'PPS'
    group by v.issue_id
    having
        boolor_agg(parse_json(v.fields_customfield_10577)[0]:value = 'Yes')
        = TRUE
)

select

    v.key as "Issue Key",
    v.fields_summary as "Summary",
    parse_json(v.fields_customfield_10582)[0]:value::string as "Network Member",
    to_timestamp_tz(
        v.fields_customfield_10580::string, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM'
    )::timestamp as "Network Incident Created",
    to_timestamp_tz(
        v.fields_customfield_10581::string, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM'
    )::timestamp as "Network Incident Resolved",
    v.fields_customfield_10583::number as "Impacted Workspaces",
    v.fields_customfield_10578::number as "Settlement Failed or Rescheduled",
    v.fields_customfield_10579::number as "Total Scheduled Settlement",
    v.fields_customfield_10062 as "Root Cause Details",
    parse_json(v.fields_customfield_10037):value::string as "Severity",

    parse_json(v.fields_customfield_10145):value::string as "Triage Analysis",
    parse_json(v.fields_customfield_10146)[0]:value::string
        as "Possible Root Cause",
    l.last_inserted_at as "updated_at",
    iff(
        l.has_previous_version,
        l.first_inserted_at,
        l.last_inserted_at
    ) as "inserted_at"
from
    {{ ref('vw_issues') }} as v
inner join latest_snapshot as l
    on
        v.issue_id = l.issue_id
        and v.inserted_at = l.max_inserted_at

order by v.fields_customfield_10531
