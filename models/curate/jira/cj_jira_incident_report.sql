{{
  config(
    materialized = 'incremental',
    unique_key = 'Issue_Key'
    )
}}
with latest_network_record as (
    select
        i.id,
        max(iff(i.customfields:customfield_10577[0]:value::string = 'Yes', i.extracted, NULL)) as last_network_incident_at,
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
),
src as (
    select
        v.key as Issue_Key,
        v.summary as Summary,
        v.customfields:customfield_10582[0]:value::string as Network_Member,
        to_timestamp_tz(v.customfields:customfield_10580::string, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM')::timestamp as Network_Incident_Created,
        to_timestamp_tz(v.customfields:customfield_10581::string, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZHTZM')::timestamp as Network_Incident_Resolved,
        v.customfields:customfield_10583::number as Impacted_Workspaces,
        v.customfields:customfield_10578::number as Settlement_Failed_or_Rescheduled,
        v.customfields:customfield_10579::number as Total_Scheduled_Settlement,
        v.customfields:customfield_10062::variant as Root_Cause_Details,
        v.customfields:customfield_10037:value::string as Severity,
        v.customfields:customfield_10145:value::string as Triage_Analysis,
        v.customfields:customfield_10146[0]:value::string as Possible_Root_Cause,
        l.last_inserted_at as updated_at,
        l.first_inserted_at as inserted_at
    from {{ ref('vw_issues_new') }} as v
    inner join latest_network_record as l on v.id = l.id and v.extracted = l.last_network_incident_at
),
textify as (
    SELECT
        Issue_Key,
        LISTAGG(paragraph_text, '\n\n') WITHIN GROUP (ORDER BY paragraph_idx) AS plain_text
    FROM (
        SELECT
            t.Issue_Key,
            p.index AS paragraph_idx,
            LISTAGG(
                CASE c.value:type::string
                    WHEN 'text' THEN c.value:text::string
                    WHEN 'inlineCard' THEN REGEXP_SUBSTR(c.value:attrs:url::string, '[A-Z]+-[0-9]+')
                    ELSE ''
                END,
                ''
            ) WITHIN GROUP (ORDER BY c.index) AS paragraph_text
        FROM src t,
            LATERAL FLATTEN(input => t.Root_Cause_Details:content) p,
            LATERAL FLATTEN(input => p.value:content) c
        WHERE p.value:type::string = 'paragraph'
        GROUP BY t.Issue_Key, p.index
    )
    GROUP BY Issue_Key
)
select
    src.Issue_Key,
    src.Summary,
    src.Network_Member,
    src.Network_Incident_Created,
    src.Network_Incident_Resolved,
    src.Impacted_Workspaces,
    src.Settlement_Failed_or_Rescheduled,
    src.Total_Scheduled_Settlement,
    t.plain_text as Root_Cause_Text,
    src.Severity,
    src.Triage_Analysis,
    src.Possible_Root_Cause,
    src.updated_at,
    src.inserted_at
from src
left join textify t on src.Issue_Key = t.Issue_Key
