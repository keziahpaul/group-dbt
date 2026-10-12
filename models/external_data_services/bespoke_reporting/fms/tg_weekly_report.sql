with filtered_settlements as (

    select
        workspace_id,
        workspace_number,
        jurisdiction,
        subscriber_id,
        workspace_role_id,
        workspace_role,
        first_accepted_dt,
        settlement_date
    from {{ source('selfservice_source', 'tg_settlements') }}
    where subscriber_id = 4042
      and settlement_date between date_trunc(
        'day',
        convert_timezone('Australia/Sydney', current_timestamp) - interval '7 day')::date
      AND 
        convert_timezone('Australia/Sydney', current_timestamp)::date
),

workspace_participants as (

    select
        p.workspace_id,
        p.workspace_role_id,
        p.subscriber_id,
        p.subscriber_name,
        p.role as workspace_role,
        pp.party_represented,
        pp.reference
    from {{ source('selfservice_source', 'workspace_partroles') }} p
    inner join {{ source('selfservice_source', 'participants') }} pp
        on pp.participant_id = p.participant_id
    where p.subscriber_id = 4042
      and pp.party_represented is not null

),

invitations_by_workspace_role as (

    select
        workspace_id,
        receiver_role,
        min(sent_date) as invitation_received
    from {{ source('selfservice_source', 'invitations_detailed') }}
    where receiver_subid = 4042
       or forwardedto_subscriber_id = 4042
    group by
        workspace_id,
        receiver_role

),

base_settlements as (

    select
        s.workspace_id,
        s.workspace_number,
        s.jurisdiction,
        wp.subscriber_name,
        wp.workspace_role,
        wp.party_represented,
        wp.reference,
        s.subscriber_id,
        s.workspace_role_id as settlement_role,
        s.workspace_role as settlement_role_name,
        s.first_accepted_dt as first_settlement_date_accepted,
        s.settlement_date
    from filtered_settlements s
    inner join {{ source('selfservice_source', 'workspace_created_master') }} wc
        on wc.workspace_id = s.workspace_id
    inner join workspace_participants wp
        on wp.workspace_id = s.workspace_id
       and wp.workspace_role_id = s.workspace_role_id
       and wp.subscriber_id = s.subscriber_id

)

select
    b.workspace_number,
    b.jurisdiction,
    b.subscriber_name,
    b.workspace_role,
    b.party_represented,
    b.reference,
    to_varchar(b.first_settlement_date_accepted, 'YYYY-MM-DD HH24:MI:SS') as first_settlement_date_accepted,
    to_varchar(b.settlement_date, 'YYYY-MM-DD HH24:MI:SS') as settlement_date,
    to_varchar(i.invitation_received, 'YYYY-MM-DD HH24:MI:SS.FF6') as invitation_received,
    to_varchar(fproceeds.first_event_date_local, 'YYYY-MM-DD HH24:MI:SS') as first_proceeds_entered,
    to_varchar(lproceeds.last_event_created_date_local, 'YYYY-MM-DD HH24:MI:SS') as last_proceeds_entered,
    to_varchar(fpayout.first_event_date_local, 'YYYY-MM-DD HH24:MI:SS') as first_payout_entered,
    to_varchar(lpayout.last_event_created_date_local, 'YYYY-MM-DD HH24:MI:SS') as last_payout_entered,
    to_varchar(atd.first_event_date_local, 'YYYY-MM-DD HH24:MI:SS') as first_auth_to_debt_entered,
    case upper(trim(lproceeds.metric_met))
        when 'TRUE' then 'True'
        when 'FALSE' then 'False'
    end as proceed_flag,
    case upper(trim(lpayout.metric_met))
        when 'TRUE' then 'True'
        when 'FALSE' then 'False'
    end as payout_flag,
    case upper(trim(atd.metric_met))
        when 'TRUE' then 'True'
        when 'FALSE' then 'False'
    end as auth_to_debit_flag
from base_settlements b
left join invitations_by_workspace_role i
    on i.workspace_id = b.workspace_id
   and i.receiver_role = b.settlement_role_name
left join {{ source('selfservice_source', 'tg_first_proceeds_entered') }} fproceeds
    on fproceeds.workspace_id = b.workspace_id
   and fproceeds.subscriber_id = b.subscriber_id
   and fproceeds.workspace_role_id = b.settlement_role
left join {{ source('selfservice_source', 'tg_last_proceeds_entered') }} lproceeds
    on lproceeds.workspace_id = b.workspace_id
   and lproceeds.subscriber_id = b.subscriber_id
   and lproceeds.workspace_role_id = b.settlement_role
left join {{ source('selfservice_source', 'tg_first_payout_entered') }} fpayout
    on fpayout.workspace_id = b.workspace_id
   and fpayout.subscriber_id = b.subscriber_id
   and fpayout.workspace_role_id = b.settlement_role
left join {{ source('selfservice_source', 'tg_last_payout_entered') }} lpayout
    on lpayout.workspace_id = b.workspace_id
   and lpayout.subscriber_id = b.subscriber_id
   and lpayout.workspace_role_id = b.settlement_role
left join {{ source('selfservice_source', 'tg_authority_to_debit') }} atd
    on atd.workspace_id = b.workspace_id
   and atd.subscriber_id = b.subscriber_id
   and atd.workspace_role_id = b.settlement_role
order by
    b.settlement_date,
    b.workspace_number desc
