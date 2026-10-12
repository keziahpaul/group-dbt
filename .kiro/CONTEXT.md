# kspec Context
> Auto-generated. Always read this first after context compression.

## Current Spec
**2026-06-04-test**
Path: `.kiro/specs/2026-06-04-test`

## Design
- Status: not yet created
- Run `kspec design` to create (optional)

## Quick Commands
- `kspec design` - Create technical design (optional)
- `kspec tasks` - Generate implementation tasks
- `kspec build` - Continue building tasks
- `kspec verify` - Verify implementation
- `kspec status` - Show current status
- `kspec context` - Refresh this file
# Project Context

## Overview
PEXA ONEData AU Group dbt project — a Medallion Architecture (ELT) data platform on Snowflake, managed via dbt Cloud. Ingests data from Salesforce (S3), FMS (Azure), JIRA API, Genesys API, Kapiche, and SendFX, transforming it through raw → staging → curate → data services/CDM layers.

## Quick Reference
- **Warehouse**: Snowflake
- **Orchestration**: dbt Cloud (IDE + CI/CD jobs)
- **Environments**: DEV (feature branches) → TEST (develop) → PST (release) → PRD (main)
- **Private package**: `pexa_one_data_au_dbt_common_lib` (critical dependency, pinned by git revision)
- **PI governance**: Column-level tagging + masking via `dbt_tags` post-hooks on every run

## Key Patterns
- Raw layer: external tables (S3/Azure) + materialized views + Python API models (JIRA/Genesys stored procedures)
- Staging: incremental append with explicit type casting and column renaming
- Curate: custom SCD2 materialization via common lib (`scd_materialization` + `scd2_transformation`)
- CDM: dimensional model with historical tables + current views (filtered by `active_date = '9999-12-31'`)
- All macros delegate to `pexa_one_data_au_dbt_common_lib` — local wrappers are thin

## Active Risks
- **Hardcoded dev reference**: `validate_fms_external_table_structure.sql` line 7 references `@dev_group_raw.fms.fms_model_json_stage` — will fail in non-dev environments
- **Missing FMS staging YML**: No schema documentation for `models/staging/FMS/` (30+ models undocumented)
- **Package lock drift**: `package-lock.yml` shows `dbt_artifacts 2.6.3` but `packages.yml` specifies `2.9.3`
- **Inconsistent directory casing**: `FMS` vs `fms`, `Foreign_address` — mixed conventions
- **Global test severity `warn`**: All tests default to warn, meaning data quality failures won't block builds
- **Large YML files**: Several schema files exceed 200KB+ (e.g., `curate_salesforce.yml` at 399KB, `salesforce_external_tables.yml` at 478KB)

## Steering Docs
See `.kiro/steering/` for:
- `project-structure.md` — directory layout and data flow
- `tech-stack.md` — dependencies and integrations
- `code-style.md` — SQL/Python conventions and naming
- `security.md` — PI classification, masking, and data governance
