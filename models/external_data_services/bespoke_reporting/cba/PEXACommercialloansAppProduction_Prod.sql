with subscriber_base as (
    select * from {{ source('exchange_share', 'vw_users') }}
    where SUBSCRIBER_ID in (18742)
),
user_permissions as (
    select
        U.USER_ID,
        p.Description
    from
        subscriber_base U
        inner join {{ source('exchange_share', 'vw_user_permissions') }} UP on UP.USER_ID = U.USER_ID
        inner join {{ source('exchange_share', 'vw_permissions') }} P on UP.PERMISSION_ID = P.PERMISSION_ID
    group by
        U.USER_ID,
        p.Description
),
workgroup_users as (
    select
        U.USER_ID,
        W.NAME
    from
        {{ source('exchange_share', 'vw_users') }} U
        inner join {{ source('exchange_share', 'vw_workgroup_users') }} WU on WU.USER_ID = U.USER_ID
        inner join {{ source('exchange_share', 'vw_workgroups') }} W on W.WORKGROUP_ID = WU.WORKGROUP_ID
    group by
        U.USER_ID,
        W.NAME
),
application_roles as (
    select
        U.USER_ID,
        Case
            when SUBSTR(ar.NAME, 6, 99) = 'USER' then 'Subscriber User'
            when SUBSTR(ar.NAME, 6, 99) = 'SUBSCRIBER_ADMIN' then 'Subscriber Administrator'
            when SUBSTR(ar.NAME, 6, 99) = 'SUBSCRIBER_MANAGER' then 'Subscriber Manager'
        End as "Relationship Based Entitlement"
    from
        subscriber_base U
        inner join {{ source('exchange_share', 'vw_user_application_roles') }} up on up.USER_ID = u.USER_ID
        inner join {{ source('exchange_share', 'vw_application_roles') }} ar on ar.APPLICATION_ROLE_ID = up.APPLICATION_ROLE_ID
    group by
        U.USER_ID,
        SUBSTR(ar.NAME, 6, 99)
),
last_login as (
    SELECT
        be.user_id,
        MAX(created_date) AS last_login
    FROM
        {{ source('exchange_share', 'vw_business_event') }} be
    WHERE
        business_event_type_id = 43 --USER_AUTHENTICATED (Logged in)
        AND be.created_date >= date_trunc('month', {{ var('local_current_time_ntz') }}) - INTERVAL '6 months'
    GROUP BY
        be.user_id
),
combined_roles as (
    select * from user_permissions
    union all
    select * from workgroup_users
    union all
    select * from application_roles
)
select
    u.username as "Account Name",
    Case
        when u.status = 'ACTIVE' then 'False'
        else 'True' 
    end as "Account Disabled",
    '' as "EmployeeID", 
    u.username as "Email",
    '' as "LANID",
    u.First_name as "Given Name",
    u.Last_name as "Surname",
    to_char(lg.last_login, 'DD/MM/YYYY') as "Last Logon Date",
    to_char(u.created, 'DD/MM/YYYY') as "Created Date",
    MAX(to_char(pass.CHANGED, 'DD/MM/YYYY')) as "Last Password Changed",
    '' as "Account Description",
    Case
        when u.Subscriber_ID = 563 then 'PEXARetailAppProduction'
        else 'PEXACommercialloansAppProduction'
    end as "Endpoint",
    Case
        when u.username like 'ACOE%' then 'imsNonHuman'
        else 'imsHuman'
    end as "Super Type",
    '' as "Sub Type",
    x.description as "Relationship Based Entitlement",
    '' as "Value-based Entitlement"
from
    subscriber_base U
    left join {{ source('exchange_share', 'vw_passwords') }} PASS on PASS.USER_ID = U.USER_ID
    left join combined_roles x on u.user_id = x.user_id
    LEFT JOIN last_login lg ON lg.user_id = u.user_id
Group by
    u.username,
    u.status,
    u.First_name,
    u.Last_name,
    u.created,
    u.Subscriber_ID,
    lg.last_login,
    x.description
    