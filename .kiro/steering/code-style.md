# Code Style & Conventions

## SQL Models
- Use lowercase snake_case for all column names and aliases
- Cast columns explicitly in staging layer (e.g., `CAST(IsDeleted AS BOOLEAN) as is_deleted`)
- Use `with` CTE pattern: `initial` as first CTE for source selection
- Prefix staging models with `stg_`, curate views with `vw_`, curate tables without prefix
- Jinja config blocks at top of file before SQL
- Use `{{ ref() }}` and `{{ source() }}` — never hardcode table references
- Use `{{ env_var() }}` for all database/schema references — never hardcode environment-specific values

## Incremental Models
- Staging: `incremental_strategy='append'` with `is_incremental()` guard
- Curate: Custom `scd_materialization` / `scd2_transformation` via common lib
- Track latest timestamp with `coalesce(max(timestamp_col), '1990-01-01')` pattern

## Python Models
- Use for Snowflake stored procedure calls (JIRA_API, GENESYS_API)
- Always set `python_version="3.11"`
- Call `session.use_database()` and `session.use_schema()` before operations
- Return a DataFrame from `model()` function

## YML Files
- One schema/source YML per domain per layer (e.g., `salesforce_stage.yml`, `raw_jira.yml`)
- Document all columns with descriptions
- Apply `dbt_tags` column tags for PI classification

## Macros
- Local macros delegate to `pexa_one_data_au_dbt_common_lib` — keep wrappers thin
- Include commented-out `dbt run-operation` examples above macro definitions
- Document macros in `macros/macro_docs.yml`

## Naming Conventions
- Directories: lowercase (prefer `fms` over `FMS` for new work)
- Models: `stg_` (staging), `vw_` (curate views), `mv_` (materialized views), `cj_` (curate jira)
- Seeds: descriptive name with domain prefix directory
- Tests: generic tests in `tests/generic/`, unit tests in `tests/unit/`

## Linting
- SQLFluff configured with `dbt` templater
- No max line length enforced (`max_line_length = 0`)
- `AM04` rule excluded (ambiguous column references)
- Implicit indents allowed
- Tests directory excluded from linting
