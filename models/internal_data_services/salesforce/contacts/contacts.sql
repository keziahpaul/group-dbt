{{
    config(
        materialized='incremental',
        unique_key='user_id',
        merge_exclude_columns = ['inserted_at']
    )
}}
with user_login_events as
(
    select user_id, created_date,inserted_at, business_event_id
    from {{ source('exchange_share', 'vw_business_event') }} be
    where be.business_event_type_id in (43) --( user_authentication )
    and user_id is not null
) ,

user_last_login as
(
    select user_id,
    max(created_date) as user_last_login_date,
    max(inserted_at) as be_inserted_at
    from user_login_events
    group by user_id
) ,
user_login_count as
(
    select user_id,
    count(distinct business_event_id) as user_login_count
    from user_login_events
    where to_date(created_date) > dateadd( 'days', -7, current_date )
    group by user_id
)
,
final_output as (
select distinct  
    u.user_id,
    u.first_name,
    u.last_name,
    u.email_address,
    u.phone_number,
    u.user_status,
    u.user_role,
    u.primary_subscriber_manager_flag,
    u.subscriber_id,
	to_char(user_last_login_date, 'yyyy-mm-ddThh24:mi:ss.ff3Z') as exchange_last_login__c,
    user_login_count as exchange_user_login_days_count__c,
    user_permissions,
    greatest_ignore_nulls(u.src_delta_extract_ts,user_last_login.be_inserted_at) as src_delta_extract_ts
from {{ ref('user_details') }} u
left join user_last_login on u.user_id = user_last_login.user_id  -- to obtain last login date
left join user_login_count on  u.user_id =user_login_count.user_id -- to obtain login count in last 7 days
{%if is_incremental()%}
where greatest_ignore_nulls(u.src_delta_extract_ts,user_last_login.be_inserted_at) > (select max(src_delta_extract_ts) from {{this}} )
{%endif%}
)

select user_id, 
    first_name,
    last_name,
    email_address,
    phone_number,
    user_status,
    user_role,
	primary_subscriber_manager_flag,
    subscriber_id,
	exchange_last_login__c,
    exchange_user_login_days_count__c,
    user_permissions,
    CONVERT_TIMEZONE('Australia/Sydney',src_delta_extract_ts) as src_delta_extract_ts,
    'Processing Answers' as status__c,
    {{ var('inserted_at') }} as inserted_at,
    {{ var('updated_at') }} as updated_at
from final_output
