{{
  config(
    materialized='ephemeral',
    tags=['unit-test', 'macro-test']
  )
}}

-- Test model for unit testing the extract_financial_year macro
-- This model creates test data and applies the macro to validate its output

with test_data as (
    select * from (
        values
            ('2024-01-15'::date),
            ('2024-02-29'::date),
            ('2024-06-30'::date),
            ('2024-07-01'::date),
            ('2024-07-15'::date),
            ('2024-12-31'::date),
            ('2023-06-30'::date),
            ('2023-07-01'::date),
            ('2020-02-29'::date)
    ) as t(test_date)
)

select 
    test_date,
    {{ extract_financial_year('test_date') }} as financial_year
from test_data
