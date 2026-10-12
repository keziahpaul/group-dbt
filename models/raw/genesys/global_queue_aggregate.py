# once a day

from snowflake.snowpark.functions import to_timestamp_tz, to_variant, to_date, max, get_path, lit, col, split_part
from datetime import date, timedelta

MISSING_MAX_YEARS: int = 5 # years

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
        # Using interval end as the new since value as it is always the day after the last interval start
        max_val = session.table(dbt.this.identifier).join(last_extract, col("LAST_EXTRACT") == col("EXTRACTED")).select(
            to_date(max(to_timestamp_tz(to_variant(split_part(get_path("payload", lit("interval")), lit("/"), lit(2)))))).as_("MAX")
        ).collect()
        since = max_val[0]["MAX"]
    if since == None:
        max_years = int(dbt.config.get("meta", {}).get("max_years", MISSING_MAX_YEARS))
        if max_years > MISSING_MAX_YEARS:
            max_years = MISSING_MAX_YEARS
        since = date.today() - timedelta(days=365 * max_years)
    if (date.today() - since) > timedelta(days=365 * MISSING_MAX_YEARS):
        since = date.today() - timedelta(days=365 * MISSING_MAX_YEARS)
    result = session.call("GENESYS_API", dbt.this.identifier, since, block=True, return_dataframe=True)

    return result
