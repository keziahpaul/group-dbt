with source as (
    select
        workspace_number,
        subscriber_name,
        subscriber_reference,
        role as workspace_role,
        workgroup,
        to_varchar(scheduled_date_time, 'YYYY-MM-DD HH24:MI:SS') as scheduled_date_time,
        end_of_day_outcome_category,
        readiness_category,
        first_attempt_to_settle,
        to_varchar(actual_settlement_date, 'YYYY-MM-DD HH24:MI:SS') as current_settlement_date,
        current_status_outcome,
        accepted_prior_subscriber,
        to_varchar(scheduled_date_time_accepted, 'YYYY-MM-DD HH24:MI:SS') as scheduled_date_time_accepted,
        fss_signed_subscriber,
        to_varchar(first_fss_signed_date, 'YYYY-MM-DD HH24:MI:SS') as first_fss_signed_date
    from {{ source('selfservice_source', 'on_time_settlements_subscribers') }}
    where
        upper(settlement_type) = 'TRANSFER'
        and (upper(role) = 'INCOMING_MORTGAGEE' or upper(role) = 'MORTGAGEE_ON_TITLE')
        and scheduled_date_time::date >= dateadd(
            week,
            -1,
            date_trunc(
                'week',
                {{ var('local_current_date') }}
            )   
        ) 
        and scheduled_date_time::date < date_trunc(
            'week',
            {{ var('local_current_date') }}
        )
        and subscriber_id = 6817
)
select source.*
from (values('')) v(t)
left join source on 1=1