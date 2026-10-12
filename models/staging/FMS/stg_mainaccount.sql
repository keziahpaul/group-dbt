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
        cast(adjustmentmethod_mx as NUMBER) as adjustment_method_mx,
        cast(closetype as NUMBER) as close_type,
        cast(closing as NUMBER) as closing,
        cast(debitcreditbalancedemand as NUMBER) as debit_credit_balance_demand,
        cast(debitcreditcheck as NUMBER) as debit_credit_check,
        cast(debitcreditproposal as NUMBER) as debit_credit_proposal,
        cast(exchangeadjusted as NUMBER) as exchange_adjusted,
        cast(financialreportingtranslationtype as NUMBER) as financial_reporting_translation_type,
        cast(inflationadjustment_mx as NUMBER) as inflation_adjustment_mx,
        cast(mandatorypaymentreference as NUMBER) as mandatory_payment_reference,
        cast(monetary as NUMBER) as monetary,
        cast(postingtype as NUMBER) as posting_type,
        cast(repomotype_mx as NUMBER) as repomo_type_mx,
        cast(reportingaccounttype as NUMBER) as reporting_account_type,
        cast(type as NUMBER) as type,   -- noqa: RF04
        cast(validatecurrency as NUMBER) as validate_currency,
        cast(validateposting as NUMBER) as validate_posting,
        cast(validateuser as NUMBER) as validate_user,
        sysdatastatecode as sys_data_state_code, {# unknown datatype#}
        cast(accountcategoryref as NUMBER) as account_category_ref,
        consolidationmainaccount as consolidation_main_account,
        currencycode as currency_code,
        cast(exchangeadjustmentratetype as NUMBER) as exchange_adjustment_rate_type,
        cast(financialreportingexchangeratetype as NUMBER) as financial_reporting_exchange_rate_type,
        cast(ledgerchartofaccounts as NUMBER) as ledger_chart_of_accounts,
        mainaccountid as main_account_id,
        cast(mainaccounttemplate as NUMBER) as main_account_template,
        name,   -- noqa: RF04
        cast(offsetledgerdimension as NUMBER) as offset_ledger_dimension,
        cast(openingaccount as NUMBER) as opening_account,
        cast(parentmainaccount as NUMBER) as parent_main_account,
        srucode as sru_code,
        cast(transferyearendaccount_es as NUMBER) as transfer_year_end_account_es,
        cast(unitofmeasure as NUMBER) as unit_of_measure,
        userinfoid as user_info_id,
        cast(parentmainaccount_br as NUMBER) as parent_main_account_br,
        cast(reportingexchangeadjustmentratetype as NUMBER) as reporting_exchange_adjustment_rate_type,
        cast(standardmainaccount_w as NUMBER) as standard_main_account_w,
        naturecode_br as nature_code_br, {# unknown datatype#}
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
        cast(isdelete as BOOLEAN) as is_delete,
        {{ var('inserted_at' ) }} as inserted_at

    from {{ ref("vw_mainaccount") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
