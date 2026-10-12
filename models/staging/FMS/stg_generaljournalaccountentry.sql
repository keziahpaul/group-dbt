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
        cast(iscorrection as number) as is_correction,
        cast(iscredit as number) as is_credit,
        cast(postingtype as number) as posting_type,
        skipcreditcalculation as skip_credit_calculation,  {# unknown datatype#}
        cast(assetleasepostingtypes as number) as asset_lease_posting_types,
        cast(assetleasetransactiontype as number) as asset_lease_transaction_type,
        sysdatastatecode as sys_data_state_code,  {# unknown datatype#}
        cast(accountingcurrencyamount as number) as accounting_currency_amount,
        cast(allocationlevel as number) as allocation_level,
        cast(generaljournalentry as number) as general_journal_entry,
        to_timestamp_ntz(
            historicalexchangeratedate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as historical_exchange_rate_date,
        ledgeraccount as ledger_account,
        cast(ledgerdimension as number) as ledger_dimension,
        cast(quantity as number) as quantity,
        cast(reportingcurrencyamount as number) as reporting_currency_amount,
        subledgerjournalentry as sub_ledger_journal_entry,
        text,   -- noqa: RF04
        cast(transactioncurrencyamount as number) as transaction_currency_amount,
        transactioncurrencycode as transaction_currency_code,
        cast(mainaccount as number) as main_account,
        cast(fintag as number) as fin_tag,
        projid_sa as proj_id_sa,
        projtabledataareaid as proj_table_data_area_id,
        cast(reasonref as number) as reason_ref,
        paymentreference as payment_reference,
        cast(originalaccountentry as number) as original_accountentry,
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

    from {{ ref("vw_generaljournalaccountentry") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
