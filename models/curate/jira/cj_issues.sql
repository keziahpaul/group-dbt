{# supposed to be SCD2 -#}
{{
  config(
    materialized = 'incremental',
    unique_key = ['id', 'updated'],
    incremental_strategy = 'merge',
    merge_exclude_columns = ['id', 'updated', 'inserted_at']
    )
}}
{#- in case the model has to be rebuilt after multiple api loads #}
with latest_version as (
  select
    id,
    updated,
    max(extracted) as latest_extracted
  from {{ ref('vw_issues_new') }}
{%- if is_incremental() %}
  where extracted > coalesce((select max(updated_at) from {{ this }}), '{{ var("base_date") }}')
{%- endif %}
  group by id, updated
)
select
    i.id,
    i.key,
    i.expand,
    i.aggregateprogress, {#- variant field - not all that useful #}
    i.aggregatetimeestimate,
    i.aggregatetimeoriginalestimate,
    i.aggregatetimespent,
    get(i.assignee, 'accountId')::string as assignee_user_id,
    i.attachment, {#- array field, strip these down such that "author" becomes author.accountId #}
    i.comment, {#- variant field, strip these down such that "author", "updateAuthor" becomes author/updateAuthor.accountId  #}
    i.components, {#- array field #}
    i.created,
    get(i.creator, 'accountId')::string as creator_user_id,
    i.description, {#- variant field, maybe turn this into a "string" #}
    i.duedate,
    i.environment,
    i.fixVersions, {#- array field #}
    i.issuelinks, {#- array field #}
    i.issuerestriction, {#- variant field #}
    get(i.issuetype, 'id')::string as issuetype_id,
    i.labels, {#- array field #}
    i.lastViewed,
    get(i.parent, 'id')::string as parent_issue_id,
    get(i.priority, 'id')::string as priority_id,
    i.progress, {#- variant field #}
    i.project as project_id,
    get(i.reporter, 'accountId')::string as reporter_user_id,
    get(i.resolution, 'id')::string as resolution_id,
    i.resolutiondate,
    i.security, {#- variant field #}
    get(i.status, 'id')::string as status_id,
    get(i.statusCategory, 'id')::string as statusCategory_id,
    i.statuscategorychangedate,
    i.subtasks, {#- array field #}
    i.summary,
    i.timeestimate,
    i.timeoriginalestimate,
    i.timespent,
    i.timetracking, {#- variant field #}
    i.updated,
    i.versions, {#- array field #}
    i.votes, {#- variant field #}
    i.watches, {#- variant field #}
    i.worklog, {#- variant field #}
    i.workratio,
    object_pick(i.customfields,
                filter(object_keys(i.customfields),
                       key -> not is_null_value(get(i.customfields, key))))::variant as customfields, {#- variant field #}
    i.self,
    i.extracted as inserted_at,
    i.extracted as updated_at
from {{ref('vw_issues_new')}} i
join latest_version l on i.id = l.id and i.updated = l.updated and i.extracted = l.latest_extracted
order by i.id, i.updated, i.extracted
