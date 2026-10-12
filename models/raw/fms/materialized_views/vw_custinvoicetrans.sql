 {{config( 
         materialized='materialized_view_snowflake' 
         )}} 
 
 {% set source_name= source('external_source_fms', 'custinvoicetrans') %}  
 {% set base_column_list= dbt_utils.star(from= source_name, except =['VALUE']) %} 
     select 
     {{ base_column_list }}
     from {{ source_name }}