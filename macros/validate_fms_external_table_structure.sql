{% macro compare_columns_fms_azure_vs_dbt(source_name) %}

{# Read model.json from Snowflake stage #}
{# dbt run-operation compare_columns_fms_azure_vs_dbt --args "source_name: external_source_fms"#}
{% set get_model_json_query %}
   SELECT $1 as json_data
    FROM @dev_group_raw.fms.fms_model_json_stage/model.json;
{% endset %}

{# Execute query to get model.json content #}
{% set model_json_results = run_query(get_model_json_query) %}
{% set model_json = fromjson(model_json_results.columns[0].values()[0]) %}

{# Get source nodes from dbt graph #}
{% set source_nodes = graph.sources.values() %}


{% set source_nodes = {} %}
{% for node in graph.sources.values() %}
    {% if node.source_name == source_name %}
        {% do source_nodes.update({node.name: node}) %}
    {% endif %}
{% endfor %}


{% set missing_columns = [] %}
{% set matching_tables = [] %}

{# Iterate through each entity in model.json #}
{% for entity in model_json.entities %}
    {% if entity['$type'] == 'LocalEntity' %}
        {% set table_name = entity.name %}
        {% set model_columns = entity.attributes | map(attribute='name') | list %}
        
        {# Find corresponding source table in dbt graph #}
        {% if table_name in source_nodes %}
            {% set source_table = source_nodes[table_name] %}
            
            {# Get source columns from dbt graph #}
            {% set source_columns = source_table.columns.keys() | list %}
                                  
            {# Compare columns and find missing ones #}
            {% set table_missing_columns = [] %}
            {% for column in model_columns %}
                {% if column not in source_columns %}
                    {% do table_missing_columns.append(column) %}
                {% endif %}
            {% endfor %}
            
            {% if table_missing_columns | length > 0 %}
                {% do missing_columns.append({
                    'table_name': table_name,
                    'missing_columns': table_missing_columns,
                    'total_columns': model_columns|length,
                    'matched_columns': model_columns|length - table_missing_columns|length
                }) %}
            {% else %}
                {% do matching_tables.append({
                    'table_name': table_name,
                    'total_columns': model_columns|length
                }) %}
            {% endif %}
        {% else %}
            {% do log('Table ' ~ table_name ~ ' not found in source: ' ~ source_name, info=True) %}
            {% do missing_columns.append({
                'table_name': table_name,
                'missing_columns': ['ENTIRE TABLE MISSING IN SOURCE YML'],
                'total_columns': model_columns|length,
                'matched_columns': 0
            }) %}
        {% endif %}
    {% endif %}
{% endfor %}

{# Output results #}
{% if execute %}
    {% do log('📊 Column Comparison Report for source: ' ~ source_name, info=True) %}   
    {% do log('========================================', info=True) %}
    
    {% if matching_tables | length > 0 %}
        {% do log('✅ FULLY MATCHING TABLES:', info=True) %}
        {% do log('----------------------------------------', info=True) %}
        {% for table in matching_tables %}
            {% do log('Table: ' ~ table.table_name, info=True) %}
            {% do log('Total Columns: ' ~ table.total_columns, info=True) %}
            {% do log('----------------------------------------', info=True) %}
        {% endfor %}
    {% endif %}
    {% if missing_columns | length > 0 %}
        {% do log('❌ Found missing columns in source yml for source: ' ~ source_name, info=True) %}
        {% for result in missing_columns %}
            {% do log('Table: ' ~ result.table_name, info=True) %}
            {% do log('Missing columns: ' ~ result.missing_columns | join(', '), info=True) %}
            {% do log('----------------------------------------', info=True) %}
        {% endfor %}
        {{ return(1) }}  {# Return failure #}
    {% else %}
        {% do log('✅ All columns from model.json are present in source yml for source: ' ~ source_name, info=True) %}
        {{ return(0) }}  {# Return success #}
    {% endif %}
{% endif %}

{% endmacro %}