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
        cast(journalcategory as number) as journal_category,
        cast(postinglayer as number) as posting_layer,
        sysdatastatecode as sys_data_state_code,  {# unknown datatype#}
        to_timestamp_ntz(
            accountingdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as accounting_date,
        to_timestamp_ntz(
            acknowledgementdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as acknowledgement_date,
        to_timestamp_ntz(
            documentdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as document_date,
        documentnumber as document_number,
        cast(fiscalcalendarperiod as number) as fiscal_calendar_period,
        cast(fiscalcalendaryear as number) as fiscal_calendar_year,
        journalnumber as journal_number,
        cast(ledger as number) as ledger,
        subledgerjournalentry as sub_ledger_journal_entry,
        cast(transferid as number) as transfer_id,
        subledgervoucher as sub_ledger_voucher,
        subledgervoucherdataareaid as sub_ledger_voucher_data_area_id,
        cast(ledgerentryjournal as number) as ledger_entry_journal,
        ledgerpostingjournal as ledger_posting_journal,
        ledgerpostingjournaldataareaid as ledger_posting_journal_data_area_id,
        cast(
            budgetsourceledgerentryposted as number
        ) as budget_source_ledger_entry_posted,
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

    from {{ ref("vw_generaljournalentry") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
