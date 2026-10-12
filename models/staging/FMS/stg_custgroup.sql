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
        cast(priceincludesalestax as number) as price_include_sales_tax,
        cast(ispublicsector_it as number) as is_public_sector_it,
        sysdatastatecode as sys_data_state_code,  {# sysdatastatecode unknown datatype#}
        cast(bankcustpaymidtable as number) as bank_cust_paymid_table,
        clearingperiod as clearing_period,
        custgroup as cust_group,
        cast(defaultdimension as number) as default_dimension,
        name, -- noqa: RF04 
        paymtermid as paym_term_id,
        taxgroupid as tax_group_id,
        taxperiodpaymentcode_pl as tax_period_payment_code_pl,
        cast(custwriteoffrefrecid as number) as cust_write_off_ref_rec_id,
        cast(custaccountnumseq as number) as cust_account_num_seq,
        accountingcurrencyexchangeratetype
            as accounting_currency_exchange_rate_type,  {# accountingcurrencyexchangeratetype unknown#}
        cast(
            reportingcurrencyexchangeratetype as number
        ) as reporting_currency_exchange_rate_type,
        to_timestamp_ntz(
            modifieddatetime, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as modified_date_time,
        modifiedby as modified_by,
        cast(modifiedtransactionid as number) as modified_transaction_id,
        to_timestamp_ntz(
            createddatetime, 'YYYY-MM-DD HH24:MI:SS.FF3'
        ) as created_date_time,
        createdby as created_by,
        createdtransactionid as created_transaction_id,
        dataareaid as data_area_id,
        recversion,
        partition,  -- noqa: RF04 
        sysrowversion as sys_row_version,  {# unknown datatype#}
        recid as rec_id,
        cast(tableid as number) as table_id,  {# unknown datatype#}
        cast(versionnumber as number) as version_number,  {# unknown datatype#}
        to_timestamp_ntz(createdon, 'YYYY-MM-DD HH24:MI:SS.FF3') as created_on,
        to_timestamp_ntz(modifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') as modified_on,
        cast(isdelete as boolean) as is_delete,
        {{ var('inserted_at' ) }} as inserted_at
    from {{ ref("vw_custgroup") }}
    {% if is_incremental() %}
        where
            to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3')
            > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
