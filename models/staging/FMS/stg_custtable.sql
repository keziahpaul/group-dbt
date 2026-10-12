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
        cast(accountstatement as number) as account_statement,
        cast(affiliated_ru as number) as affiliated_ru,
        cast(blocked as number) as blocked,
        cast(companytype_mx as number) as company_type_mx,
        cast(
            creditcardaddressverification as number
        ) as credit_card_address_verification,
        cast(
            creditcardaddressverificationlevel as number
        ) as credit_card_address_verification_level,
        cast(
            creditcardaddressverificationvoid as number
        ) as credit_card_address_verification_void,
        cast(creditcardcvc as number) as credit_card_cvc,
        cast(custexcludecollectionfee as number) as cust_exclude_collection_fee,
        cast(custexcludeinterestcharges as number) as cust_exclude_interest_charges,
        cast(custfinaluser_br as number) as cust_final_user_br,
        cast(custwhtcontributiontype_br as number) as cust_wht_contribution_type_br,
        cast(einvoice as number) as einvoice,
        cast(einvoiceattachment as number) as einvoice_attachment,
        cast(entrycertificaterequired_w as number) as entry_certificate_required_w,
        cast(exportsales_pl as number) as export_sales_pl,
        cast(expressbilloflading as number) as express_bill_of_lading,
        cast(fednonfedindicator as number) as fed_non_fed_indicator,
        cast(fiscaldoctype_pl as number) as fiscal_doctype_pl,
        cast(forecastdmpinclude as number) as forecast_dmp_include,
        cast(foreignresident_ru as number) as foreign_resident_ru,
        cast(
            generateincomingfiscaldocument_br as number
        ) as generate_incoming_fiscal_document_br,
        cast(girotype as number) as giro_type,
        cast(girotypeaccountstatement as number) as giro_type_account_statement,
        cast(girotypecollectionletter as number) as giro_type_collection_letter,
        cast(girotypefreetextinvoice as number) as giro_type_free_text_invoice,
        cast(girotypeinterestnote as number) as giro_type_interest_note,
        cast(girotypeprojinvoice as number) as giro_type_proj_invoice,
        cast(icmscontributor_br as number) as icms_contributor_br,
        cast(incltax as number) as incl_tax,
        cast(
            intercompanyallowindirectcreation as number
        ) as inter_company_allow_in_direct_creation,
        cast(
            intercompanyautocreateorders as number
        ) as inter_company_auto_create_orders,
        cast(intercompanydirectdelivery as number) as inter_company_direct_delivery,
        cast(inventprofiletype_ru as number) as invent_profile_type_ru,
        cast(invoiceaddress as number) as invoice_address,
        cast(invoicepostingtype_ru as number) as invoice_posting_type_ru,
        cast(irs1099cindicator as number) as irs_1099_c_indicator,
        cast(isresident_lv as number) as is_resident_lv,
        cast(issueownentrycertificate_w as number) as issue_own_entry_certificate_w,
        cast(mandatorycreditlimit as number) as mandatory_credit_limit,
        cast(mandatoryvatdate_pl as number) as mandatory_vat_date_pl,
        cast(onetimecustomer as number) as one_time_customer,
        cast(packagedepositexcempt_pl as number) as package_deposit_excempt_pl,
        cast(pdsfreightaccrued as number) as pds_freight_accrued,
        cast(rfidcasetagging as number) as rf_id_case_tagging,
        cast(rfiditemtagging as number) as rf_id_item_tagging,
        cast(rfidpallettagging as number) as rf_id_pallet_tagging,
        cast(
            servicecodeondlvaddress_br as number
        ) as service_code_on_dlv_address_br,
        shipcarrierblindshipment as ship_carrier_blind_shipment,
        cast(shipcarrierfuelsurcharge as number) as ship_carrier_fuel_surcharge,
        cast(suframa_br as number) as suframa_br,
        cast(suframapiscofins_br as number) as suframa_pis_cofins_br,
        cast(taxwithholdcalculate_in as number) as tax_with_hold_calculate_in,
        cast(taxwithholdcalculate_th as number) as tax_with_hold_calculate_th,
        cast(unitedvatinvoice_lt as number) as united_vat_invoice_lt,
        cast(usecashdisc as number) as use_cash_disc,
        cast(usepurchrequest as number) as use_purch_request,
        cast(websalesorderdisplay as number) as web_sales_order_display,
        cast(einvoiceregister_it as number) as einvoice_register_it,
        cast(presencetype_br as number) as presence_type_br,
        cast(isexternallymaintained as number) as is_externally_maintained,
        cast(cfdienabled_mx as number) as cfdi_enabled_mx,
        cast(foreigntrade_mx as number) as foreign_trade_mx,
        cast(workflowstate as number) as workflow_state,
        cast(
            useoriginaldocumentasfacture_ru as number
        ) as use_original_document_as_facture_ru,
        cast(collectionlettercode as number) as collection_letter_code,
        cast(
            blockfloorlimituseinchannel as number
        ) as block_floor_limit_use_in_channel,
        cast(cfdiskipiepstaxes_mx as number) as cf_disk_ipieps_taxes_mx,
        cast(
            simplifytaxintgrexportdocvalidation_cn as number
        ) as simplify_tax_in_tgrex_port_doc_validation_cn,
        cast(simplenational_br as number) as simple_national_br,
        cast(vatnumtabletype as number) as vat_num_table_type,
        cast(overridesalestax as number) as override_sales_tax,
        prepaytype as prepay_type,  {# unknown datatype#}
        cast(usualexporter_it as number) as usual_exporter_it,
        cast(ispublicsector_it as number) as is_public_sector_it,
        cast(
            simplifytaxintgrexporttaxregvalidation_cn as number
        ) as simplify_tax_intgr_export_tax_reg_validation_cn,
        cast(printdynamicqrcode_in as number) as print_dynamic_qrcode_in,
        cast(invoicetype_w as number) as invoice_type_w,
        cast(cfditemporaryexport_mx as number) as cfdi_temporary_export_mx,
        cast(credmanexclude as number) as credman_exclude,
        cast(credmantitleheld as number) as credman_title_held,
        cast(credmanwithagency as number) as credman_with_agency,
        cast(credmancustunlimitedcredit as number) as credman_cust_unlimited_credit,
        cast(revrecdisableintercompany as number) as rev_rec_disable_inter_company,
        cast(
            avacustprinttransdetailoninvoice as number
        ) as ava_cust_print_trans_detail_on_invoice,
        cast(
            pexafeescollectedviaddoverride as number
        ) as pexa_fees_collected_vi_add_override,
        cast(
            pexageneratebillingdataextract as number
        ) as pexageneratebillingdataextract,
        cast(
            pexajurisdictionalsummaryoninvoice as number
        ) as pexa_jurisdictional_summary_on_invoice,
        cast(
            pexasendinvoicecsvextractelectronically as number
        ) as pexa_send_invoice_csv_extract_electronically,
        cast(pexaencryptfile as number) as pexa_encrypt_file,
        sysdatastatecode,  {# unknown datatype#}
        paymtermid as paym_ter_mid,
        linedisc as line_disc,
        taxwithholdgroup_th as tax_with_hold_group_th,
        partycountry as party_country,
        accountnum as account_num,
        agencylocationcode as agency_location_code,
        bankaccount as bank_account,
        bankcentralbankpurposecode as bank_central_bank_purpose_code,
        bankcentralbankpurposetext as bank_central_bank_purpose_text,
        cast(bankcustpaymidtable as number) as bank_cust_paym_id_table,
        birthcountycode_it as birth_county_code_it,
        birthplace_it as birth_place_it,
        cashdisc as cash_disc,
        cast(cashdiscbasedays as number) as cash_disc_base_days,
        ccmnum_br as ccm_num_br,
        clearingperiod as clearing_period,
        cnae_br,
        cnpjcpfnum_br,
        commercialregister as commercial_register,
        commercialregisterinsetnumber as commercial_register_inset_number,
        commercialregistersection as commercial_register_section,
        commissiongroup as commission_group,
        companychainid as company_chain_id,
        companyidsiret as company_idsiret,
        cast(companynafcode as number) as company_naf_code,
        cast(consday_jp as number) as consday_jp,
        contactpersonid as contact_person_id,
        cast(creditmax as number) as credit_max,
        creditrating as credit_rating,
        curp_mx,
        currency,
        custclassificationid as cust_classification_id,
        custgroup as cust_group,
        custitemgroupid as cust_item_group_id,
        cast(custtradingpartnercode as number) as cust_trading_partner_code,
        cast(defaultdimension as number) as default_dimension,
        cast(defaultdirectdebitmandate as number) as default_direct_debit_man_date,
        defaultinventstatusid as default_invent_status_id,
        destinationcodeid as destination_code_id,
        dlvmode,
        dlvreason as dlv_reason,
        dlvterm as dlv_term,
        einvoiceeannum as einvoice_eannum,
        enddisc as end_disc,
        enterprisenumber as enterprise_number,
        factoringaccount as factoring_account,
        federalcomments as federal_comments,
        finecode_br as fine_code_br,
        fiscalcode as fiscal_code,
        freightzone as freight_zone,
        identificationnumber as identification_number,
        ienum_br,
        insscei_br,
        intbank_lv as int_bank_lv,
        interestcode_br as interest_code_br,
        inventlocation as invent_location,
        inventprofileid_ru as invent_profile_id_ru,
        inventsiteid as invent_site_id,
        invoiceaccount as invoice_account,
        issuercountry_hu as issuer_country_hu,
        lineofbusinessid as line_of_business_id,
        cast(lvpaymtranscodes as number) as lv_paym_trans_codes,
        cast(maincontactworker as number) as main_contact_worker,
        markupgroup as mark_up_group,
        mcrmergedparent as mcr_merged_parent,
        mcrmergedroot as mcr_merged_root,
        memo,  {# unknown datatype#}
        multilinedisc as multi_line_disc,
        nit_br,
        numbersequencegroup as number_sequence_group,
        orderentrydeadlinegroupid as order_entry_deadline_group_id,
        orgid as org_id,
        ouraccountnum as our_account_num,
        packmaterialfeelicensenum as pack_material_fee_license_num,
        cast(party as number) as party,
        partystate as party_state,
        passportno_hu as passport_no_hu,
        paymdayid as paym_day_id,
        paymentreference_ee as payment_reference_ee,
        paymidtype as paym_id_type,
        paymmode as paym_mode,
        paymsched as paym_sched,
        paymspec as paym_spec,
        pdscustrebategroupid as pds_cust_rebate_group_id,
        pdsrebatetmagroup as pds_rebate_tma_group,
        pricegroup as price_group,
        residenceforeigncountryregionid_it
            as residence_foreign_country_region_id_it,
        rfc_mx,
        salescalendarid as sales_calendar_id,
        salesdistrictid as sales_district_id,
        salesgroup as sales_group,
        salespoolid as sales_pool_id,
        segmentid as segment_id,
        shipcarrieraccount as ship_carrier_account,
        shipcarrieraccountcode as ship_carrier_account_code,
        shipcarrierid as ship_carrier_id,
        stateinscription_mx as state_inscription_mx,
        statisticsgroup as statistics_group,
        subsegmentid as subsegment_id,
        suframanumber_br as suframa_number_br,
        suppitemgroupid as supp_item_group_id,
        taxgroup as tax_group,
        taxlicensenum as tax_license_num,
        taxperiodpaymentcode_pl as tax_period_payment_code_pl,
        vatnum as vat_num,
        vendaccount as vend_account,
        authorityoffice_it as authority_office_it,
        foreignerid_br as foreigner_id_br,
        cast(
            taxgstreliefgroupheading_my as number
        ) as tax_gst_relief_group_heading_my,
        foreigntaxregistration_mx as foreign_tax_registration_mx,
        cast(custwriteoffrefrecid as number) as cust_write_off_ref_rec_id,
        regnum_w,
        enterprisecode as enterprise_code,  {# unknown datatype#}
        taxbordernumber_fi,  {# unknown datatype#}
        birthdate_it as birth_date_it,  {# unknown datatype#}
        satpaymmethod_mx as sat_paym_method_mx,
        satpurpose_mx as sat_purpose_mx,
        cast(vatnumrecid as number) as vat_num_rec_id,
        prepaymentvalue as pre_payment_value,  {# unknown datatype#}
        freenotesgroup_it as free_notes_group_it,
        taxregimecode_mx as tax_regime_code_mx,
        satregistrationname_mx as sat_registration_name_mx,
        to_timestamp_ntz(
            credmaneligiblecreditlimitdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as cred_mane_ligible_credit_limit_date,
        credmangroupid as cred_man_group_id,
        credmannotes as cred_man_notes,  {# unknown datatype#}
        credmanaccountstatusid as cred_man_account_status_id,
        cast(credmaneligiblecreditmax as number) as cred_man_eligible_credit_max,
        to_timestamp_ntz(
            credmanbusinessstarted, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as cred_man_business_started,
        cast(credmancustcreditmaxalt as number) as cred_man_cust_credit_max_alt,
        credmaneligiblecreditlimitcurrency
            as cred_man_eligible_credit_limit_currency,
        to_timestamp_ntz(
            credmancustomersince, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as cred_man_customer_since,
        credmanstatusreasonid as cred_man_status_reason_id,
        credmancollectiongroupid as cred_man_collection_group_id,
        to_timestamp_ntz(
            credmancreditlimitexpirydate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as cred_man_credit_limit_expiry_date,
        to_timestamp_ntz(
            credmancreditlimitdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as cred_man_credit_limit_date,
        to_timestamp_ntz(
            credmanlastreviewdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as cred_man_last_review_date,
        to_timestamp_ntz(
            credmannextschedreviewdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as cred_man_next_sched_review_date,
        avaddfrequencycode as av_add_frequency_code,
        pexacustomerfilenamecode as pexa_customer_filename_code,
        pexacustomerporeference as pexa_customer_po_reference,
        pexapxdagent as pexa_pxd_agent,
        pexapxdstatus as pexa_pxd_status,
        pexasubscriberbillingentity as pexa_subscriber_billing_entity,
        transfertypeid as transfer_type_id,
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

    from {{ ref("vw_custtable") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
