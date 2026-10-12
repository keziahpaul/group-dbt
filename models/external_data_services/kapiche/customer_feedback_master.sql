{{
    config(
        materialized='incremental',
        unique_key='related_account_c',
        incremental_strategy='append',
    )
}}

{% if is_incremental() %}
    with
    target_max_timestamp as (
        select nvl(max(src_delta_extract_ts),to_date('19000101','yyyymmdd')) as last_load_max_timestamp
        from {{ this }}
    )
{% endif %}

select
    survey.related_account_c as related_account_c,
    survey.created_date::date as creation_date,
    survey.csat_c::float as csat_rating,
    csat_comment,
    survey.exchange_subscriber_id_c::integer as subscriber_id,
    acct.name as subscriber_name,
    acct.ps_account_management_segment_c as account_management_segment,
    acct.ps_customer_segment_level_1_c as customer_segment,
    acct.billing_state as subscriber_state,
    case
        when acct.ps_channel_c = 'Practitioner'
            then
                case


                    when
                        acct.ps_customer_segment_level_1_c = 'Developer'
                        then 'Developer'
                    when
                        acct.ps_customer_segment_level_1_c = 'Govt/Council'
                        then 'Government/ Council'
                    when
                        acct.ps_account_management_segment_c in (
                            'Tier One', 'Tier Two', 'Tier Three', 'Strategic'
                        )
                        then 'Practitioner'
                    when
                        acct.ps_account_management_segment_c = 'Major'
                        then 'Major'
                    else
                        'Practitioner'
                end
        when
            acct.ps_channel_c = 'Financial Institution'
            then 'Financial Institution'


    end as customer_type,
    survey.survey_owner_name_formula_c as account_owner,
    convert_timezone(
        'Australia/Sydney', greatest_ignore_nulls(survey.inserted_at, acct.inserted_at)
    ) as src_delta_extract_ts,
    {{ var('inserted_at') }} as inserted_at

from {{ ref('vw_all_survey_responses') }} as survey
unpivot (
    csat_comment for comment_col in (
        customer_support_verbatim_c, pexapositives_c, pexaimprovements_c
    )
)
inner join {{ ref('vw_account') }} as acct
    on
        survey.related_account_c = acct.id

where
    survey.created_date >= {{ env_var("DBT_OUTBOUND_CREATED_DATE") }}

    {% if is_incremental() %}
        and survey.inserted_at > (select last_load_max_timestamp from target_max_timestamp)
    {% endif %}
