{% macro generate_schema_name(custom_schema_name, node) -%}
    {{pexa_one_data_au_dbt_common_lib.generate_schema_name(custom_schema_name, node)}}
{%- endmacro %}


{% macro get_list_of_tables_to_log(s3_base_path,logs_for, table_catalog,table_schema,db_name,schema_name,stage_name,file_format) %}
{# Execute dbt run --select dbt_artifacts for dbt logs to be pushed to snowflake#}
{#dbt run-operation get_list_of_tables_to_log --args '{s3_base_path: "Group/Logs/dev", logs_for: "dbt", table_catalog: "DEV_LOGGING", table_schema: "DBT_LOGS", db_name: "DEV_LOGGING", schema_name: "SPLUNK_LOGGING", stage_name: "DEV_LOGGING_STAGE",file_format: "DEV_LOGGING_FILE_FORMAT"}'    #}
{#dbt run-operation get_list_of_tables_to_log --args '{s3_base_path: "Group/Logs/dev", logs_for: "snowflake", table_catalog: "SNOWFLAKE", table_schema: "ACCOUNT_USAGE", db_name: "DEV_LOGGING", schema_name: "SPLUNK_LOGGING", stage_name: "DEV_LOGGING_STAGE",file_format: "DEV_LOGGING_FILE_FORMAT"}' #}
{#dbt run-operation get_list_of_tables_to_log --args '{s3_base_path: "Group/Logs/dev", logs_for: "fivetran", table_catalog: "DEV_LOGGING", table_schema: "FIVETRAN_LOGS", db_name: "DEV_LOGGING", schema_name: "SPLUNK_LOGGING", stage_name: "DEV_LOGGING_STAGE",file_format: "DEV_LOGGING_FILE_FORMAT"}'  #}

{#s3_base_path is the basefolder where you want to log in S3#}
{#logs_for is a variable to specify whether logs are for snowflake, dbt or fivetran. Also serves to access the seed file which contains tables list to be logged #}
{#table_catalog is database name where the tables to be logged are present. SNOWFLAKE / {env}_LOGGING #}
{#table_schema is schema name where the tables to be logged are present. ACCOUNT_USAGE / DBT_LOGS/FIVETRAN_LOGS #}
{#db_name  is database where external stage is available#}
{#schema_name  is schema where external stage is available#}
{#stage_name is the name of the stage#}
{#file_format is the name of fileformat#}
 {{pexa_one_data_au_dbt_common_lib.get_list_of_tables_to_log(s3_base_path,logs_for, table_catalog,table_schema,db_name,schema_name,stage_name,file_format) }}
{%endmacro%}


{% macro get_objects_to_unload(loads_for, table_catalog,table_schema,db_name,schema_name,stage_name,file_format,filter_condition =None,unload_object=None) %}
{# Execute dbt run --select dbt_artifacts for dbt logs to be pushed to snowflake#}
{#dbt run-operation get_objects_to_unload --args '{loads_for: "dbt", table_catalog: "DEV_LOGGING", table_schema: "DBT_LOGS", db_name: "DEV_LOGGING", schema_name: "SPLUNK_LOGGING", stage_name: "DEV_LOGGING_STAGE",file_format: "DEV_LOGGING_FILE_FORMAT"}'    #}
{#dbt run-operation get_objects_to_unload --args '{loads_for: "snowflake", table_catalog: "SNOWFLAKE", table_schema: "ACCOUNT_USAGE", db_name: "DEV_LOGGING", schema_name: "SPLUNK_LOGGING", stage_name: "DEV_LOGGING_STAGE",file_format: "DEV_LOGGING_FILE_FORMAT"}' #}
{#dbt run-operation get_objects_to_unload --args '{loads_for: "fivetran", table_catalog: "DEV_LOGGING", table_schema: "FIVETRAN_LOGS", db_name: "DEV_LOGGING", schema_name: "SPLUNK_LOGGING", stage_name: "DEV_LOGGING_STAGE",file_format: "DEV_LOGGING_FILE_FORMAT"}'  #}
{#dbt run-operation get_objects_to_unload --args '{loads_for: "inmoment", table_catalog: "DEV_GROUP_INT_DATASERVICES", table_schema: "SALESFORCE_DATASERVICES", db_name: "DEV_GROUP_INT_DATASERVICES", schema_name: "SALESFORCE_DATASERVICES", stage_name: "SALESFORCE_S3_OUTBOUND_STAGE",file_format: "CSV_FILE_FORMAT"}' #}
{#dbt run-operation get_objects_to_unload --args '{loads_for: "foreign_address", table_catalog: "DEV_GROUP_INT_DATASERVICES", table_schema: "SALESFORCE_DATASERVICES", db_name: "DEV_GROUP_INT_DATASERVICES", schema_name: "SALESFORCE_DATASERVICES", stage_name: "SALESFORCE_S3_OUTBOUND_STAGE",file_format: "CSV_FILE_FORMAT",filter_condition: "and settlement_date >=\"2024-08-08\" "}' #}
{#dbt run-operation get_objects_to_unload --args "{loads_for: 'foreign_address', table_catalog: 'DEV_GROUP_INT_DATASERVICES', table_schema: 'SALESFORCE_DATASERVICES', db_name: 'DEV_GROUP_INT_DATASERVICES', schema_name: 'SALESFORCE_DATASERVICES', stage_name: 'SALESFORCE_S3_OUTBOUND_STAGE',file_format: 'CSV_FILE_FORMAT',filter_condition: 'and settlement_date >=''2024-08-08'''}" #}
{#dbt run-operation get_objects_to_unload --args '{loads_for: "dna", table_catalog: "DEV_GROUP_INT_DATASERVICES", table_schema: "SALESFORCE_DATASERVICES", db_name: "DEV_GROUP_INT_DATASERVICES", schema_name: "SALESFORCE_DATASERVICES", stage_name: "SALESFORCE_S3_OUTBOUND_STAGE",file_format: "CSV_FILE_FORMAT"}'#}

{#s3_base_path is the basefolder where you want to log in S3#}
{#loads_for is a variable to specify whether unload is for logs of snowflake, dbt or fivetran or another table. Also serves to access the seed file which contains tables list to be unloaded #}
{#table_catalog is database name where the tables to be unloaded are present. SNOWFLAKE / {env}_LOGGING #}
{#table_schema is schema name where the tables to be unloaded are present. ACCOUNT_USAGE / DBT_LOGS/FIVETRAN_LOGS #}
{#db_name  is database where external stage and file format is available#}
{#schema_name  is schema where external stage and file format is available#}
{#stage_name is the name of the stage#}
{#file_format is the name of fileformat#}
 {{pexa_one_data_au_dbt_common_lib.get_objects_to_unload(loads_for,table_catalog,table_schema,db_name,schema_name,stage_name,file_format,filter_condition,unload_object) }}
{%endmacro%}

{% macro scd_materialization() -%}
    {{pexa_one_data_au_dbt_common_lib.scd_materialization()}}
{%- endmacro %}
{% macro column_count_check(model, source, source_exclude, model_exclude) %}
    {{ pexa_one_data_au_dbt_common_lib.column_count_check(model, source, source_exclude, model_exclude) }}
{% endmacro %}

{% macro is_newer() -%}
    {{ pexa_one_data_au_dbt_common_lib.is_newer(*varargs, **kwargs) }}
{%- endmacro %}
