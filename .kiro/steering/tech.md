---
inclusion: always
---

# Tech Stack

## Core
- **dbt** (data build tool) — SQL-based transformation framework
- **Snowflake** — cloud data warehouse (target platform)
- **dbt Cloud** — primary development and deployment environment
- **SQL dialect**: Snowflake SQL with Jinja2 templating

## dbt Packages (packages.yml)
- `brooklyn-data/dbt_artifacts` (2.9.3) — run result logging
- `Snowflake-Labs/dbt_constraints` — constraint management
- `metaplane/dbt_expectations` — data quality expectations
- `dbt-labs/dbt_external_tables` — external table support (Salesforce, FMS)
- `dbt-labs/codegen` (0.12.1) — code generation utilities
- `dbt-labs/audit_helper` (0.12.0) — audit/comparison helpers
- `fivetran/salesforce_formula_utils` — Salesforce formula field support
- `pexa-one-data-au-dbt-common-lib` (private Git package) — shared macros for schema generation, SCD2, masking policies, tagging, logging, and unloading

## Linting
- **SQLFluff** with the `dbt` templater
- No max line length enforced (`max_line_length = 0`)
- Rule `AM04` excluded
- Implicit indents allowed

## Raw Data Ingestion
- **Fivetran** for Salesforce replication
- **External tables** for FMS (Azure → Snowflake stage) and Salesforce
- **Python models** (`.py`) for Jira and Genesys API ingestion

## Common Commands
```bash
# Install dbt packages
dbt deps

# Run all models
dbt run

# Run a specific model and its downstream
dbt run --select model_name+

# Run models by path
dbt run --select path:models/curate/salesforce/

# Run using a selector
dbt run --selector build_jira_hourly

# Test all models
dbt test

# Build (run + test)
dbt build

# Run a macro operation
dbt run-operation macro_name --args '{key: value}'

# Compile SQL without executing
dbt compile

# Clean build artifacts
dbt clean
```

## Environment Variables
All database/schema targets are configured via environment variables (e.g., `DBT_GROUP_RAW_DB`, `DBT_GROUP_CURATE_DB`, `DBT_CDM_DATABASE`). These are set per environment in dbt Cloud. Never hardcode database or schema names.

## Test Severity
Default test severity is `warn` (configured in `dbt_project.yml`). Use `severity: error` for critical data integrity tests.
