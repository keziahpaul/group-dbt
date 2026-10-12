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
        cast(abccontributionmargin as number) as abc_contribution_margin,
        cast(abcrevenue as number) as abc_revenue,
        cast(abctieup as number) as abc_tie_up,
        cast(abcvalue as number) as abc_value,
        cast(autoreportfinished as number) as auto_report_finished,
        cast(
            batchmergedatecalculationmethod as number
        ) as batch_merge_date_calculation_method,
        cast(bommanualreceipt as number) as bom_manual_receipt,
        cast(costmodel as number) as cost_model,
        cast(fiscallifoavoidcalc as number) as fiscallifo_avoid_calc,
        cast(fiscallifonormalvaluecalc as number) as fiscallifo_normal_value_calc,
        cast(forecastdmpinclude as number) as forecast_dmp_include,
        cast(icmsonservice_br as number) as icmson_service_br,
        cast(intrastatexclude as number) as intra_stat_exclude,
        cast(itemdimcostprice as number) as item_dim_cost_price,
        cast(itemtype as number) as item_type,
        cast(matchingpolicy as number) as matching_policy,
        cast(pdspotencyattribrecording as number) as pds_potency_attrib_recording,
        cast(pdsvendorcheckitem as number) as pds_vendor_check_item,
        cast(phantom as number) as phantom,
        cast(pmfproducttype as number) as pmf_product_type,
        cast(prodflushingprincip as number) as prod_flushing_princip,
        cast(purchmodel as number) as purch_model,
        cast(salesmodel as number) as sales_model,
        cast(salespricemodelbasic as number) as sales_price_model_basic,
        cast(skipintracompanysync_ru as number) as skip_intra_company_sync_ru,
        cast(taxationorigin_br as number) as taxation_origin_br,
        cast(usealtitemid as number) as use_alt_item_id,
        cast(dsa_in as number) as dsa_in,
        cast(exciserecordtype_in as number) as excise_record_type_in,
        cast(exempt_in as number) as exempt_in,
        cast(scaleindicator_br as number) as scale_indicator_br,
        cast(nongst_in as number) as nongst_in,
        cast(hmimindicator as number) as hmim_indicator,
        cast(coodualuseproduct as number) as coo_dual_use_product,
        preventphysicaldimensionsync as prevent_physical_dimension_sync,  {# unknown datatype#}
        cast(bomwhsreleasepolicy as number) as bomwhs_release_policy,
        cast(displayhazard_mx as number) as display_hazard_mx,
        cast(bundle as number) as bundle,
        cast(revrecexcludefromcarveout as number) as revrec_exclude_from_carveout,
        cast(revrecmedianprice as number) as revrec_median_price,
        cast(
            revrecrevenuerecognitionenabled as number
        ) as revrec_revenue_recognition_enabled,
        cast(revrecrevenuetype as number) as revrec_revenue_type,
        cast(revrecbundle as number) as revrec_bundle,
        cast(pexadisplayproduct as number) as pexa_display_product,
        cast(
            pexasponsorservicefeepayable as number
        ) as pexa_sponsor_service_fee_payable,
        cast(
            pexaexcludeitemfrominvoicing as number
        ) as pexa_exclude_item_from_invoicing,
        cast(pexaproductexpired as number) as pexa_product_expired,
        sysdatastatecode as sys_data_state_code,  {# unknown datatype#}
        itemid as item_id,
        alcoholmanufacturerid_ru as alcohol_manufacturer_id_ru,
        alcoholproductiontypeid_ru as alcohol_production_type_id_ru,
        cast(alcoholstrength_ru as number) as alcohol_strength_ru,
        altconfigid as alt_config_id,
        altinventcolorid as alt_invent_color_id,
        altinventsizeid as alt_invent_size_id,
        altinventstyleid as alt_invent_style_id,
        altinventversionid as alt_invent_version_id,
        altitemid as alt_item_id,
        cast(approxtaxvalue_br as number) as approx_tax_value_br,
        assetgroupid_ru as asset_group_id_ru,
        assetid_ru as asset_id_ru,
        batchnumgroupid as batch_num_group_id,
        bomcalcgroupid as bom_calc_group_id,
        cast(bomlevel as number) as bom_level,
        bomunitid as bom_unit_id,
        brandcodeid_mx as brand_code_id_mx,
        commissiongroupid as commission_group_id,
        costgroupid as cost_group_id,
        cast(
            customsexporttariffcodetable_in as number
        ) as custom_sex_port_tariff_code_table_in,
        cast(
            customsimporttariffcodetable_in as number
        ) as custom_sim_port_tariff_code_table_in,
        cast(defaultdimension as number) as default_dimension,
        cast(density as number) as density,
        cast(depth as number) as depth,
        exceptioncode_br as exception_code_br,
        cast(excisetariffcodes_in as number) as excise_tariff_codes_in,
        cast(eximproductgrouptable_in as number) as exim_product_group_table_in,
        cast(fiscallifonormalvalue as number) as fiscal_lifo_normal_value,
        cast(grossdepth as number) as gross_depth,
        cast(grossheight as number) as gross_height,
        cast(grosswidth as number) as gross_width,
        cast(height as number) as height,
        cast(intrastatcommodity as number) as intra_stat_commodity,
        intrastatprocid_cz as intra_stat_proc_id_cz,
        cast(inventfiscallifogroup as number) as invent_fiscal_lifo_group,
        inventproducttype_br as invent_product_type_br,
        itembuyergroupid as item_buyer_group_id,
        itempricetolerancegroupid as item_price_tolerance_group_id,
        markupcode_ru as mark_up_code_ru,
        cast(minimumpalletquantity as number) as minimum_pallet_quantity,
        namealias as name_alias,
        cast(netweight as number) as net_weight,
        cast(ngpcodestable_fr as number) as ngp_code_stable_fr,
        nrtaxgroup_lv as nr_tax_group_lv,
        origcountryregionid as orig_country_region_id,
        origcountyid as orig_county_id,
        origstateid as orig_state_id,
        packaginggroupid as packaging_group_id,
        packing_ru,
        pdsbaseattributeid as pds_base_attribute_id,
        cast(pdsbestbefore as number) as pds_best_before,
        cast(pdscwwmsminimumpalletqty as number) as pds_cwwms_minimum_pallet_qty,
        cast(pdscwwmsqtyperlayer as number) as pds_cwwms_qty_per_layer,
        cast(pdscwwmsstandardpalletqty as number) as pds_cwwms_standard_pallet_qty,
        pdsfreightallocationgroupid as pds_freight_allocation_group_id,
        pdsitemrebategroupid as pds_item_rebate_group_id,
        cast(pdsshelfadvice as number) as pds_shelf_advice,
        cast(pdsshelflife as number) as pds_shelf_life,
        cast(pdstargetfactor as number) as pds_target_factor,
        pkwiucode_pl as pkwiu_code_pl,
        pmfplanningitemid as pmf_planning_item_id,
        cast(pmfyieldpct as number) as pmf_yield_pct,
        primaryvendorid as primary_vendor_id,
        prodgroupid as prod_group_id,
        prodpoolid as prod_pool_id,
        cast(product as number) as product,
        projcategoryid as proj_category_id,
        propertyid as property_id,
        cast(qtyperlayer as number) as qty_per_layer,
        reqgroupid as req_group_id,
        sadratecode_pl as sad_rate_code_pl,
        cast(salescontributionratio as number) as sales_contribution_ratio,
        cast(salespercentmarkup as number) as sales_percent_mark_up,
        cast(scrapconst as number) as scrap_const,
        cast(scrapvar as number) as scrap_var,
        serialnumgroupid as serial_num_group_id,
        cast(servicecodetable_in as number) as service_code_table_in,
        cast(sortcode as number) as sort_code,
        standardconfigid as standard_config_id,
        standardinventcolorid as standard_invent_color_id,
        standardinventsizeid as standard_invent_size_id,
        standardinventstyleid as standard_invent_style_id,
        standardinventversionid as standard_invent_version_id,
        cast(standardpalletquantity as number) as standard_pallet_quantity,
        cast(statisticsfactor as number) as statistics_factor,
        cast(taraweight as number) as tara_weight,
        taxfiscalclassification_br as tax_fiscal_classification_br,
        cast(taxpackagingqty as number) as tax_packaging_qty,
        taxservicecode_br as tax_service_code_br,
        cast(unitvolume as number) as unit_volume,
        cast(width as number) as width,
        cast(wmsarrivalhandlingtime as number) as wms_arrival_handling_time,
        wmspallettypeid as wms_pallet_type_id,
        cast(wmspickingqtytime as number) as wms_picking_qty_time,
        intracode as intra_code,  {# unknown datatype#}
        satcodeid_mx as sat_code_id_mx,
        sattarifffraction_mx as sattariff_fraction_mx,
        cast(hsncodetable_in as number) as hsn_code_table_in,
        cast(
            serviceaccountingcodetable_in as number
        ) as service_accounting_code_table_in,
        productlifecyclestateid as product_lifecycle_state_id,
        cnpj_br,
        cast(taxratetype as number) as tax_rate_type,
        cast(intrastatchargeperkg as number) as intra_stat_charge_per_kg,
        coodualusecode as coo_dual_use_code,
        cast(costbomlevel as number) as cost_bom_level,
        freenotesgroup_it as free_notes_group_it,
        itmarrivalgroupid as it_marrival_group_id,
        itmcommoditycodeid as itm_commodity_code_id,
        itmcustomsdescid as itm_customs_desc_id,
        itmoverundertolerancegroupid as itm_over_under_tolerance_group_id,
        itmcosttypegroupid as itm_cost_type_group_id,
        itmcosttransfergroupid as itm_cost_transfer_group_id,
        revrecdefaultrevenuerecognitionschedule
            as revrec_default_revenue_recognition_schedule,
        cast(
            revrecmedianpricemaximumtolerance as number
        ) as revrec_median_price_maximum_tolerance,
        cast(
            revrecmedianpriceminimumtolerance as number
        ) as revrec_median_price_minimum_tolerance,
        pexaproductcategoryid as pexa_product_category_id,
        pexatransactiontypeid as pexa_transaction_type_id,
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

    from {{ ref("vw_inventtable") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
