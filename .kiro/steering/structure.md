---
inclusion: always
---

# Project Structure

## Medallion Architecture Layers

```
models/
├── raw/              # Bronze: raw ingestion (external tables, Python API models)
│   ├── fms/          # Finance Management System (external tables from Azure)
│   ├── salesforce/   # Salesforce (external tables via Fivetran)
│   ├── jira/         # Jira API ingestion (Python models + SQL views)
│   ├── genesys/      # Genesys call centre API (Python + SQL)
│   └── kapiche/      # Kapiche customer feedback
│
├── staging/          # Silver: incremental staging with deduplication and type casting
│   ├── salesforce/   # Incremental append, daily_refresh_stage macro
│   ├── FMS/          # Incremental append, stg_ prefix
│   └── sendfx/      # Table materialization
│
├── curate/           # Gold: business logic, cleaning, flattening
│   ├── salesforce/   # Views over staged Salesforce data
│   ├── FMS/          # Views over staged FMS data
│   ├── sendfx/       # Tables with SendFX transformations
│   ├── jira/         # Curated Jira data
│   ├── genesys/      # Curated Genesys data
│   └── kapiche/      # Curated Kapiche data
│
├── common_data_layer/  # CDM: dimensional model (star schema)
│   ├── dimension/
│   │   ├── historical/   # SCD2 dimension tables (dim_*)
│   │   └── current/      # Current-state views (vw_dim_*), filtered to active_date
│   └── fact/
│       ├── historical/   # Fact tables (fact_*)
│       └── current/      # Current-state fact views (vw_fact_*)
│
├── internal_data_services/   # Internal analytics-ready data marts
├── external_data_services/   # External-facing data services (bespoke, kapiche)
├── on_day_settlement/        # On-day settlement analytics
├── logging/                  # Trust center and operational logging
└── tests/                    # Test helper models
```

## Other Directories

```
macros/           # Shared macros (schema generation, refresh, financial year, etc.)
tests/
├── generic/      # Reusable generic test macros (column checks, SCD2 validation)
├── unit/         # dbt unit tests (YAML-based)
├── data_quality/ # Data quality tests
├── integration/  # Integration tests
└── smoke/        # Smoke tests
seeds/            # CSV seed files organized by source (logging, salesforce, kapiche, etc.)
snapshots/        # dbt snapshots
analyses/         # Ad-hoc analysis SQL
```

## Naming Conventions

| Layer | Prefix/Pattern | Example |
|-------|---------------|---------|
| Raw external tables | source name | `salesforce_external_tables.yml` |
| Raw Python models | entity name | `issues.py` |
| Raw views | `vw_` | `vw_issues.sql` |
| Staging | `stg_` | `stg_account.sql` |
| Curate | entity name | `companyinfo.sql` |
| CDM dimension (historical) | `dim_` | `dim_subscribers.sql` |
| CDM dimension (current view) | `vw_dim_` | `vw_dim_subscribers.sql` |
| CDM fact (historical) | `fact_` | `fact_settlement_attributes.sql` |
| CDM fact (current view) | `vw_fact_` | `vw_fact_first_accepted_settlement.sql` |

## Key Patterns

- **Current views** filter historical tables to `effective_to = '9999-12-31'` (the `active_date` var)
- **SCD2 models** use the custom `scd_materialization` materialization from the common lib, with `key_hash`, `row_hash`, `effective_from`, `effective_to`, `inserted_at`, `updated_at` audit columns
- **Staging models** use incremental append strategy with the `daily_refresh_stage` macro for file-based delta detection
- **Column aliasing** in staging: CamelCase source columns are aliased to snake_case
- **PI (Personal Information) tagging**: models containing sensitive data are tagged (e.g., `PI_FULL_NAME`, `PI_EMAIL`) and have masking policies applied via `dbt_tags`
- **Schema/database routing**: all target databases and schemas are driven by environment variables in `dbt_project.yml`, never hardcoded
- **YAML model docs** (`cdm_models.yml`, `salesforce_stage.yml`, etc.) include Alation metadata integration via `config.meta.alation_oid`
