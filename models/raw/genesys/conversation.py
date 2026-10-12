# once a day

from snowflake.snowpark.functions import to_timestamp_tz, max, get_path, lit, col, to_date, convert_timezone

MISSING_BASE_DATE: str = "2021-01-01"

def model(dbt, session):
    dbt.config(
        materialized="incremental",
        incremental_strategy="append",
        python_version="3.11"
    )
    session.use_database(dbt.this.database)
    session.use_schema(dbt.this.schema)

    since = None
    if dbt.is_incremental:
        last_extract = session.table(dbt.this.identifier).select(max("EXTRACTED").as_("LAST_EXTRACT"))
        # Using conversartion start time as a date + 1 day as the new since value as it is always the day after the last conversation start time
        max_val = session.table(dbt.this.identifier).join(last_extract, col("LAST_EXTRACT") == col("EXTRACTED")).select(
            (to_date(convert_timezone(lit("Australia/Melbourne"), to_timestamp_tz(max(get_path("payload", lit("conversationStart")))))) + lit(1)).as_("MAX")
        ).collect()
        since = max_val[0]["MAX"]
    if since == None:
        since = dbt.config.get("meta", {}).get("base_date", MISSING_BASE_DATE)
    result = session.call("GENESYS_API", dbt.this.identifier, since, block=True, return_dataframe=True)
    return result
