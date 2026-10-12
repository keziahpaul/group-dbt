select
s.workspace_number,
s.jurisdiction,
s.subscriber_name,
s.workspace_role,
s.party_represented,
s.reference,
to_char(s.first_accepted_dt,'YYYY-MM-DD HH24:MI:SS') as first_settlement_date_accepted,
to_char(s.settlement_date,'YYYY-MM-DD HH24:MI:SS') as settlement_date,
to_char(s.signed_date,'YYYY-MM-DD HH24:MI:SS') as signed_date,
s.metric_met
from {{ source('selfservice_source', 'signed_on_time') }} s
where subscriber_id = 4042
and s.settlement_date between date_trunc('day', {{ var('local_current_date') }}  - interval '1 day' )::date and {{ var('local_current_date') }} 
