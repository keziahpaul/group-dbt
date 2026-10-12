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
        cast(ledgerdimensiontype as number) as ledger_dimension_type,
        cast(hashversion as number) as hash_version,
        systemgeneratedjournalaccounttype as system_generated_journal_account_type,
        sysdatastatecode,  {# unknown datatype#}
        cast(accountstructure as number) as account_structure,
        displayvalue as display_value,
        dataareaforcreation as data_area_for_creation,
        implieddataareaid as implied_data_area_id,
        systemgeneratedjournalaccount as system_generated_journal_account,
        systemgeneratedjournalaccountvalue
            as system_generated_journal_account_value,
        cast(mainaccount as number) as main_account,
        mainaccountvalue as main_account_value,
        cast(businessunit as number) as business_unit,
        businessunitvalue as business_unit_value,
        cast(costcentre as number) as cost_centre,
        costcentrevalue as cost_centre_value,
        jurisdiction,
        jurisdictionvalue as jurisdiction_value,
        cast(subscribertype as number) as subscriber_type,
        subscribertypevalue as subscriber_type_value,
        cast(
            systemgeneratedattributebankaccount as number
        ) as system_generated_attribute_bank_account,
        systemgeneratedattributebankaccountvalue
            as system_generated_attribute_bank_account_value,
        cast(
            systemgeneratedattributecustomer as number
        ) as system_generated_attribute_customer,
        systemgeneratedattributecustomervalue
            as system_generated_attribute_customer_value,
        cast(
            systemgeneratedattributeemployee as number
        ) as system_generated_attribute_employee,
        systemgeneratedattributeemployeevalue
            as system_generated_attribute_employee_value,
        cast(
            systemgeneratedattributeemployee_ru as number
        ) as system_generated_attribute_employee_ru,
        systemgeneratedattributeemployee_ruvalue
            as system_generated_attribute_employee_ru_value,
        cast(
            systemgeneratedattributefixedasset as number
        ) as system_generated_attribute_fixed_asset,
        systemgeneratedattributefixedassetvalue
            as system_generated_attribute_fixed_asset_value,
        cast(
            systemgeneratedattributefixedassets_ru as number
        ) as system_generated_attribute_fixed_assets_ru,
        systemgeneratedattributefixedassets_ruvalue
            as system_generated_attribute_fixed_assets_ruvalue,
        cast(
            systemgeneratedattributeitem as number
        ) as system_generated_attribute_item,
        systemgeneratedattributeitemvalue as system_generated_attribute_item_value,
        cast(
            systemgeneratedattributeproject as number
        ) as system_generated_attribute_project,
        systemgeneratedattributeprojectvalue
            as system_generated_attribute_project_value,
        cast(
            systemgeneratedattributercash as number
        ) as system_generated_attributer_cash,
        systemgeneratedattributercashvalue
            as system_generated_attributer_cash_value,
        cast(
            systemgeneratedattributerdeferrals as number
        ) as system_generated_attributer_deferrals,
        systemgeneratedattributerdeferralsvalue
            as system_generated_attributer_deferrals_value,
        cast(
            systemgeneratedattributevendor as number
        ) as system_generated_attribute_vendor,
        systemgeneratedattributevendorvalue
            as system_generated_attribute_vendor_value,
        cast(agreement as number) as agreement,
        agreementvalue as agreement_value,
        cast(project as number) as project,
        projectvalue as project_value,
        cast(businessentity as number) as busines_sentity,
        businessentityvalue as busines_sentity_value,
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

    from {{ ref("vw_dimensionattributevaluecombination") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
