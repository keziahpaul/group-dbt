select
s.workspace_number,
s.jurisdiction,
s.subscriber_name,
s.workspace_role,
s.party_represented,
s.reference,
s.first_accepted_dt as first_settlement_date_accepted,
s.settlement_date,
s.signed_date,
s.metric_met
from {{ source('selfservice_source', 'signed_on_time') }} s
where subscriber_id = 4042
and s.settlement_date between
    date_trunc('day',convert_timezone('Australia/Sydney', current_timestamp) - interval '7 day')::date
    AND 
    convert_timezone('Australia/Sydney', current_timestamp)::date