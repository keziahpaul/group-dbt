{% test all_column_value_check(src_tbl_name, model, primarykey, exclude_columns=[]) %}
    {{ config(severity = 'error') }}
    {%- if execute %}
        
        {%- if primarykey is string %}
            {%- set primarykey = [ primarykey ] %}
        {%- endif %}

        {%- set exclude_columns = exclude_columns + ['METADATA_FILENAME', 'INSERTED_AT'] %}
        {%- set column_names = dbt_utils.get_filtered_columns_in_relation(from=src_tbl_name, except=exclude_columns) %}
        {%- set primarykey = primarykey | map("lower") | list %}
        {%- set pkey_fields = [] %}
        {%- set hkey_fields = [] %}
        {%- for field in column_names %}
            {%- if field|lower in primarykey %}
                {%- do pkey_fields.append(field) %}
            {%- else %}
                {%- do hkey_fields.append(field) %}
            {%- endif %}
        {%- endfor %}
        {%- if pkey_fields | length == 0 %}
            {{ return("SELECT 'NO PRIMARY KEY'") }}
        {%- endif %}
        {%- set primarykey -%}
            {%- if pkey_fields | length > 1 -%}
                [
            {%- endif -%}
            {%- for field in pkey_fields -%}
                {{ field }}
                {%- if not loop.last -%}, {%- endif -%}
            {%- endfor -%}
            {%- if pkey_fields | length > 1 -%}
                ]
            {%- endif -%}
        {%- endset -%}
        {%- set hashkey -%}
            {%- if hkey_fields | length > 0 -%}
                {%- if hkey_fields | length > 1 -%}
                    HASH(
                {%- endif -%}
                {%- for field in hkey_fields -%}
                    {{ field }}
                    {%- if not loop.last -%}, {%- endif -%}
                {%- endfor -%}
                {%- if hkey_fields | length > 1 -%}
                    )
                {%- endif -%}
            {%- else -%}
                0
            {%- endif -%}
        {%- endset -%}

        WITH summary AS (
            SELECT
            count(*) AS join_count,
            count(DISTINCT a.pk) AS a_count,
            count(DISTINCT b.pk) AS b_count,
            sum((a.row_hash IS DISTINCT FROM b.row_hash)::integer)
            AS diff_count
            FROM (
                SELECT {{ primarykey }} AS pk, {{ hashkey }} AS row_hash
                FROM {{ src_tbl_name }}
            ) a
            FULL OUTER JOIN (
                SELECT {{ primarykey }} AS pk, {{ hashkey }} AS row_hash
                FROM {{ model }}
            ) b USING (pk)
        )
        SELECT * FROM summary
        WHERE diff_count > 0
           OR join_count <> a_count
           OR a_count <> b_count
    {%- endif %}
{%- endtest %}