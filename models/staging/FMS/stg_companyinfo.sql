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
        cast(combinedfedstatefiler as number) as combined_fed_state_filer,
        cast(companytype_mx as number) as company_type_mx,
        cast(isconsolidationcompany as number) as is_consolidation_company,
        cast(iseliminationcompany as number) as is_elimination_company,
        cast(lastfilingindicator as number) as last_filing_indicator,
        cast(legalnature_it as number) as legal_nature_it,
        cast(planningcompany as number) as planning_company,
        cast(printinnkppinaddress_ru as number) as printinnkppinaddress_ru,
        cast(resident_w as number) as resident_w,
        cast(validate1099onentry as number) as validate_1099_on_entry,
        cast(printcorrinvoicelabel_de as number) as print_corr_invoice_label_de,
        cast(printenterpriseregister_no as number) as print_enter_prise_register_no,
        cast(
            localizationcountryregioncode as number
        ) as localization_country_region_code,
        cast(dashboardimagetype as number) as dashboard_image_type,
        cast(privacyconsent_dk as number) as privacy_consent_dk,
        cast(
            eeenablepersonaldatareadlog as number
        ) as eeenable_personal_data_read_log,
        cast(eeenablerolechangelog as number) as eeenable_role_change_log,
        cast(profitmarginscheme_ae as number) as profit_margin_scheme_ae,
        cast(vatrefund_ae as number) as vat_refund_ae,
        cast(vatoncustomerbehalf_ae as number) as vaton_customer_behalf_ae,
        sysdatastatecode as sys_data_state_code,
        accountant_lt,
        accountingpersonnel_jp as accounting_personnel_jp,
        accountofficerefnum,
        activitycode as activity_code,
        addrformat as addr_format,
        branchid as branch_id,
        businessactivity_sa as business_activity_sa,
        businessactivitydesc_sa as business_activity_desc_sa,
        businessnumber_ca as business_number_ca,
        cnae_br,
        companyregcomfr as company_reg_comfr,
        companyrepresentative_jp as company_representative_jp,
        to_timestamp_ntz(
            conversiondate, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as conversion_date,
        coregnum as co_reg_num,
        curp_mx,
        dataarea as data_area,
        dba,
        dvrid,
        enterprisecode as enterprise_code,
        ficreditorid_dk as fi_credit_orid_dk,
        filenumber_sa,
        fiscalcode_it as fiscal_code_it,
        giro,
        girocontract as giro_contract,
        girocontractaccount as giro_contract_account,
        head_lt,
        importvatnum as import_vatnum,
        importvatnumbranchid as import_vatnum_branch_id,
        intrastatcode as intrastat_code,
        issuingsignature as issuing_signature,
        key,
        legalformfr as legal_form_fr,
        legalrepresentativecurp_mx as legal_representative_curp_mx,
        legalrepresentativename_mx as legal_representative_name_mx,
        legalrepresentativerfc_mx as legal_representativer_fc_mx,
        namecontrol as name_control,
        orgid as org_id,
        paymroutingdnb as paym_routing_dnb,
        paymtradernumber as paym_trader_number,
        raliencorpcountry as ralien_corp_country,
        raliencorpname as ralien_corp_name,
        regnum as reg_num,
        rfc_mx,
        rfullname as r_full_name,
        siacode as sia_code,
        softwareidentificationcode_ca as software_identification_code_ca,
        stateinscription_mx as state_inscription_mx,
        tax1099regnum as tax_1099_reg_num,
        taxrepresentative as tax_representative,
        tcc,
        templatefolder_w as template_folder_w,
        upsnum as ups_num,
        vatnum as vat_num,
        vatnumbranchid as vat_num_branch_id,
        to_timestamp_ntz(
            businesscommenceddate_jp, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as business_commenced_date_jp,
        cast(businessinitialcapital_jp as float) as business_initial_capital_jp,
        businessitem_jp as business_item_jp,
        certifiedtaxaccountant_jp as certified_tax_accountant_jp,
        cuc_it,
        fss_ru,
        fssaccount_ru as fss_account_ru,
        legalrepresentative_jp as legal_representative_jp,
        organizationlegalform_ru as organization_legal_form_ru,
        personincharge_jp as person_in_charge_jp,
        pfregnum_ru as pf_reg_num_ru,
        to_timestamp_ntz(
            printcorrinvoicelabeleffdate_de, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as print_corr_invoice_label_effdate_de,
        subordinatecode as subordinate_code,
        taxgsthstaccountid_ca as tax_gsthst_account_id_ca,
        naics,
        bank,
        bankacctusedfor1099 as bank_acctused_for_1099,
        bankcentralbankpurposetext as bank_central_bank_purpose_text,
        bankcentralbankpurposecode as bank_central_bank_purpose_code,
        cast(companynafcode as number) as company_naf_code,
        cast(payminstruction1 as number) as paym_instruction1,
        cast(payminstruction2 as number) as paym_instruction2,
        cast(payminstruction3 as number) as paym_instruction3,
        cast(payminstruction4 as number) as paym_instruction4,
        shippingcalendarid as shipping_calendar_id,
        taxauthority_ru as tax_authority_ru,
        packmaterialfeelicensenum as pack_material_fee_license_num,
        cast(companyinitialcapital_fr as number) as company_initial_capital_fr,
        taxregimecode_mx as tax_regime_code_mx,
        cast(taxablepersonname_ae as number) as tax_able_person_name_ae,
        cast(declarantname_ae as number) as declarant_name_ae,
        cast(taxableagentname_ae as number) as taxable_agent_name_ae,
        cast(taxableagencyname_ae as number) as taxable_agency_name_ae,
        to_timestamp_ntz(
            modifieddatetime, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as modified_date_time,
        modifiedby as modified_by,
        cast(modifiedtransactionid as number) as modified_transaction_id,
        to_timestamp_ntz(
            createddatetime, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as created_date_time,
        createdby as created_by,
        cast(createdtransactionid as number) as created_transaction_id,
        dataareaid as data_area_id,
        cast(recversion as number) as recversion,
        cast(partition as number) as partition, -- noqa: RF04 
        cast(sysrowversion as number) as sys_row_version,
        cast(recid as number) as recid,
        cast(tableid as number) as table_id,
        cast(versionnumber as number) as version_number,
        to_timestamp_ntz(createdon, 'YYYY-MM-DD HH24:MI:SS.FF3') as created_on,
        to_timestamp_ntz(modifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') as modified_on,
        cast(isdelete as boolean) as is_delete,
        {{ var('inserted_at' ) }} as inserted_at
    from {{ ref("vw_companyinfo") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
