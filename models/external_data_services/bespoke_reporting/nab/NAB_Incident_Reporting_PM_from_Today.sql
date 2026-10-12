with
workspace_ids as (
    select workspace_number from {{ ref("NAB_Incident_Reporting_AM") }}
    union
    select workspace_number from {{ ref("NAB_Incident_Reporting_1PM") }}
),

nab_ws as (
    select
        w.workspace_id,
        w.number1 as workspace_number,
        sett.date1 as settlement_date,
        sett.status as settlement_status
    from {{ source("exchange_share", "vw_settlements") }} as sett
    inner join
        {{ source("exchange_share", "vw_participants") }} as p
        on p.workspace_id = sett.workspace_id
    inner join
        {{ source("exchange_share", "vw_workspaces") }} as w
        on w.workspace_id = p.workspace_id
    inner join workspace_ids as ws on w.number1 = ws.workspace_number
    where p.subscriber_id = 581 and w.status <> 'ABANDONED' and p.status = 'ACTIVE'
    group by w.workspace_id, w.number1, sett.date1, sett.status
)

-- noqa: disable=ST06
select
    nab_ws.workspace_number,
    to_char(nab_ws.settlement_date, 'YYYY-MM-DD HH24:MI:SS') as settlement_date,
    nab_ws.settlement_status,
    s.name as subscriber,
    wr.name as workspace_role,
    p.reference as subscriber_reference,
    p.settle_acceptance_status
from nab_ws
inner join
    {{ source("exchange_share", "vw_participants") }} as p
    on p.workspace_id = nab_ws.workspace_id
        and p.status = 'ACTIVE'
inner join
    {{ source("exchange_share", "vw_workspace_roles") }} as wr
    on wr.workspace_role_id = p.workspace_role_id
inner join
    {{ source("exchange_share", "vw_subscribers") }} as s
    on s.subscriber_id = p.subscriber_id
order by nab_ws.workspace_number, s.name, wr.name
