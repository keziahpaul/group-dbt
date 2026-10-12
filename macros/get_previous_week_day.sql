{% macro get_previous_weekday(input_date) %} 
CASE
  DAYOFWEEK({{ input_date }})
  WHEN 1 THEN DATEADD(day, -3, {{ input_date }})
  WHEN 0 THEN DATEADD(day, -2, {{ input_date }})
  ELSE DATEADD(day, -1, {{ input_date }})
END 
{% endmacro %}