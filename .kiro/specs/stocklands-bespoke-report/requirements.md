# Requirements Document

## Introduction

This document defines the requirements for creating a new Stockland bespoke report within the PEXA dbt project. The report will be materialised as an incremental table (SCD1, merge strategy) under `models/external_data_services/bespoke_reporting/stockland/` and served via the existing bespoke reporting infrastructure (Snowflake table → S3 unload). The model uses hash-based change detection to merge only changed rows on each incremental run, with `inserted_at` and `updated_at` audit columns tracking row lifecycle.

## Glossary

- **Report_Model**: The dbt SQL model materialised as an incremental Snowflake table using SCD1 merge strategy in the `STOCKLAND_DATASERVICES` schema of the `DBT_GROUP_EXT_DATASERVICES_DB` database
- **SCD1_Merge**: Slowly Changing Dimension Type 1 — overwrites existing rows on change rather than maintaining history; implemented via dbt's `incremental` materialization with `merge` strategy
- **Hash_Column**: A column computed via `HASH(...)` over all business columns, used to detect changes between source and target
- **Audit_Columns**: `inserted_at` (set on first insert, never overwritten) and `updated_at` (set on every merge/insert) — these exist only in the target table, not in the source query
- **Composite_Key**: The unique key comprising `['workspace_id', 'subscriber_reference', 'lodgement_status', 'ip_subscriber_id', 'im_subscriber_id', 'pexa_project_id']` used to identify rows for merge
- **S3_Unload**: The process of exporting table data from Snowflake to S3 via the `get_objects_to_unload` macro and a seed CSV configuration
- **Seed_Config**: A CSV file in `seeds/bespoke/` that drives the S3 unload macro with table names, path formats, and file naming conventions
- **Exchange_Share**: The shared Snowflake database containing core PEXA platform views (workspaces, settlements, participants, subscribers, etc.)

## Requirements

### Requirement 1: Stockland Report Folder Structure and Schema Routing

**User Story:** As a data engineer, I want a dedicated `stockland` subfolder under `models/external_data_services/bespoke_reporting/`, so that Stockland reports are organised consistently with other bespoke reports.

#### Acceptance Criteria

1. THE Report_Model SHALL reside in the directory `models/external_data_services/bespoke_reporting/stockland/`
2. WHEN the `stockland` folder is added, THE dbt_project.yml SHALL include a schema routing entry `stockland: +schema: "STOCKLAND_DATASERVICES"` under `external_data_services.bespoke_reporting`
3. THE Report_Model SHALL use `+query_tag: bespoke_extracts` and `+database: "{{env_var('DBT_GROUP_EXT_DATASERVICES_DB')}}"` inherited from the parent `bespoke_reporting` config block

### Requirement 2: Stockland Report SCD1 Incremental Materialization

**User Story:** As a data engineer, I want the Stockland report materialised as an incremental table with SCD1 merge strategy, so that only changed rows are updated on each run and historical audit timestamps are preserved.

#### Acceptance Criteria

1. THE Report_Model SHALL use `materialized = 'incremental'` with `incremental_strategy = 'merge'`
2. THE Report_Model SHALL define `unique_key` as the Composite_Key: `['workspace_id', 'subscriber_reference', 'lodgement_status', 'ip_subscriber_id', 'im_subscriber_id', 'pexa_project_id']`
3. THE Report_Model SHALL define `merge_exclude_columns = ['inserted_at', 'updated_at']` so that audit columns are not overwritten on merge
4. THE Report_Model SHALL compute a Hash_Column using Snowflake `HASH(...)` over all business columns to detect row-level changes
5. WHEN an incremental run occurs, THE Report_Model SHALL use a left-join anti-pattern comparing the Hash_Column between source and target to select only new or changed rows
6. THE Report_Model SHALL add an `inserted_at` Audit_Column set to `{{ var('inserted_at') }}` on first insert only
7. THE Report_Model SHALL add an `updated_at` Audit_Column set to `{{ var('updated_at') }}` on every insert and merge

### Requirement 3: Stockland Report Query Logic

**User Story:** As a data analyst at Stockland, I want a report that provides workspace, settlement, invitation, and financial data for all Stockland-related participants, so that I can monitor PEXA activity relevant to Stockland entities.

#### Acceptance Criteria

1. THE Report_Model SHALL identify Stockland workspaces by filtering subscribers where name starts with 'STOCKLAND ' OR subscriber_id is in the set (1412651, 1700340, 1730940, 2218092, 2591412, 3018996)
2. THE Report_Model SHALL source data from the following Exchange_Share sources using `{{ source('exchange_share', '...') }}` syntax:
   - `vw_subscribers`
   - `vw_participants`
   - `vw_invitations`
   - `vw_workspaces`
   - `vw_lodgements`
   - `vw_documents`
   - `vw_settlements`
   - `vw_settlement_schedules`
3. THE Report_Model SHALL produce the following output columns: `workspace_id`, `subscriber_reference`, `workspace_status`, `lodgement_status`, `financial_settlement_status`, `settlement_date`, `settlement_time_aest`, `settlement_booking_status`, `ip_subscriber_id`, `ip_invitation_status`, `ip_settlement_booking_status`, `im_subscriber_id`, `im_invitation_status`, `im_settlement_booking_status`, `vendor_funds`, `pot_settlement_booking_status`, `pexa_project_id`
4. THE Report_Model SHALL derive `settlement_booking_status` as a composite status based on IP, IM, and POT settlement booking statuses combined with the presence of a settlement date
5. THE Report_Model SHALL calculate `vendor_funds` as the sum of settlement schedule amounts (divided by 100) where settlement_category_id = 7
6. THE Report_Model SHALL filter lodgements to transaction types ('WCTM', 'DT', 'WCT', 'T', 'WCDT', 'TM', 'DTM', 'WCDTM') or null
7. THE Report_Model SHALL apply DISTINCT to the final output to eliminate duplicate rows
8. THE Report_Model SHALL group invitations by workspace and recipient using ROW_NUMBER partitioned by workspace_id and to_subscriber_id, ordered by invitation_id descending, selecting only the most recent invitation (COUNTER = 1)

### Requirement 4: Incremental Change Detection

**User Story:** As a data engineer, I want the model to detect changes efficiently using hash comparison, so that only new or modified rows are merged on incremental runs.

#### Acceptance Criteria

1. THE Report_Model SHALL compute the Hash_Column over all business output columns (excluding `inserted_at`, `updated_at`, and the hash column itself)
2. WHEN running incrementally, THE Report_Model SHALL left-join source records against `{{ this }}` on the Composite_Key and Hash_Column
3. WHEN the left-join produces a NULL match on the target side, THE Report_Model SHALL include that row in the merge set (indicating a new or changed row)
4. WHEN running a full refresh, THE Report_Model SHALL select all source records without the change-detection join

### Requirement 5: Model Documentation

**User Story:** As a data engineer, I want the Stockland report model documented in a YAML file, so that it is discoverable in dbt docs and the data catalog.

#### Acceptance Criteria

1. THE Report_Model SHALL have a corresponding entry in `models/external_data_services/bespoke_reporting/stockland/stockland_model.yml`
2. THE stockland_model.yml SHALL include a model description and column-level descriptions for all output columns including Audit_Columns
3. THE stockland_model.yml SHALL follow the same structure as existing bespoke model YAML files (e.g., `anz_model.yml`)

### Requirement 6: S3 Unload Configuration

**User Story:** As a data engineer, I want a seed CSV that configures the Stockland report for S3 unload, so that the report data can be delivered to Stockland via the standard bespoke extract pipeline.

#### Acceptance Criteria

1. THE Seed_Config SHALL be created at `seeds/bespoke/stockland_extracts.csv`
2. THE Seed_Config SHALL contain a row where `table_name` exactly matches the dbt model name (case-sensitive)
3. THE Seed_Config SHALL define `path_prefix`, `path_date_format`, `file_datetime_format`, `file_ext`, `output_path_format`, and `unload_single_file` columns consistent with the delivery requirements
4. WHEN `dbt seed --select stockland_extracts` is run, THE Seed_Config SHALL load into `OUTBOUND_SEEDS.STOCKLAND_EXTRACTS` in the external data services database
