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
        cast(canbereversed as number) as can_be_reversed,
        cast(reversetrans_ru as number) as reverse_trans_ru,
        cast(transtype as number) as trans_type,
        sysdatastatecode as sys_data_state_code,  {# unknown datatype#}
        accountnum as account_num,
        cast(
            cashdiscountledgerdimension as number
        ) as cash_discount_ledger_dimension,
        cast(defaultdimension as number) as default_dimension,
        to_timestamp_ntz(duedate, 'YYYY-MM-DD HH24:MI:SS.FF3') as duedate,
        eusaleslist as eu_sales_list,
        cast(exchadjustment as number) as exch_adjustment,
        cast(exchadjustmentreporting as number) as exch_adjustment_reporting,
        cast(fineamount_br as number) as fine_amount_br,
        finecode_br as fine_code_br,
        cast(interestamount_br as number) as interest_amount_br,
        interestcode_br as interest_code_br,
        to_timestamp_ntz(
            lastinterestdatedummy, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as last_interest_date_dummy,
        offsetaccountnum as offset_account_num,
        offsetcompany as offset_company,
        cast(offsetrecid as number) as offset_rec_id,
        offsettransvoucher as offset_trans_voucher,
        cast(pennydiff as number) as penny_diff,
        cast(remittanceaddress as number) as remittance_address,
        cast(reversedrecid_ru as number) as reversed_rec_id_ru,
        cast(settleamountcur as number) as settle_amount_cur,
        cast(settleamountmst as number) as settle_amount_mst,
        cast(settleamountreporting as number) as settle_amount_reporting,
        cast(settlementgroup as number) as settlement_group,
        settlementvoucher as settlement_voucher,
        cast(settletax1099amount as number) as settle_tax_1099_amount,
        cast(settletax1099stateamount as number) as settle_tax_1099_state_amount,
        statusvoucher as status_voucher,
        taxvoucher_ru as tax_voucher_ru,
        thirdpartybankaccountid as third_party_bank_account_id,
        transcompany as trans_company,
        to_timestamp_ntz(transdate, 'YYYY-MM-DD HH24:MI:SS.FF3') as trans_date,
        cast(transrecid as number) as trans_rec_id,
        cast(utilizedcashdisc as number) as utilized_cash_disc,
        cast(vattaxagentamount_ru as number) as vat_tax_agent_amount_ru,
        to_timestamp_ntz(
            vendcashdiscdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as vend_cash_disc_date,
        vendpaymentgroup as vend_payment_group,
        to_timestamp_ntz(
            reportingdate_ru, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as reporting_date_ru,
        to_timestamp_ntz(closeddate, 'YYYY-MM-DD HH24:MI:SS.FF3') as closed_date,
        cast(transopen as number) as trans_open,
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
        {{ var('inserted_at') }} as inserted_at

    from {{ ref("vw_vendsettlement") }}
    {% if is_incremental() %}
        where
            to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
