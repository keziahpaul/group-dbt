 {{config( 
         materialized='materialized_view_snowflake' 
         )}} 
 
 {% set source_name= source('SALESFORCE_S3', 'contact') %}  
 {% set base_column_list= dbt_utils.star(from= source_name, except =['VALUE']) %} 
     select 
     METADATA$FILENAME as metadata_filename,
     {{ base_column_list }}
     from {{ source_name }}
     