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
        cast(isblockedformanualentry as number) as is_blocked_for_manual_entry,
        cast(isdeleted as number) as is_deleted,
        cast(issuspended as number) as is_suspended,
        cast(istotal as number) as is_total,
        pendingsuccessfuldeletevalidation as pending_successful_delete_validation,  {# unknown datatype#}
        cast(isbalancing_psn as number) as is_balancing_psn,
        sysdatastatecode as sys_data_state_code,  {# unknown datatype#}
        to_timestamp_ntz(activefrom, 'YYYY-MM-DD HH24:MI:SS.FF3') as active_from,
        to_timestamp_ntz(activeto, 'YYYY-MM-DD HH24:MI:SS.FF3') as active_to,
        cacheddisplayvalue as cached_display_value,  {# unknown datatype#}
        cast(dimensionattribute as number) as dimension_attribute,
        cast(entityinstance as number) as entity_instance,
        groupdimension as group_dimension,
        hashkey,
        cachedinvariantname as cached_invariant_name,  {# unknown datatype#}
        cachedname as cached_name,  {# unknown datatype#}
        displayvalue as display_value,
        backingrecorddataareaid as backing_record_data_area_id,
        cast(originalentityinstance as number) as original_entity_instance,
        cast(owner as number) as owner,    -- noqa: RF04
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

    from {{ ref("vw_dimensionattributevalue") }}
    {% if is_incremental() %}
        where to_timestamp_ntz(sinkmodifiedon, 'YYYY-MM-DD HH24:MI:SS.FF3') > (select last_extracted_ts from latest_ts)
    {% endif %}
)

select *
from initial
