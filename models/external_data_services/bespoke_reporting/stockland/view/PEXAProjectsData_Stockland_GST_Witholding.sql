with load_date as 
(
    
    SELECT COALESCE(max(CONVERT_TIMEZONE('UTC', 'Australia/Sydney', METADATA$FILE_LAST_MODIFIED)), '1900-01-01'::TIMESTAMP_TZ) as l_date
    FROM @{{env_var('DBT_GROUP_EXT_DATASERVICES_DB')}}.STOCKLAND_DATASERVICES.{{env_var('DBT_ENV_NAME')}}_BESPOKE_OUTBOUND_STAGE/stockland_project_data_gst/
    (file_format => {{env_var('DBT_GROUP_EXT_DATASERVICES_DB')}}.STOCKLAND_DATASERVICES.CSV_FILE_FORMAT,
     pattern => '.*/PEXAProjectsData_Stockland_GST_Witholding.*\\.csv$' )
)
,source as
(SELECT distinct
    stockland_reference,
    prn,
    vendor_abn,
    form1_status,
    gst_withholding_amount,
    form2_status,
    gst_lineitem
FROM {{ ref('stockland_project_data_GST_Witholding') }}
join load_date on 1=1
WHERE inserted_at::timestamp_ntz >= load_date.l_date
)
select
    stockland_reference,
    prn,
    vendor_abn,
    form1_status,
    gst_withholding_amount AS "GST_Withholding_AMOUNT",
    form2_status,
    gst_lineitem
from source
UNION ALL
select
    null as stockland_reference,
    null as prn,
    null as vendor_abn,
    null as form1_status,
    null AS "GST_Withholding_AMOUNT",
    null as form2_status,
    null as gst_lineitem
from dual
where not exists
    (select 1 from source)

