with workspace as (
    select 
        w.workspace_id,
        w.number1 as workspace,
        w.status as workspace_status
    from {{ source('exchange_share', 'vw_workspaces') }} w
),
transaction_type as (
    select 
        wt.workspace_id,
        wt.ws_transaction_type as transaction_type
    from {{ source('exchange_share', 'vw_ws_txn_type_workspaces') }} wt
),
im as (
    select 
        im.workspace_id,
        im_sub.name as incoming_mortgagee,
        im.reference as IM_reference
    from {{ source('exchange_share', 'vw_participants') }} im
    inner join {{ source('exchange_share', 'vw_subscribers') }} im_sub 
        on im_sub.subscriber_id = im.subscriber_id
    where 
        im.subscriber_id = 563 -- CBA - COMMONWEALTH BANK OF AUSTRALIA
        and im.workspace_role_id = 5 -- IM
        and im.status = 'ACTIVE'
),
mot as (
    select 
        mot.workspace_id,
        mot_sub.name as mortgagee_on_title,
        mot.reference as MOT_reference
    from {{ source('exchange_share', 'vw_participants') }} mot
    inner join {{ source('exchange_share', 'vw_subscribers') }} mot_sub 
        on mot_sub.subscriber_id = mot.subscriber_id
    where 
        mot.subscriber_id = 942 -- Bankwest
        and mot.workspace_role_id = 1 -- MOT
        and mot.status = 'ACTIVE'
),
workspace_created as (
    select 
        be.workspace_id,
        be.created_date::date as workspace_created_date
    from {{ source('exchange_share', 'vw_business_event') }} be
    where be.business_event_type_id = 1
)
select 
    cast( {{ var('local_current_time_ntz') }} as date) as reporting_date,
    w.workspace,
    w.workspace_status,
    wt.transaction_type,
    im.incoming_mortgagee,
    im.IM_reference,
    mot.mortgagee_on_title,
    mot.MOT_reference,
    wc.workspace_created_date,
    s.date1::date as current_settlement_date
from {{ source('exchange_share', 'vw_settlements') }} s
inner join workspace w on w.workspace_id = s.workspace_id
inner join transaction_type wt on wt.workspace_id = s.workspace_id
inner join im on im.workspace_id = s.workspace_id
inner join mot on mot.workspace_id = s.workspace_id
inner join workspace_created wc on wc.workspace_id = s.workspace_id
where wt.transaction_type = 'REFINANCE'
    and w.workspace_status = 'IN_PREPARATION'
    and s.date1 > cast( {{ var('local_current_time_ntz') }} as date)
    