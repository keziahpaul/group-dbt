{% test check_unique_active(model,pk_field_list ) %}

{% if pk_field_list is string %}
    {% set pk_field_list = [ pk_field_list ] %}
{% endif %}
SELECT
{% for pk_field in pk_field_list -%}
    {{ pk_field }}
    {%- if not loop.last -%},{%- endif %}
{%- endfor %}
FROM {{ model }}
WHERE effective_to::date = '{{var('active_date')}}'::date
GROUP BY
{% for pk_field in pk_field_list -%}
    {{ pk_field }}
    {%- if not loop.last -%},{%- endif %}
{%- endfor %}
HAVING COUNT(*) > 1
{% endtest %}