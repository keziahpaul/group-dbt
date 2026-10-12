{% macro copy_from_src_to_target(source_stage, target_stage) %}
    {# setting target_stage_with_file_location as it is required in the copy files command but not in the minus query #}
    {% set target_stage_with_file_location = source_stage ~ '/' ~ env_var('DBT_KAPICHE_FILE_LOCATION') %}

    {% set check_for_new_files_query %}
            {# concat / because FILES param expects a / prefixed in front of file names #}
                select concat('\'', '/' || file_name, '\'') from (select distinct SPLIT_PART(FILE_NAME, '/', -1) as file_name
                from {{env_var('DBT_GROUP_RAW_DB')}}.INFORMATION_SCHEMA.LOAD_HISTORY where lower(table_name)='customer_feedback'
                    minus
                        SELECT distinct SPLIT_PART(METADATA$FILENAME, '/', -1) from {{target_stage}})

    {% endset %}

    {% if execute%}
        {% set files_registered_new = run_query(check_for_new_files_query).columns[0].values()%}
    {%endif%}

    {%if files_registered_new %}
        {%set file_names = files_registered_new | join(",") %} {# this removes the wrapping of double quotes and trailing comman when there is only 1 in list#}
        COPY FILES INTO {{ target_stage }} FROM {{ target_stage_with_file_location }} FILES=({{file_names }}) {# file_names must wrap in () list#}
    {%else%}
        select 1
    {%endif%}

{% endmacro %}
