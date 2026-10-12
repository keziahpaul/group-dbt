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
        cast(assetgroup_in as number) as asset_group_in,
        cast(revrecexcludefromcarveout as number) as revrec_exclude_from_carve_out,
        cast(revrecmedianprice as number) as revrec_median_price,
        cast(
            revrecrevenuerecognitionenabled as number
        ) as revrec_revenue_recognition_enabled,
        cast(revrecrevenuetype as number) as revrec_revenue_type,
        sysdatastatecode as sys_data_state_code,  {# unknown datatype#}
        taxitemgroupidsales as tax_item_group_id_sales,
        duedatelimitgroupid_es as due_date_limit_group_id_es,
        itemgroupid as item_group_id,
        loadtemplateid as load_template_id,
        name,   -- noqa: RF04
        standarditemallocateid as standard_item_allocate_id,
        taxitemgroupidpurch as tax_item_group_id_purch,
        retailsaftstandardvatcode as retail_saft_standard_vat_code,
        revrecdefaultrevenuerecognitionschedule
            as revrec_default_revenue_recognition_schedule,
        cast(
            revrecmedianpricemaximumtolerance as number
        ) as revrec_median_price_maximum_tolerance,
        cast(
            revrecmedianpriceminimumtolerance as number
        ) as revrec_median_price_minimum_tolerance,
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

    from {{ ref("vw_inventitemgroup") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
