{{
    config(
        materialized='incremental',
        unique_key='PS_SubscriberID__c',
        merge_exclude_columns = ['inserted_at'],
        on_schema_change = 'append_new_columns'
    )
}}

select
    ps.id as record_id,
    s.subscriber_id as PS_SubscriberID__c,
    s.name as Name,
    s.status as PS_Status__c,
    case
        when s.status in ('TERMINATED','SUSPENDED') then coalesce(s.status_reason_date::date, current_date)
        else null
    end as PS_SuspensionTerminationDate__c,
    case
        when s.status in ('SUSPENDED') then coalesce(substr(s.status_reason,0,255),'Other')
        else null
    end as PS_ReasonforSuspension__c,
    case
        when s.status in ('TERMINATED') then 'Other'
        else null
    end as PS_ReasonforTermination__c,
    case
        when s.status in ('TERMINATED')
        then coalesce(substr(s.status_reason,0,255),'Other')
        else null
    end as PS_TerminationOther__c,
    a.ID as PS_Account__c,
    CONVERT_TIMEZONE('Australia/Sydney',s.inserted_at) as src_delta_extract_ts,
    {{ var('inserted_at') }} as inserted_at,
    {{ var('updated_at') }} as updated_at
from {{ source('exchange_share', 'vw_subscribers') }} s 
inner join {{ ref('vw_ps_subscription') }} ps
on s.subscriber_id = ps.PS_SUBSCRIBER_ID_C
inner join {{ ref('vw_account') }} a
on ps.PS_SUBSCRIBER_ID_C = try_cast(a.ps_external_id_c as number(38,0))
{% if is_incremental() %}
where CONVERT_TIMEZONE('Australia/Sydney',s.inserted_at) > (select max(src_delta_extract_ts) from {{ this }})
{% endif %}