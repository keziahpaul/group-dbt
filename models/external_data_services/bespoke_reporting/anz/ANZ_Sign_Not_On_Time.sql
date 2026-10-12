select  DISTINCT
		workspace_id as "Workspace_ID"
		, reference as "Subscriber_Reference"
		, business_unit as "Business_Unit"
		, workspace_role as "Workspace_Role"
		, jurisdiction as "Jurisdiction"
		, to_char(first_accepted_dt,'YYYY-MM-DD HH24:MI:SS') as "First_Accepted_dt"
		, to_char(signed_date,'YYYY-MM-DD HH24:MI:SS') as "Signed_Date"
		, to_char(settlement_date,'YYYY-MM-DD HH24:MI:SS') as "Final_Settlement_Date"
		, to_char(workspace_created_date,'YYYY-MM-DD HH24:MI:SS') as "Workspace_Created_Date"
		, to_char(date_participant_added,'YYYY-MM-DD HH24:MI:SS') as "Invite_Received_Date"
		, metric_met as "Metric_Met"
from {{ source('selfservice_source', 'signed_on_time') }}
where subscriber_id = 601
and settlement_date::date =  (select {{ get_previous_weekday(var('local_current_date')) }} )
		