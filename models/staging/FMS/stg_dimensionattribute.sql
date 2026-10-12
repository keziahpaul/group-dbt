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
        cast(type as number) as type,   -- noqa: RF04
        cast(usetranslationnamemethod as number) as use_translation_name_method,
        cast(copyvaluesoncreate as number) as copy_values_on_create,
        cast(
            givederiveddimensionsprecedence as number
        ) as give_derived_dimensions_precedence,
        cast(isbalancing_psn as number) as is_balancing_psn,
        sysdatastatecode as sys_data_state_code,  {# unknown datatype#}
        cast(backingentitykeyfieldid as number) as back_ingentity_key_field_id,
        backingentitykeyfieldname as backing_entity_key_field_name,
        cast(backingentitytableid as number) as backing_entity_table_id,
        backingentitytablename as backing_entity_table_name,
        cast(backingentitytype as number) as backing_entity_type,
        cast(backingentityvaluefieldid as number) as backing_entity_value_field_id,
        backingentityvaluefieldname as backing_entity_value_field_name,
        hashkey,
        cast(keyattribute as number) as key_attribute,
        name,   -- noqa: RF04
        cast(nameattribute as number) as name_attribute,
        reportcolumnname as report_column_name,
        cast(translationkeyfieldid as number) as translation_key_field_id,
        translationkeyfieldname as translation_key_field_name,
        cast(
            translationlanguageidfieldid as number
        ) as translation_language_id_field_id,
        translationlanguageidfieldname as translation_language_id_field_name,
        cast(translationnamefieldid as number) as translation_name_field_id,
        translationnamefieldname as translation_name_field_name,
        cast(translationtableid as number) as translation_table_id,
        translationtablename as translation_table_name,
        cast(valueattribute as number) as value_attribute,
        viewname as view_name,
        translationviewkeyfieldname as translation_view_key_field_name,
        translationviewlanguageidfieldname
            as translation_view_language_id_field_name,
        translationviewname as translation_view_name,
        translationviewnamefieldname as translation_view_name_field_name,
        translationviewsystemlanguageidfieldname
            as translation_view_system_language_id_field_name,
        translationviewtranslatednamefieldname
            as translation_view_translated_name_field_name,
        translationviewvaluefieldname as translation_view_value_field_name,
        cast(translationviewid as number) as translation_view_id,
        cast(translationviewkeyfieldid as number) as translation_view_key_field_id,
        cast(
            translationviewlanguageidfieldid as number
        ) as translation_view_language_id_field_id,
        cast(
            translationviewnamefieldid as number
        ) as translation_view_name_field_id,
        cast(
            translationviewsystemlanguageidfieldid as number
        ) as translation_view_system_language_id_field_id,
        cast(
            translationviewtranslatednamefieldid as number
        ) as translation_view_translated_name_field_id,
        cast(
            translationviewvaluefieldid as number
        ) as translation_view_value_field_id,
        dimensionkeycolumnname as dimension_key_column_name,
        dimensionvaluecolumnname as dimension_value_column_name,
        cast(balancingdimension_psn as number) as balancing_dimension_psn,
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

    from {{ ref("vw_dimensionattribute") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
