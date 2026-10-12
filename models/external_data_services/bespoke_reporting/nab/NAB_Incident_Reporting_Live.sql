with nab_ws as (
    select
        w.workspace_id,
        w.number1 as workspace_number,
        sett.date1 as settlement_date,
        sett.status as settlement_status
    from {{ source('exchange_share', 'vw_settlements') }} as sett
    inner join
        {{ source('exchange_share', 'vw_participants') }} as p
        on sett.workspace_id = p.workspace_id
    inner join
        {{ source('exchange_share', 'vw_workspaces') }} as w
        on p.workspace_id = w.workspace_id
    where
        sett.date1::date = cast({{ var('local_current_time_ntz') }} as date)
        and p.subscriber_id = 581
        and w.status <> 'ABANDONED'
        and p.status = 'ACTIVE'
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
inner join {{ source('exchange_share', 'vw_participants') }} as p
    on
        nab_ws.workspace_id = p.workspace_id
        and p.status = 'ACTIVE'
inner join
    {{ source('exchange_share', 'vw_workspace_roles') }} as wr
    on p.workspace_role_id = wr.workspace_role_id
inner join
    {{ source('exchange_share', 'vw_subscribers') }} as s
    on p.subscriber_id = s.subscriber_id
order by
    nab_ws.workspace_number,
    s.name,
    wr.name
