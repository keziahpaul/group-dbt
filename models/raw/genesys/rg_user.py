# once a day

def model(dbt, session):
    dbt.config(
        materialized="table",
        python_version="3.11"
    )
    session.use_database(dbt.this.database)
    session.use_schema(dbt.this.schema)
    result = session.call("GENESYS_API", dbt.this.identifier, block=True, return_dataframe=True)

    return result
