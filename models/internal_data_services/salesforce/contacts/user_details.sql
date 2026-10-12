{{
    config(
        materialized='incremental',
        unique_key='user_id',
        merge_exclude_columns = ['inserted_at']
    )
}}

With 
{%if is_incremental()%}
target_max_timestamp as 
(
    select max(src_delta_extract_ts) as last_load_max_timestamp from {{this}}
),
{%endif%}

permissions as 
(

select u.user_id, listagg(distinct p.name,';') as user_permissions, max(up.inserted_at) as inserted_at
from {{ source('exchange_share', 'vw_users') }}  u
inner join {{ source('exchange_share', 'vw_user_permissions') }}  up
    on u.user_id=up.user_id
inner join {{ source('exchange_share', 'vw_permissions') }}  p
    on up.permission_id=p.permission_id
group by u.user_id

),

user_details as (
select u.subscriber_id 
		,u.user_id 
		,LEFT(u.first_name, 40) as first_name
		,LEFT(u.last_name, 40) as last_name
		,replace(u.email_address1,'&apos;', '''')  as email_address
		,'+'||replace(phone_number,'+','') as phone_number -- Salesforce requirement to add + sign for phone numbers
		,r.description as user_role
		,case 
			when sm.user_id is null then false
			else true 
		end as primary_subscriber_manager_flag
		,u.status as user_status
		,to_char(u.reason_date,'YYYY-MM-DD"T"HH24:MI:SS".000Z"') as user_status_reason_changed_date
        ,p.user_permissions as user_permissions 
        ,greatest_ignore_nulls(u.inserted_at,ur.inserted_at,r.inserted_at,sm.inserted_at, p.inserted_at) as src_delta_extract_ts
from {{ source('exchange_share', 'vw_users') }}  u -- to obtain most user info
join {{ source('exchange_share', 'vw_user_application_roles') }}  ur -- to obtain user role
	on u.user_id = ur.user_id 
join {{ source('exchange_share', 'vw_application_roles') }}  r -- to obtain role name
	on ur.application_role_id = r.application_role_id 
left join {{ source('exchange_share', 'vw_primary_contacts') }}  sm -- to know whether user is subscriber manager - user id in spplication role and primary contact
	on ur.user_id = sm.user_id
left join permissions p
    on u.user_id=p.user_id
where u.subscriber_id IS NOT NULL
-- Exclude emails with 'old' preceded by special characters (except dots)
and NOT REGEXP_LIKE(u.email_address1, '.*[^a-z0-9\\.]old$', 'i')
and (
    u.email_address1 not ilike '%.OLD'
    or (
        u.email_address1 ilike '%.OLD'
        and greatest_ignore_nulls(u.updated_at, ur.updated_at, r.updated_at, sm.updated_at, p.inserted_at) >= '{{ var("sf_old_email_cutoff_date") }}'
    )
)

{% if is_incremental()%}
    and (   u.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or ur.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or r.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or sm.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
         or p.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
        )
{%endif%}
)


select subscriber_id,
    user_id,
    first_name, 
    last_name, 
    email_address,
    phone_number,
    user_role,
    primary_subscriber_manager_flag,
    user_status,
    user_status_reason_changed_date,
    user_permissions,
    CONVERT_TIMEZONE('Australia/Sydney',src_delta_extract_ts) as src_delta_extract_ts,
    {{ var('inserted_at') }} as inserted_at,
    {{ var('updated_at') }} as updated_at
from user_details

