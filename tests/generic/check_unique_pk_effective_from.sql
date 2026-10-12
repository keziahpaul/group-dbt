{% test check_unique_pk_effective_from(model,pk_field_list ) %}
    SELECT {{pk_field_list}}, effective_from, count(*)
    FROM {{ model }}
    where effective_from::date = '{{ var('active_date') }}'
    GROUP BY {{pk_field_list}}, effective_from
    HAVING COUNT(*) > 1
{% endtest %}