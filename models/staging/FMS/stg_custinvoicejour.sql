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
        cast(backorder as number) as back_order,
        cast(einvoicelinespecific as number) as einvoice_line_specific,
        cast(girotype as number) as giro_type,
        cast(incltax as number) as incl_tax,
        cast(intercompanyposted as number) as inter_company_posted,
        cast(iscorrection as number) as is_correction,
        cast(listcode as number) as list_code,
        cast(onetimecustomer as number) as one_time_customer,
        cast(prepayment as number) as pre_payment,
        cast(proforma as number) as proforma,
        cast(refnum as number) as ref_num,
        cast(returnstatus as number) as return_status,
        cast(salestype as number) as sales_type,
        cast(shipcarrierblindshipment as number) as ship_carrier_blind_shipment,
        cast(taxprintoninvoice as number) as tax_print_on_invoice,
        cast(taxspecifybyline as number) as tax_specify_by_line,
        cast(triangulation as number) as triangulation,
        cast(updated as number) as updated,
        cast(sentelectronically as number) as sent_electronically,
        cast(provisionalassessment_in as number) as provisional_assessment_in,
        cast(postedstate as number) as posted_state,
        cast(commissiontype_it as number) as commission_type_it,
        cast(printdynamicqrcode_in as number) as print_dynamic_qrcode_in,
        cast(invoicetype_w as number) as invoicetype_w,
        cast(subbillsuppresschilditems as number) as sub_bill_suppress_child_items,
        cast(avaprocessedbyddjob as number) as ava_processed_bydd_job,
        cast(avabillingtranstype as number) as ava_billing_trans_type,
        cast(pexasettlementindicator as number) as pexa_settlement_indicator,
        cast(pexatransactiontype as number) as pexa_transaction_type,
        cast(
            pexabillingextractsendstatus as number
        ) as pexa_billing_extract_send_status,
        sysdatastatecode as sys_data_state_code,  {# unknown#}
        orderaccount as order_account,
        invoiceid as invoice_id,
        cast(banklcexportline as number) as banklc_export_line,
        billofladingid as bill_of_lading_id,
        cast(cashdisc as number) as cash_disc,
        to_timestamp_ntz(
            cashdiscbasedate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as cash_disc_base_date,
        cashdisccode as cash_disc_code,
        to_timestamp_ntz(
            cashdiscdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as cash_disc_date,
        cast(cashdiscpercent as number) as cash_disc_percent,
        contactpersonid as contact_person_id,
        cast(covstatus as number) as cov_status,
        currencycode as currency_code,
        custgroup as cust_group,
        customerref as customer_ref,
        cast(defaultdimension as number) as default_dimension,
        deliveryname as delivery_name,
        cast(deliverypostaladdress as number) as delivery_postal_address,
        cast(directdebitmandate as number) as direct_debit_mandate,
        dlvmode as dlv_mode,
        dlvterm as dlv_term,
        to_timestamp_ntz(
            documentdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as document_date,
        documentnum as document_num,
        to_timestamp_ntz(duedate, 'YYYY-MM-DD HH24:MI:SS.FF3') as due_date,
        einvoiceaccountcode as einvoice_account_code,
        cast(enddisc as number) as end_disc,
        cast(enddiscmst as number) as end_disc_mst,
        enterprisenumber as enterprise_number,
        eusaleslist as eu_sales_list,
        cast(exchrate as number) as exch_rate,
        cast(exchratesecondary as number) as exch_rate_secondary,
        to_timestamp_ntz(
            fixedduedate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as fixed_due_date,
        intercompanycompanyid as inter_company_companyid,
        intercompanypurchid as inter_company_purchid,
        intrastatdispatch as intrastat_dispatch,
        to_timestamp_ntz(
            intrastatfulfillmentdate_hu, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as intrastat_fulfillment_date_hu,
        inventlocationid as invent_location_id,
        invoiceaccount as invoice_account,
        cast(invoiceamount as number) as invoice_amount,
        cast(invoiceamountmst as number) as invoice_amount_mst,
        to_timestamp_ntz(invoicedate, 'YYYY-MM-DD HH24:MI:SS.FF3') as invoice_date,
        cast(invoicepostaladdress as number) as invoice_postal_address,
        cast(invoiceroundoff as number) as invoice_round_off,
        cast(invoiceroundoffmst as number) as invoice_round_off_mst,
        invoicingname as invoicing_name,
        languageid as language_id,
        ledgervoucher as ledger_voucher,
        log,
        cast(mcrdueamount as number) as mcr_due_amount,
        mcremail as mcr_email,
        cast(mcrpaymamount as number) as mcr_paym_amount,
        numbersequencegroup as number_sequence_group,
        cast(olapcostvalue as number) as olap_cost_value,
        cast(onaccountamount as number) as on_account_amount,
        parmid as parm_id,
        paymdayid,
        payment,
        paymentsched as payment_sched,
        paymid as paym_id,
        postingprofile as posting_profile,
        cast(printedoriginals as number) as printed_originals,
        printmgmtsiteid as print_mgmtsite_id,
        purchaseorder as purchase_order,
        cast(qty as number) as qty,
        rcsaleslist_uk,
        cast(reasontableref as number) as reason_table_ref,
        to_timestamp_ntz(
            receiptdateconfirmed_es, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as receipt_date_confirmed_es,
        returnitemnum as return_it_emnum,
        returnreasoncodeid as return_reason_code_id,
        cast(reversechargeamount as number) as reverse_charge_amount,
        cast(reversedrecid as number) as reverse_drec_id,
        cast(salesbalance as number) as sales_balance,
        cast(salesbalancemst as number) as sales_balance_mst,
        salesid as sales_id,
        salesoriginid as sales_origin_id,
        cast(sourcedocumentheader as number) as source_document_header,
        cast(sourcedocumentline as number) as source_document_line,
        cast(sumlinedisc as number) as sum_line_disc,
        cast(sumlinediscmst as number) as sum_line_disc_mst,
        cast(summarkup as number) as sum_mark_up,
        cast(summarkupmst as number) as sum_mark_up_mst,
        cast(sumtax as number) as sum_tax,
        cast(sumtaxmst as number) as sum_tax_mst,
        taxgroup as tax_group,
        taxinvoicesalesid as tax_invoice_sales_id,
        taxitemgroup as tax_item_group,
        cast(transportationdocument as number) as transportation_document,
        vatnum as vat_num,
        cast(volume as number) as volume,   -- noqa: RF04
        cast(weight as number) as weight,
        cast(workersalestaker as number) as worker_sales_taker,
        cast(reversecharge_uk as number) as reversecharge_uk,
        cast(taxid as number) as tax_id,
        cast(partytaxid as number) as party_tax_id,
        cast(
            reportingcurrencyexchangerate as number
        ) as reporting_currency_exchange_rate,
        cast(
            reportingcurrencyexchangeratesecondary as number
        ) as reporting_currency_exchange_rate_secondary,
        cast(fintag as number) as fin_tag,
        cast(headertax as number) as header_tax,
        to_timestamp_ntz(
            intentletterfromdate_it, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as intent_letter_from_date_it,
        intentletterid_it as intent_letter_id_it,
        intentletterinternalid_it as intent_letter_internal_id_it,
        to_timestamp_ntz(
            intentlettertodate_it, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as intent_letter_to_date_it,
        qrcode_sa,
        cast(
            electronicinvoiceframeworktype_fr as number
        ) as electronic_invoice_framework_type_fr,
        servicecode_fr as service_code_fr,
        projectmanager_fr as project_manager_fr,
        cast(servicecoderefrecid as number) as service_code_refrec_id,
        avasummaryinvoiceid as ava_summary_invoiceid,
        pexaworkspaceid as pexa_workspace_id,
        propdevsummaryinvoiceid as prop_dev_summary_invoice_id,
        propdevpropertydevelopername as prop_dev_property_developer_name,
        propdevemailrecipient as prop_dev_email_recipient,
        pexasubscriberrole as pexa_subscriber_role,
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
    from {{ ref("vw_custinvoicejour") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
