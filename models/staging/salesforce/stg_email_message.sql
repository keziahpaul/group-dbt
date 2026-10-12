{#  materialization, incremental strategy configured in dbt_project.yml #}

WITH
initial AS (
    SELECT  
        {#- management fields #}
        Id,
        metadata_filename,
        TO_TIMESTAMP_TZ(SystemModstamp, 'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') AS system_modstamp,

        CAST(IsDeleted AS BOOLEAN) AS is_deleted,
        ROW_NUMBER() OVER (PARTITION BY Id ORDER BY SystemModstamp ASC NULLS FIRST) AS row_num,

        CONVERT_TIMEZONE('Australia/Melbourne', 
            CASE
            WHEN is_deleted = true
                THEN system_modstamp
            WHEN LEAD(is_deleted) OVER (PARTITION BY Id ORDER BY SystemModstamp ASC NULLS FIRST) = true
                THEN LEAD(system_modstamp) OVER (PARTITION BY Id ORDER BY SystemModstamp ASC NULLS FIRST)
            ELSE NULL
            END
        ) AS deleted_at,

        {#- record content fields #}
        ActivityId AS activity_id,
        BccAddress AS bcc_address,
        CcAddress AS cc_address,
        ClientThreadIdentifier AS client_thread_identifier,
        CreatedById AS created_by_id,
        TO_TIMESTAMP_TZ(CreatedDate, 'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') AS created_date,
        TO_TIMESTAMP_TZ(FirstOpenedDate, 'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') AS first_opened_date,
        FromAddress AS from_address,
        FromName AS from_name,
        CAST(HasAttachment AS BOOLEAN) AS has_attachment,
        Headers,
        HtmlBody AS html_body,
        CAST(Incoming AS BOOLEAN) AS incoming,
        CAST(IsBounced AS BOOLEAN) AS is_bounced,
        CAST(IsClientManaged AS BOOLEAN) AS is_client_managed,
        CAST(IsExternallyVisible AS BOOLEAN) AS is_externally_visible,
        CAST(IsOpened AS BOOLEAN) AS is_opened,
        CAST(IsTracked AS BOOLEAN) AS is_tracked,
        LastModifiedById AS last_modified_by_id,
        TO_TIMESTAMP_TZ(LastModifiedDate, 'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') AS last_modified_date,
        TO_TIMESTAMP_TZ(LastOpenedDate, 'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') AS last_opened_date,
        TO_TIMESTAMP_TZ(MessageDate, 'YYYY-MM-DDTHH24:MI:SS.FF3TZHTZM') AS message_date,
        MessageIdentifier AS message_identifier,
        Name,
        ParentId AS parent_id,
        RelatedToId AS related_to_id,
        ReplyToEmailMessageId AS reply_to_email_message_id,
        Status,
        Subject,
        TextBody AS text_body,
        ThreadIdentifier AS thread_identifier,
        ToAddress AS to_address,
        ValidatedFromAddress AS validated_from_address
    FROM {{ ref('mv_email_message') }}
    {%- if is_incremental() %}
    WHERE metadata_filename IN {{ daily_refresh_stage(this, ref('mv_email_message')) }}
    {%- endif %} 
)
SELECT
    * EXCLUDE(row_num, deleted_at, metadata_filename),
    row_num,
    {{ var('inserted_at' ) }} AS inserted_at,
    deleted_at,
    metadata_filename
FROM initial