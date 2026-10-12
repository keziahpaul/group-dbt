# Tech Stack & Dependencies

## Core
- **dbt** (SQL + Python models) on **dbt Cloud** IDE
- **Snowflake** as data warehouse
- **SQLFluff** for SQL linting (dbt templater)
- **Dependabot** for pip dependency scanning (weekly, Melbourne timezone)

## dbt Packages

### Critical (project won't function without these)
- `pexa_one_data_au_dbt_common_lib` — Private PEXA shared library. Provides: `generate_schema_name`, `scd_materialization`, all PI masking/tagging macros, logging utilities, `is_newer`, `column_count_check`. Pinned to git revision via `DBT_COMMON_REPO_BRANCH` env var.
- `infinitelambda/dbt_tags` — Column-level tagging engine. Applied as post-hook on every model run. Drives PI classification and masking policy enforcement.

### Important
- `brooklyn-data/dbt_artifacts` (2.9.3) — Captures run metadata via `on-run-end` hook. Logs to `DBT_LOGGING_DB`.
- `dbt-labs/dbt_external_tables` — Manages Salesforce (S3) and FMS (Azure) external table definitions.
- `fivetran/salesforce_formula_utils` — Resolves Salesforce formula fields in staging models.

### Utility
- `Snowflake-Labs/dbt_constraints` — Constraint enforcement helpers.
- `metaplane/dbt_expectations` — Data quality test macros (dbt_expectations).
- `dbt-labs/codegen` — Code generation for model/source scaffolding.
- `dbt-labs/audit_helper` — Model comparison and audit utilities.

### Transitive (pulled in by above)
- `calogica/dbt_date`, `dbt-labs/dbt_utils`, `data-mie/dbt_profiler`, `fivetran/fivetran_utils`

## External Integrations
- **Snowflake stored procedures**: `JIRA_API`, `GENESYS_API` — called from Python models
- **S3 stages**: Salesforce external tables, logging unloads, Salesforce outbound
- **Azure stages**: FMS external tables (model.json validation)
- **Fivetran**: Salesforce data ingestion (referenced in logging seeds)

## Environment Variables (required)
Database: `DBT_GROUP_RAW_DB`, `DBT_GROUP_STAGE_DB`, `DBT_GROUP_CURATE_DB`, `DBT_GROUP_DATASERVICES_DB`, `DBT_GROUP_EXT_DATASERVICES_DB`, `DBT_CDM_DATABASE`, `DBT_LOGGING_DB`, `DBT_GOVERNANCE_DB`

Schema: `DBT_SALESFORCE_RAW_SCHEMA`, `DBT_JIRA_RAW_SCHEMA`, `DBT_GENESYS_RAW_SCHEMA`, `DBT_KAPICHE_SCHEMA`, `DBT_FMS_SCHEMA`, `DBT_DS_SALESFORCE_SCHEMA`, `DBT_EXT_DS_KAPICHE_SCHEMA`, `DBT_CDM_SCHEMA`, `DBT_ODS_SCHEMA`, `DBT_LOGGING_SCHEMA`, `DBT_LOG_MAPPING_SCHEMA`, `DBT_TRUSTCENTER_SCHEMA`, `DBT_GOVERNANCE_SCHEMA`, `DBT_KAPICHE_FILE_LOCATION`

Secrets: `DBT_ENV_SECRET_GIT_CREDENTIAL`, `DBT_COMMON_REPO_BRANCH`
