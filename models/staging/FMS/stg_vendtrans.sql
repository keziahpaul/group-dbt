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
        cast(approved as number) as approved,
        cast(arrival as number) as arrival,
        cast(cancel as number) as cancel,
        cast(correct as number) as correct,
        cast(eurotriangulation as number) as euro_triangulation,
        cast(fixedexchrate as number) as fixed_exch_rate,
        cast(invoiceproject as number) as invoice_project,
        cast(prepayment as number) as pre_payment,
        cast(promissorynotestatus as number) as promissory_note_status,
        cast(rbovendtrans as number) as rbo_vendtrans,
        cast(settlement as number) as settlement,
        cast(transtype as number) as trans_type,
        cast(psnpurchasingcardtype as number) as psn_purchasing_card_type,
        cast(avaapinvoicetype as number) as avaap_invoice_type,
        cast(avafeeforwardingstatus as number) as ava_fee_forwarding_status,
        cast(pexatransactiontype as number) as pexa_transaction_type,
        sysdatastatecode as sys_data_state_code,  {# unknown datatype#}
        postingprofile as posting_profile,
        cast(accountingevent as number) as accounting_event,
        accountnum as account_num,
        cast(amountcur as number) as amount_cur,
        cast(amountmst as number) as amount_mst,
        to_timestamp_ntz(
            approveddate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as approved_date,
        cast(approver as number) as approver,
        bankcentralbankpurposecode as bank_central_bank_purpose_code,
        bankcentralbankpurposetext as bank_central_bank_purpose_text,
        cast(banklcimportline as number) as bank_lc_import_line,
        bankremittancefileid as bank_remittance_file_id,
        to_timestamp_ntz(
            cashdiscbasedate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as cash_disc_base_date,
        cashdisccode as cash_disc_code,
        to_timestamp_ntz(closed, 'YYYY-MM-DD HH24:MI:SS.FF3') as closed,
        companybankaccountid as company_bank_account_id,
        currencycode as currency_code,
        cast(defaultdimension as number) as default_dimension,
        to_timestamp_ntz(
            documentdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as document_date,
        documentnum as document_num,
        to_timestamp_ntz(duedate, 'YYYY-MM-DD HH24:MI:SS.FF3') as due_date,
        cast(exchadjustment as number) as exch_adjustment,
        cast(exchadjustmentreporting as number) as exch_adjustment_reporting,
        cast(exchrate as number) as exch_rate,
        cast(exchratesecond as number) as exch_rate_second,
        invoice,
        to_timestamp_ntz(
            invoicereleasedate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as invoice_release_date,
        journalnum as journal_num,
        to_timestamp_ntz(lastexchadj, 'YYYY-MM-DD HH24:MI:SS.FF3') as last_exch_adj,
        cast(lastexchadjrate as number) as last_exch_adj_rate,
        cast(lastexchadjratereporting as number) as last_exch_adj_rate_reporting,
        lastexchadjvoucher as last_exch_adj_voucher,
        lastsettleaccountnum as last_settle_account_num,
        lastsettlecompany as last_settle_company,
        to_timestamp_ntz(
            lastsettledate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as last_settle_date,
        lastsettlevoucher as last_settle_voucher,
        cast(offsetrecid as number) as offset_rec_id,
        paymid as paym_id,
        paymmode as paym_mode,
        paymreference as paym_reference,
        paymspec as paym_spec,
        paymtermid as paym_term_id,
        postingchangevoucher as posting_change_voucher,  {# unknown datatype#}
        postingprofileapprove as posting_profile_approve,
        postingprofilecancel as posting_profile_cancel,
        postingprofileclose as posting_profile_close,
        postingprofilereopen as posting_profile_reopen,
        promissorynoteid as promissory_note_id,
        cast(promissorynoteseqnum as number) as promissory_note_seq_num,
        cast(reasonrefrecid as number) as reason_ref_rec_id,
        releasedatecomment as release_date_comment,
        cast(remittanceaddress as number) as remittance_address,
        cast(remittancelocation as number) as remittance_location,
        cast(reportingcurrencyamount as number) as reporting_currency_amount,
        cast(reportingcurrencycrossrate as number) as reporting_currency_cross_rate,
        cast(
            reportingexchadjustmentrealized as number
        ) as reporting_exch_adjustment_realized,
        cast(
            reportingexchadjustmentunrealized as number
        ) as reporting_exch_adjustment_unrealized,
        cast(settleamountcur as number) as settle_amount_cur,
        cast(settleamountmst as number) as settle_amount_mst,
        cast(settleamountreporting as number) as settle_amount_reporting,
        cast(settletax1099amount as number) as settle_tax_1099_amount,
        cast(settletax1099stateamount as number) as settle_tax_1099_state_amount,
        cast(tax1099amount as number) as tax_1099_amount,
        to_timestamp_ntz(tax1099date, 'YYYY-MM-DD HH24:MI:SS.FF3') as tax_1099_date,
        cast(tax1099fields as number) as tax_1099_fields,
        tax1099num as tax_1099_num,
        cast(tax1099recid as number) as tax_1099_rec_id,
        tax1099state as tax_1099_state,
        cast(tax1099stateamount as number) as tax_1099_state_amount,
        taxinvoicepurchid as tax_invoice_purch_id,
        thirdpartybankaccountid as third_party_bank_account_id,
        to_timestamp_ntz(transdate, 'YYYY-MM-DD HH24:MI:SS.FF3') as trans_date,
        txt,
        cast(vendexchadjustmentrealized as number) as vend_exch_adjustment_realized,
        cast(
            vendexchadjustmentunrealized as number
        ) as vend_exch_adjustment_unrealized,
        vendpaymentgroup as vend_payment_group,
        voucher,
        cast(reportingcurrencyexchrate as number) as reporting_currency_exch_rate,
        cast(
            reportingcurrencyexchratesecondary as number
        ) as reporting_currency_exch_rate_secondary,
        arrivalaccountid as arrival_account_id,
        summaryaccountid as summary_account_id,
        to_timestamp_ntz(
            vendorvatdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as vendor_vat_date,
        cast(psnjournalizingdefinition as number) as psn_journalizing_definition,
        to_timestamp_ntz(
            avafeeforwardingcreatedatetimestamp, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as ava_fee_forwarding_create_date_timestamp,
        avalodgementcaseid as ava_lodgement_case_id,
        avalodgementreference as ava_lodgement_reference,
        cast(avapexabillingeventrecid as number) as ava_pexa_billing_event_rec_id,
        to_timestamp_ntz(
            avapexadatetimestamp, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as ava_pexa_date_timestamp,
        avasubscriberid as ava_subscriber_id,
        pexatransactionid as pexa_transaction_id,
        pexaworkspaceid as pexa_workspace_id,
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

    from {{ ref("vw_vendtrans") }}
    {% if is_incremental() %}
        where
            to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
