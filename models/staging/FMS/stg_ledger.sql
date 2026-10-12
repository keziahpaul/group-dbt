with
{% if is_incremental() %}
latest_ts as (
    select
        coalesce(
            max(sink_modified_on), '1990-01-01 00:00:00'
        ) as last_extracted_ts
    from {{ this }}
),
{% endif %}

initial as (
    select
        id,
        to_timestamp_ntz(
            sinkcreatedon, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as sink_created_on,
        to_timestamp_ntz(
            sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as sink_modified_on,
        cast(isbudgetcontrolenabled as number) as is_budget_control_enabled,
        sysdatastatecode as sys_data_state_code,  {# unknown datatype#}
        accountingcurrency as accounting_currency,
        cast(budgetexchangeratetype as number) as budget_exchange_rate_type,
        cast(chartofaccounts as number) as chart_of_accounts,
        cast(defaultexchangeratetype as number) as default_exchange_rate_type,
        description,
        cast(fiscalcalendar as number) as fiscal_calendar,
        name,   -- noqa: RF04
        cast(primaryforlegalentity as number) as primary_for_legal_entity,
        reportingcurrency as reporting_currency,
        cast(
            reportingcurrencyexchangeratetype as number
        ) as reporting_currency_exchange_rate_type,
        to_timestamp_ntz(
            mostrecentyearendclose, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as most_recent_year_end_close,
        to_timestamp_ntz(
            modifieddatetime, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as modified_date_time,
        modifiedby as modified_by,
        modifiedtransactionid as modified_transaction_id,
        to_timestamp_ntz(
            createddatetime, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as created_date_time,
        createdby as created_by,
        createdtransactionid as created_transaction_id,
        dataareaid as data_area_id,
        recversion,
        partition,  -- noqa: RF04
        sysrowversion,
        recid as rec_id,
        tableid as table_id,
        versionnumber as version_number,
        to_timestamp_ntz(createdon, 'YYYY-MM-DD HH24:MI:SS.FF3') as created_on,
        to_timestamp_ntz(modifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') as modified_on,
        cast(isdelete as boolean) as is_delete,
        {{ var('inserted_at' ) }} as inserted_at

    from {{ ref("vw_ledger") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
