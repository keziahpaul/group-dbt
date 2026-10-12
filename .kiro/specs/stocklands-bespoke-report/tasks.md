# Implementation Plan: Stockland Bespoke Report

## Overview

Implement a new Stockland bespoke report as an incremental dbt model with SCD1 merge strategy, hash-based change detection, model documentation, and S3 unload seed configuration. The implementation follows the established pattern used by other bespoke reports (Westpac, ANZ, CBA, NAB).

## Tasks

- [x] 1. Add Stockland schema routing in dbt_project.yml
  - Add `stockland: +schema: "STOCKLAND_DATASERVICES"` under `models.pexa_one_data_au_group_dbt.external_data_services.bespoke_reporting`
  - Place it alongside existing entries (westpac, cba, anz, nab)
  - _Requirements: 1.2, 1.3_

- [x] 2. Create the Stockland report SQL model
  - [x] 2.1 Create directory and model file with config block
    - Create `models/external_data_services/bespoke_reporting/stockland/stockland_project_data.sql`
    - Add the `{{ config(...) }}` block with `materialized = 'incremental'`, `incremental_strategy = 'merge'`, `unique_key` as composite key list, and `merge_exclude_columns = ['inserted_at', 'updated_at']`
    - _Requirements: 1.1, 2.1, 2.2, 2.3_

  - [x] 2.2 Implement the stockland_subscribers CTE
    - Filter `{{ source('exchange_share', 'vw_subscribers') }}` where name LIKE 'STOCKLAND %' OR subscriber_id IN (1412651, 1700340, 1730940, 2218092, 2591412, 3018996)
    - _Requirements: 3.1_

  - [x] 2.3 Implement the invitations CTE
    - Deduplicate invitations using ROW_NUMBER() partitioned by workspace_id and to_subscriber_id, ordered by invitation_id DESC
    - Select only rows where counter = 1 (most recent invitation)
    - Source from `{{ source('exchange_share', 'vw_invitations') }}`
    - _Requirements: 3.2, 3.8_

  - [x] 2.4 Implement IP/IM/POT invitation grouped CTEs
    - Create separate CTEs for Incoming Proprietor (IP), Incoming Mortgagee (IM), and Purchaser On Title (POT) invitation and participant groupings
    - Join participants with invitations CTE to get invitation status and settlement booking status per role
    - _Requirements: 3.3, 3.4_

  - [x] 2.5 Implement the source_records CTE (workings/main query)
    - Join vw_workspaces, vw_participants, vw_lodgements, vw_documents, vw_settlements, vw_settlement_schedules using `{{ source('exchange_share', '...') }}` syntax
    - Filter on stockland_subscribers to limit to Stockland participants
    - Filter lodgements to transaction types ('WCTM', 'DT', 'WCT', 'T', 'WCDT', 'TM', 'DTM', 'WCDTM') or NULL
    - Compute vendor_funds as SUM(amount)/100 WHERE settlement_category_id = 7
    - Derive settlement_booking_status composite CASE logic from IP/IM/POT statuses and settlement date
    - Apply DISTINCT to eliminate duplicates
    - _Requirements: 3.2, 3.3, 3.4, 3.5, 3.6, 3.7_

  - [x] 2.6 Implement hash computation and incremental anti-join
    - Compute HASH(...) over all output columns except `inserted_at` and `updated_at`
    - Add `inserted_at` and `updated_at` audit columns using `{{ var('inserted_at') }}` and `{{ var('updated_at') }}`
    - Wrap the incremental anti-join in `{%- if is_incremental() %}` block: left join `{{ this }}` on composite key + hash, WHERE target is NULL
    - Ensure full refresh selects all source records without the anti-join
    - _Requirements: 2.4, 2.5, 2.6, 2.7, 4.1, 4.2, 4.3, 4.4_

  - [x] 2.7 Write property test for hash sensitivity (Property 1)
    - **Property 1: Hash sensitivity to column changes**
    - dbt unit test: provide two rows differing in one column (excluding inserted_at/updated_at), assert different hash values
    - The hash covers all output fields except `inserted_at` and `updated_at`
    - **Validates: Requirements 2.4, 4.1**

  - [x] 2.8 Write property test for incremental anti-join correctness (Property 2)
    - **Property 2: Incremental anti-join correctness**
    - dbt unit test: mock `{{ this }}` with known rows, verify only new/changed rows appear in output
    - **Validates: Requirements 2.5, 4.2, 4.3**

  - [-] 2.9 Write property test for subscriber filter correctness (Property 4)
    - **Property 4: Subscriber filter correctness**
    - dbt unit test: verify 'STOCKLAND ' prefix included, 'STOCKLAND' (no space) excluded, explicit IDs included
    - **Validates: Requirements 3.1**

  - [ ]* 2.10 Write property test for invitation deduplication (Property 9)
    - **Property 9: Invitation deduplication**
    - dbt unit test: provide multiple invitations per workspace+subscriber, verify only highest invitation_id used
    - **Validates: Requirements 3.8**

- [~] 3. Checkpoint - Verify model compiles
  - Ensure `dbt compile --select stockland_project_data` succeeds without errors, ask the user if questions arise.

- [ ] 4. Create model documentation
  - [ ] 4.1 Create stockland_model.yml
    - Create `models/external_data_services/bespoke_reporting/stockland/stockland_model.yml`
    - Add model-level description explaining the Stockland bespoke report purpose
    - Add column-level descriptions for all 19 output columns (17 business + hash + inserted_at + updated_at)
    - Follow the same YAML structure as `anz_model.yml`
    - _Requirements: 5.1, 5.2, 5.3_

  - [ ]* 4.2 Add dbt generic tests to stockland_model.yml
    - Add `unique` test on composite key expression
    - Add `not_null` tests on workspace_id, subscriber_reference, hash
    - **Property 8: No duplicate rows**
    - **Validates: Requirements 3.7**

- [ ] 5. Create seed CSV for S3 unload configuration
  - [ ] 5.1 Create stockland_extracts.csv
    - Create `seeds/bespoke/stockland_extracts.csv`
    - Add single row with `table_name = stockland_project_data`, empty `incremental_timestamp_column`, appropriate `path_prefix`, `path_date_format`, `file_datetime_format`, `file_ext`, `output_path_format`, and `unload_single_file = true`
    - Ensure `table_name` exactly matches the dbt model name (case-sensitive)
    - _Requirements: 6.1, 6.2, 6.3, 6.4_

- [ ] 6. Final checkpoint - Ensure all artifacts are valid
  - Ensure `dbt compile --select stockland_project_data` passes, `dbt seed --select stockland_extracts` would load correctly, and all YAML is valid. Ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- The model uses the same SCD1 incremental pattern as `cj_statuses.sql`
- All source references use `{{ source('exchange_share', '...') }}` syntax
- Property tests validate universal correctness properties from the design document
- Checkpoints ensure incremental validation between major implementation steps
