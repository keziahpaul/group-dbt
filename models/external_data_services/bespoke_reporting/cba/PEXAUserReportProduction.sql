with user_base as (
    select *
    from {{ source('exchange_share', 'vw_users') }}
    where subscriber_id in (18742, 563)
),
last_login as (
    select
        be.user_id,
        max(created_date) as last_login
    from {{ source('exchange_share', 'vw_business_event') }} be
    where business_event_type_id = 43
        and be.created_date > (
        date_trunc('month', {{ var('local_current_time_ntz') }}) + interval '1 month'- interval '1 day' + interval '1 day') - interval '7 month'
    group by be.user_id
),
workgroups as (
    select
        u.user_id,
        listagg(w.name, ',') within group (order by wu.user_id) as workgroup
    from user_base u
        inner join {{ source('exchange_share', 'vw_workgroup_users') }} wu on wu.user_id = u.user_id
        inner join {{ source('exchange_share', 'vw_workgroups') }} w on w.workgroup_id = wu.workgroup_id
    group by u.user_id
),
permissions as (
    select
        u.user_id,
        listagg(p.description, ',') within group (order by u.user_id) as permission
    from user_base u
        left join {{ source('exchange_share', 'vw_user_permissions') }} up on up.user_id = u.user_id
        left join {{ source('exchange_share', 'vw_permissions') }} p on up.permission_id = p.permission_id
    group by u.user_id
)
select
    case
        when substr(ar.name, 6, 99) = 'USER' then 'Subscriber User'
        when substr(ar.name, 6, 99) = 'SUBSCRIBER_ADMIN' then 'Subscriber Administrator'
        when substr(ar.name, 6, 99) = 'SUBSCRIBER_MANAGER' then 'Subscriber Manager'
    end as "Subscriber User Type",
    u.first_name as "First Name",
    u.middle_name as "Middle Name",
    u.last_name as "Last Name",
    u.email_address1 as "Email",
    u.job_title as "Job Title",
    wg.workgroup as "Workgroup(s)",
    perm.permission as "Permission(s)",
    u.source_signing_limit as "Source Signing Limit",
    u.destination_signing_limit as "Destination Signing Limit",
    u.certifier_designation as "Signing Role",
    u.created as "Created On",
    to_char(lg.last_login, 'DD/MM/YYYY') as "Last Active",
    u.status as "Status",
    u.subscriber_id as "Subscriber ID"
from user_base u
    inner join {{ source('exchange_share', 'vw_subscribers') }} s on s.subscriber_id = u.subscriber_id
    inner join {{ source('exchange_share', 'vw_subscriber_types') }} st on s.subscriber_type_id = st.subscriber_type_id
    left join {{ source('exchange_share', 'vw_user_application_roles') }} up on up.user_id = u.user_id
    left join {{ source('exchange_share', 'vw_application_roles') }} ar on ar.application_role_id = up.application_role_id
    left join last_login lg on lg.user_id = u.user_id
    left join workgroups wg on wg.user_id = u.user_id
    left join permissions perm on perm.user_id = u.user_id

order by u.subscriber_id
