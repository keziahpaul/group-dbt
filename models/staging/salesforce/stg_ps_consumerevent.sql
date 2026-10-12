
 {#  materialization, incremental strategy configured in dbt_project.yml #} 
 {% set src_view_name= ref('mv_ps_consumerevent__c') %}  
 {% set pk = 'Id'%} 
 
 with 

 initial as( 
     select  
            id as id
            ,   CAST(isdeleted as BOOLEAN) as is_deleted
            ,   name as name
            ,   to_timestamp_tz(createddate, 'YYYY- MM-DD"T"HH24:MI:SS.FF3TZHTZM') as created_date
            ,   createdbyid as created_by_id
            ,   to_timestamp_tz(lastmodifieddate, 'YYYY- MM-DD"T"HH24:MI:SS.FF3TZHTZM') as last_modified_date
            ,   lastmodifiedbyid as last_modified_by_id
            ,   to_timestamp_tz(systemmodstamp, 'YYYY- MM-DD"T"HH24:MI:SS.FF3TZHTZM') as system_modstamp
            ,   ps_consumer__c as ps_consumer_c
            ,   ps_consumeroffer__c as ps_consumer_offer_c
            ,   ps_eventstatusweight__c as ps_event_status_weight_c
            ,   ps_eventtype__c as ps_event_type_c
            ,   ps_property__c as ps_property_c
            --   , PS_CATEGORY__C as PS_CATEGORY_C  -- not readable from salesforce
            --   , PS_CATEGORYARTICLE__C as PS_CATEGORY_ARTICLE_C -- not readable from salesforce
              , CONVERT_TIMEZONE('Australia/Melbourne',system_modstamp) as system_modstamp_aest
            ,  case when isdeleted = true then 'D' else 'I' end as op
            ,  lead(op) over (partition by {{pk}} order by system_modstamp asc nulls first) as next_op
     from  {{ src_view_name }} 
     {% if is_incremental() %}
        where metadata_filename in {{ daily_refresh_stage(this,src_view_name) }}
     
     {% endif %} 
    ) 
    select 
     * exclude(next_op, op, system_modstamp_aest), 
     row_number() over (partition by {{pk}} order by system_modstamp asc nulls first) as row_num, 
     case when upper(op)='D' 
             then system_modstamp_aest 
         when upper(next_op) ='D' 
             then lead(system_modstamp_aest) over (partition by {{pk}} order by system_modstamp_aest asc nulls first)
         else null 
     end as deleted_at,
     {{ var('inserted_at' ) }} as inserted_at 
 from  initial