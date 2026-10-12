{% test check_for_only_active(model) %}
    SELECT  *
    FROM {{ model }}
    WHERE effective_to::date <>  '{{var('active_date')}}'::date
{% endtest %}