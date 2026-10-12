with load_date as 
(
    
    SELECT CONVERT_TIMEZONE('Australia/Sydney',current_timestamp()) as cur_date, COALESCE(max(CONVERT_TIMEZONE('UTC', 'Australia/Sydney', METADATA$FILE_LAST_MODIFIED)), '1900-01-01'::TIMESTAMP_TZ) as l_date
    FROM @{{env_var('DBT_GROUP_EXT_DATASERVICES_DB')}}.STOCKLAND_DATASERVICES.{{env_var('DBT_ENV_NAME')}}_BESPOKE_OUTBOUND_STAGE/stockland_project_data/
    (file_format => {{env_var('DBT_GROUP_EXT_DATASERVICES_DB')}}.STOCKLAND_DATASERVICES.CSV_FILE_FORMAT,
     pattern => '.*/PEXAProjectsData_Stockland.*\\.csv$' )
)
,source as
(SELECT
    WorkspaceID,
    SubscriberReference,
    WorkspaceStatus,
    LodgementStatus,
    FinancialSettlementStatus,
    SettlementDate,
    SettlementTimeAEST,
    SettlementBookingStatus,
    IPSubscriberID,
    IPInvitationStatus,
    IPSettlementBookingStatus,
    IMSubscriberID,
    IMInvitationStatus,
    IMSettlementBookingStatus,
    VendorFunds,
    POTSettlementBookingStatus,
    PexaProjectID
FROM {{ ref('stockland_project_data') }}
join load_date on 1=1
WHERE inserted_at::timestamp_ntz >= load_date.l_date
      
)
select 
    WorkspaceID,
    SubscriberReference,
    WorkspaceStatus,
    LodgementStatus,
    FinancialSettlementStatus,
    SettlementDate,
    SettlementTimeAEST,
    SettlementBookingStatus,
    IPSubscriberID,
    IPInvitationStatus,
    IPSettlementBookingStatus,
    IMSubscriberID,
    IMInvitationStatus,
    IMSettlementBookingStatus,
    VendorFunds,
    POTSettlementBookingStatus,
    PexaProjectID
from source
UNION ALL
select
    null as WorkspaceID,
    null as SubscriberReference,
    null as WorkspaceStatus,
    null as LodgementStatus,
    null as FinancialSettlementStatus,
    null as SettlementDate,
    null as SettlementTimeAEST,
    null as SettlementBookingStatus,
    null as IPSubscriberID,
    null as IPInvitationStatus,
    null as IPSettlementBookingStatus,
    null as IMSubscriberID,
    null as IMInvitationStatus,
    null as IMSettlementBookingStatus,
    null as VendorFunds,
    null as POTSettlementBookingStatus,
    null as PexaProjectID
from dual
where not exists
    (select 1 from source)

