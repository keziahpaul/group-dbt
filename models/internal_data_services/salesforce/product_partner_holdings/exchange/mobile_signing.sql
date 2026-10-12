{{
    config(
        materialized='incremental',
        unique_key='subscriber_id',
        merge_exclude_columns = ['inserted_at']
    )
}}
With

final As (
    Select
        m.subscriber_id,
        c.id As created_by,
        m.created_by As authoriser_exchange_user_id,
        Case When lower(m.status) In ('active', 'accepted', 'created')
                Then lower(m.status)
            Else 'not transitioned'
        End As status,
        to_char(m.created_date, 'yyyy-mm-ddThh24:mi:ss.ff3Z') As created_date,

        dense_rank() Over (
            Partition By m.subscriber_id Order By
                Case When lower(m.status) = 'active' Then 1
                    When lower(m.status) = 'accepted' Then 2
                    When lower(m.status) = ' created' Then 3
                    Else 4
                End,
                m.created_date
        ) As status_rank,
        convert_timezone('Australia/Sydney', m.inserted_at) As src_delta_extract_ts
    From {{ source('exchange_share','vw_mobile_signing_status') }} As m
    Left Join {{ ref('vw_contact') }} As c
        On m.user_id::text = c.ps_external_id_c
    Where m.subscriber_id Is Not null

)

Select
    *,
    {{ var('inserted_at') }} As inserted_at,
    {{ var('updated_at') }} As updated_at
From final
Where status_rank = 1
