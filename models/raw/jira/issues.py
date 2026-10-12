# Use a Python model because:
#   SELECT * FROM TABLE(JIRA_API("ISSUES"))
# doesn't work with the current Snowflake Python driver

# every 30min midnight-8am, 10pm-midnight sun-thu UTC
# meant to represent every 30 minutes 8am-6pm mon-fri AEST

# Due to the incremental nature of this model, we need to use the JIRA API's "since" parameter
# to only pull issues that have been updated since the last extract. This will mean issues which
# were updated during the same "since" window will be duplicated, but this is a tradeoff we have
# to make to avoid missing any updates.

# It is up to the downstream models to deduplicate these issues based on the "updated" field,
# which is the most recent update timestamp for an issue.

from snowflake.snowpark.functions import to_timestamp_tz, as_varchar, max, get_path, lit, col

INCASE_MISSING_BASE_DATE: str = "1900-01-01"

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
        max_val = session.table(dbt.this.identifier).join(last_extract, col("LAST_EXTRACT") == col("EXTRACTED")).select(
            to_timestamp_tz(as_varchar(max(get_path("payload", lit("fields:updated")))),
                            lit('YYYY-MM-DD"T"HH24:MI:SS.FFTZHTZM')).as_("MAX")).collect()
        since = max_val[0]["MAX"]
    if since == None:
        since = dbt.config.get("meta", {}).get("base_date", "1900-01-01")
    result = session.call("JIRA_API", dbt.this.identifier, since, block=True, return_dataframe=True)

    return result
