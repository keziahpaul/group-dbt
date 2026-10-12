# 10.30pm sun-thu UTC => 8.30am mon-fri AEST

def model(dbt, session):
    dbt.config(
        materialized="table",
        python_version="3.11"
    )
    session.use_database(dbt.this.database)
    session.use_schema(dbt.this.schema)
    result = session.call("JIRA_API", dbt.this.identifier, block=True, return_dataframe=True)

    return result
