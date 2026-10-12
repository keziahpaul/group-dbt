{% macro extract_financial_year(date) %}
    CONCAT (
    DATE_PART ('YEAR', DATEADD (MONTH, -6, {{date}})),
    '-',
    DATE_PART ('YEAR', DATEADD (MONTH, 6, {{date}})))

{% endmacro %} 