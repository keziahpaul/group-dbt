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
        cast(bidonly as number) as bidonly,
        cast(blocked as number) as blocked,
        cashaccountingregime_es as cash_accounting_regime_es,  {# unknown datatype#}
        cast(changerequestallowoverride as number) as change_request_allow_override,
        cast(changerequestenabled as number) as change_request_enabled,
        cast(changerequestoverride as number) as change_request_override,
        cast(cisstatus as number) as cis_status,
        cast(companytype_mx as number) as company_type_mx,
        cast(disabledowned as number) as disabled_owned,
        cast(fatcafilingrequirement as number) as fatca_filing_requirement,
        cast(femaleowned as number) as female_owned,
        cast(foreignentityindicator as number) as foreign_entity_indicator,
        cast(foreignresident_ru as number) as foreign_resident_ru,
        cast(heir_it as number) as heir_it,
        cast(hubzone as number) as hub_zone,
        cast(icmscontributor_br as number) as icms_contributor_br,
        cast(incltax as number) as incl_tax,
        cast(inventprofiletype_ru as number) as invent_profile_type_ru,
        cast(ispaymfeecovered_jp as number) as is_paym_fee_covered_jp,
        cast(isresident_lv as number) as is_resident_lv,
        cast(locallyowned as number) as locally_owned,
        cast(mandatoryvatdate_pl as number) as mandatory_vatdate_pl,
        cast(matchingpolicy as number) as matching_policy,
        cast(minorityowned as number) as minority_owned,
        cast(nontaxable_br as number) as non_taxable_br,
        cast(offsetaccounttype as number) as offset_account_type,
        cast(onetimevendor as number) as one_time_vendor,
        cast(operationtype_mx as number) as operation_type_mx,
        cast(presencetype_br as number) as presence_type_br,
        cast(purchamountpurchaseorder as number) as purch_amount_purchase_order,
        cast(secondtin as number) as second_tin,
        cast(
            servicecodeondlvaddress_br as number
        ) as service_code_on_dlv_address_br,
        cast(smallbusiness as number) as small_business,
        cast(tax1099namechoice as number) as tax_1099_name_choice,
        cast(tax1099reports as number) as tax_1099_reports,
        cast(taxidtype as number) as tax_id_type,
        cast(taxwithholdcalculate as number) as tax_with_hold_calculate,
        cast(taxwithholdvendortype_th as number) as tax_with_hold_vendor_type_th,
        cast(unitedvatinvoice_lt as number) as united_vat_invoice_lt,
        cast(usecashdisc as number) as use_cash_disc,
        cast(vatpartnerkind_ru as number) as vat_partner_kind_ru,
        cast(vattaxagent_ru as number) as vat_tax_agent_ru,
        cast(vendconsumption_br as number) as vend_consumption_br,
        cast(vendortype_mx as number) as vendor_type_mx,
        cast(veteranowned as number) as veteran_owned,
        cast(w9 as number) as w9,
        cast(w9included as number) as w9_included,
        cast(
            vendvendorcollaborationtype as number
        ) as vend_vendor_collaboration_type,
        cast(
            withholdingtaxpayertype_mx as number
        ) as with_holding_tax_payer_type_mx,
        cast(
            originalvendorinreporting_it as number
        ) as original_vendor_in_reporting_it,
        cast(isselfinvoicevendor_it as number) as is_self_invoice_vendor_it,
        cast(workflowstate as number) as workflow_state,
        cast(iscprb_br as number) as iscprb_br,
        cast(cxmlorderenable as number) as cxm_lorder_enable,
        cast(vatnumtabletype as number) as vat_num_table_type,
        cast(overridesalestax as number) as override_sales_tax,
        accruesalestaxtype as accrue_sales_tax_type,  {# unknown datatype#}
        taxvendorchargetaxtolerancevalidation
            as tax_vendor_charge_tax_tolerance_validation,  {# unknown datatype#}
        cast(revenuetypology_it as number) as revenue_typology_it,
        cast(ispublicsector_it as number) as is_public_sector_it,
        cast(istaxationoverpayroll_br as number) as is_taxation_over_payroll_br,
        cast(einvoiceregister_it as number) as einvoice_register_it,
        cast(isunidentifiedbenef_br as number) as is_unidentified_benef_br,
        cast(itmimportcostingvendor as number) as itm_import_costing_vendor,
        cast(itmservicesprovider as number) as itm_services_provider,
        cast(itmvendtype as number) as itm_vend_type,
        cast(isappenda7paymreference as number) as is_append_a7_paym_reference,
        sysdatastatecode as sys_data_state_code,  {# unknown datatype#}
        taxwithholdgroup as tax_with_hold_group,
        residenceforeigncountryregionid as residence_foreign_country_region_id,
        paymtermid as paym_term_id,
        linedisc as line_disc,
        accountnum as account_num,
        bankaccount as bank_account,
        bankcentralbankpurposecode as bank_central_bank_purpose_code,
        bankcentralbankpurposetext as bank_central_bank_purpose_text,
        bankcentralbanktranstypecur_ru as bank_central_bank_trans_type_cur_ru,
        bankorderofpayment_ru as bank_order_of_payment_ru,
        birthcountycode_it as birth_county_code_it,
        birthplace as birth_place,
        to_timestamp_ntz(
            blockedreleasedate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as blocked_release_date,
        cashdisc as cash_disc,
        ccmnum_br,
        ciscompanyregnum as cis_company_reg_num,
        cisnationalinsurancenum as cis_national_insurance_num,
        cisuniquetaxpayerref as cis_unique_tax_payer_ref,
        to_timestamp_ntz(
            cisverificationdate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as cis_verification_date,
        cisverificationnum as cis_verification_num,
        clearingperiod as clearing_period,
        cnae_br,
        cnpjcpfnum_br,
        commercialregister as commercial_register,
        commercialregisterinsetnumber as commercial_register_in_set_number,
        commercialregistersection as commercial_register_section,
        companychainid as company_chain_id,
        companyidsiret as company_id_siret,
        cast(companynafcode as number) as company_naf_code,
        cast(consday_jp as number) as consday_jp,
        contactpersonid as contact_person_id,
        cast(creditmax as number) as credit_max,
        creditrating as credit_rating,
        curp_mx,
        currency,
        dba,
        cast(defaultdimension as number) as default_dimension,
        defaultinventstatusid as default_invent_status_id,
        destinationcodeid as destination_code_id,
        diotcountrycode_mx as diot_country_code_mx,
        dlvmode as dlv_mode,
        dlvterm as dlv_term,
        cast(enddisc as number) as end_disc,
        enterprisenumber as enterprise_number,
        ethnicoriginid as ethnic_origin_id,
        factoringaccount as factoring_account,
        finecode_br as fine_code_br,
        fiscalcode as fiscal_code,
        foreignerid_br as foreigner_id_br,
        foreigntaxregistration_mx as foreign_tax_registration_mx,
        freightzone as freight_zone,
        ienum_br,
        insscei_br,
        intbank_lv as int_bank_lv,
        interestcode_br as interest_code_br,
        inventlocation as invent_location,
        inventprofileid_ru as invent_profile_id_ru,
        inventsiteid as invent_site_id,
        invoiceaccount as invoice_account,
        itembuyergroupid as item_buyer_group_id,
        lineofbusinessid as line_of_business_id,
        cast(lvpaymtranscodes as number) as lv_paym_trans_codes,
        cast(maincontactworker as number) as main_contact_worker,
        markupgroup as mark_up_group,
        memo,  {# unknown datatype#}
        multilinedisc as multi_line_disc,
        namecontrol as name_control,
        nationality_mx,
        nit_br,
        numbersequencegroup as number_sequence_group,
        cast(offsetledgerdimension as number) as offset_ledger_dimension,
        organizationnumber as organization_number,
        orgid as org_id,
        cast(party as number) as party,
        paymdayid as paymday_id,
        paymid as paym_id,
        paymmode as paym_mode,
        paymsched as paym_sched,
        paymspec as paym_spec,
        pricegroup as price_group,
        purchcalendarid as purch_calendar_id,
        purchpoolid as purch_pool_id,
        rfc_mx,
        segmentid as segment_id,
        separatedivisionid_ru as separate_division_id_ru,
        stateinscription_mx as state_inscription_mx,
        structdepartment_ru as struct_department_ru,
        subsegmentid as sub_segment_id,
        suppitemgroupid as supp_item_group_id,
        tamrebategroupid as tam_rebate_group_id,
        cast(tax1099fields as number) as tax_1099_fields,
        tax1099regnum as tax_1099_reg_num,
        taxgroup as tax_group,
        taxperiodpaymentcode_pl as tax_period_payment_code_pl,
        vatnum as vat_num,
        vatoperationcode_ru as vat_operation_code_ru,
        cast(vendexceptiongroup as number) as vend_exception_group,
        vendgroup as vend_group,
        vendincomecode_br as vend_income_code_br,
        cast(vendinvoicedeclaration_is as number) as vend_invoice_declaration_is,
        venditemgroupid as vend_item_group_id,
        cast(
            vendorportaladministratorrecid as number
        ) as vendor_portal_administrator_rec_id,
        vendpaymfeegroup_jp as vend_paym_fee_group_jp,
        vendpricetolerancegroupid as vend_price_tolerance_group_id,
        youraccountnum as your_account_num,
        legalrepresentativecurp_mx as legal_representative_curp_mx,
        legalrepresentativename_mx as legal_representative_name_mx,
        legalrepresentativerfc_mx as legal_representative_rfc_mx,
        withholdingtypecode_mx as with_holding_type_code_mx,
        birthdate as birth_date,  {# unknown datatype#}
        regnum_w,
        enterprisecode as enterprise_code,
        cast(vatnumrecid as number) as vat_num_rec_id,
        purchaseshipcalendarid as purchase_ship_calendar_id,
        cast(
            taxvendorchargetaxtoleranceamount as number
        ) as tax_vendor_charge_tax_tolerance_amount,
        cast(
            taxvendorchargetaxtolerancepercent as number
        ) as tax_vendor_charge_tax_tolerance_percent,
        freenotesgroup_it as free_notes_group_it,
        coderevenuetypology_it as code_revenue_typology_it,
        itmfromport as itm_from_port,
        itmoverundertolerancegroupid as itm_over_under_tolerance_group_id,
        itmagent as itm_agent,
        itmvendaccount as itm_vend_account,
        itmcosttypegroupid as itm_cost_type_group_id,
        gupdiscountvendorclaimgroupname as gup_discount_vendor_claim_group_name,
        cast(avacutofftime as number) as ava_cutoff_time,
        cast(maximuma7invoices_dc as number) as maximum_a7_invoices_dc,
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

    from {{ ref("vw_vendtable") }}
    {% if is_incremental() %}
        where
            to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
