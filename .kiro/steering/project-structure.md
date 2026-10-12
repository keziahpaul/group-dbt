# Project Structure

## Directory Layout
```
├── models/
│   ├── raw/                    # Layer 1: External tables, materialized views, API ingestion
│   │   ├── salesforce/         # External tables + materialized views from S3
│   │   ├── fms/                # External tables from Azure + materialized views
│   │   ├── jira/               # Python API models + SQL views
│   │   ├── genesys/            # Python API model + SQL views
│   │   └── kapiche/            # Source definitions
│   ├── staging/                # Layer 2: Type casting, renaming, incremental append
│   │   ├── salesforce/         # Incremental append from raw materialized views
│   │   ├── FMS/                # Incremental append from raw FMS views
│   │   └── sendfx/             # Table materialization from raw sources
│   ├── curate/                 # Layer 3: SCD2, business logic, cleaned data
│   │   ├── salesforce/         # Views with current/historical variants
│   │   ├── salesforce_table/   # SCD2 table materializations
│   │   ├── FMS/                # Curated FMS tables
│   │   ├── jira/               # Curated JIRA data (cj_ prefix)
│   │   ├── sendfx/             # Curated SendFX data
│   │   ├── genesys/            # Curated Genesys call centre data
│   │   └── kapiche/            # Curated customer feedback
│   ├── internal_data_services/ # Salesforce outbound: contacts, subscribers, product holdings
│   ├── external_data_services/ # Kapiche outbound + bespoke bank reports (ANZ/CBA/Westpac/NAB)
│   ├── common_data_layer/      # Dimensional model: fact + dimension (current/historical)
│   ├── on_day_settlement/      # Settlement-specific analytics
│   ├── logging/                # Trustcenter findings
│   └── tests/                  # Test helper models
├── macros/                     # Thin wrappers around common lib + utility macros
├── seeds/                      # Config CSVs and outbound data extracts
├── tests/
│   ├── generic/                # Reusable test macros
│   └── unit/                   # dbt unit tests (YAML)
├── analyses/                   # Ad-hoc SQL analyses
├── snapshots/                  # Unused (placeholder)
├── dbt_project.yml             # Central config
├── packages.yml                # Package dependencies
└── selectors.yml               # Named selectors for JIRA/Genesys jobs
```

## Data Flow
```
External Sources (S3/Azure/APIs)
    ↓
raw (external tables, materialized views, Python API calls)
    ↓
staging (incremental append, type casting, column renaming)
    ↓
curate (SCD2, business logic, deduplication)
    ↓
data_services / common_data_layer (analytics-ready, dimensional model)
```

## Database Topology (via env vars)
- `DBT_GROUP_RAW_DB` — raw layer
- `DBT_GROUP_STAGE_DB` — staging layer
- `DBT_GROUP_CURATE_DB` — curate layer
- `DBT_GROUP_DATASERVICES_DB` — internal data services
- `DBT_GROUP_EXT_DATASERVICES_DB` — external data services
- `DBT_CDM_DATABASE` — common data layer
- `DBT_LOGGING_DB` — logging and artifacts
- `DBT_GOVERNANCE_DB` / `DBT_GOVERNANCE_SCHEMA` — tagging and masking policies
