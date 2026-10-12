{% macro daily_refresh_stage (model_name, source_name) %}
    {% set src_ext_tbl_name= source_name|replace('vw_','')   %}
    {% set files_registered_new_query %}
        with get_last_refresh_dt as ( select max(inserted_at) as last_run_time
        from {{model_name}} )
        select  distinct file_name
        from table(
            {{ env_var('DBT_GROUP_RAW_DB') }}.information_schema.EXTERNAL_TABLE_FILE_REGISTRATION_HISTORY(
                TABLE_NAME => '{{src_ext_tbl_name}}'))
        join get_last_refresh_dt on 1=1
        where  job_created_time >= last_run_time and
         lower(operation_status) in ('registered_new','registered_update')
    {% endset %}
    {% if execute %}
     {% set result=run_query('ALTER EXTERNAL TABLE '+src_ext_tbl_name+' REFRESH; ') %}
    {%endif%}

    {% if execute %}
    
    {% set files_registered_new = run_query(files_registered_new_query).columns[0].values()%}
    {%endif%}

    {% if files_registered_new|length > 1 %}

       {% set  file_names=files_registered_new %}

    {% elif files_registered_new|length == 1 %}
        {% set file_names=files_registered_new|replace(',', '') %}
    
    {%else%}

       {% set file_names= '(\'\')' %}
    
    {%endif%}
    
    {{file_names }}
{% endmacro %}
