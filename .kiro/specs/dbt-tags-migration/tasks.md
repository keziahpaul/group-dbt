  # Implementation Plan: AI-Corrected Tag Application (Requirement 12)

## Overview

Implement a Python script (`scripts/apply_anomaly_tags.py`) that reads the Anomaly CSV, filters to CONFIRMED rows, resolves each row to a dbt model YAML file and column, and applies `secure_field=<AI_CORRECTION>` tags using `ruamel.yaml` for round-trip YAML editing. Property-based tests validate correctness properties using `hypothesis`.

## Tasks

- [x] 1. Set up script skeleton and CSV parsing
  - [x] 1.1 Create `scripts/apply_anomaly_tags.py` with main entry point, argument parsing for CSV file path, and basic logging setup
    - Use `csv` module (standard library) to read all rows
    - Accept CSV path as CLI argument
    - Configure logging to stdout with WARNING/INFO levels
    - _Requirements: 12.1, 12.2_

  - [x] 1.2 Implement `filter_confirmed_rows(rows)` function that retains only rows where CONFIRMED == "CONFIRMED" (exact, case-sensitive)
    - Return list of dicts with keys: catalog, schema, table_name, column_name, ai_correction
    - Skip rows where ai_correction is empty/null after stripping whitespace
    - _Requirements: 12.1, 12.2_

  - [ ]* 1.3 Write property test for CSV filtering (Property 1)
    - **Property 1: CSV filtering — only CONFIRMED rows processed**
    - **Validates: Requirements 12.1, 12.2**
    - Use `hypothesis` to generate arbitrary CSV rows with random CONFIRMED values
    - Assert output contains only rows with CONFIRMED == "CONFIRMED" and non-empty AI_CORRECTION

- [x] 2. Implement CATALOG/SCHEMA to dbt path mapping
  - [x] 2.1 Implement `CATALOG_SCHEMA_MAP` dictionary and `resolve_yaml_paths(catalog, schema)` function
    - Hardcode mapping per design Section 5.2 (12 distinct CATALOG/SCHEMA combinations)
    - Return the dbt layer directory path for the given (CATALOG, SCHEMA) pair
    - Return None and log warning for unmapped pairs
    - Normalize inputs to uppercase before lookup
    - _Requirements: 12.4, 12.5_

  - [ ]* 2.2 Write property test for path resolution (Property 3)
    - **Property 3: Path resolution correctness**
    - **Validates: Requirements 12.4, 12.5**
    - Assert that known (CATALOG, SCHEMA) pairs resolve to expected paths
    - Assert that same TABLE_NAME with different CATALOG/SCHEMA resolves to different paths

  - [ ]* 2.3 Write property test for tag format correctness (Property 2)
    - **Property 2: Tag format correctness**
    - **Validates: Requirements 12.3**
    - Generate arbitrary non-empty AI_CORRECTION strings
    - Assert output tag is always `secure_field=<UPPERCASE_VALUE>`

- [x] 3. Implement model and column resolution within YAML files
  - [x] 3.1 Implement `find_model_in_yaml(yaml_path, table_name)` that loads a YAML file with `ruamel.yaml` and finds the model entry matching TABLE_NAME (case-insensitive)
    - Search all `.yml` files in the resolved directory
    - Match against model `name` property (case-insensitive)
    - Handle models with aliases (match both name and alias)
    - Return (yaml_data, model_node, file_path) tuple or None if not found
    - _Requirements: 12.4, 12.9_

  - [x] 3.2 Implement `find_column_in_model(model_node, column_name)` that locates a column by name using case-insensitive comparison
    - Return the column node or None if not found
    - Log warning if model has no `columns` section
    - _Requirements: 12.9, 12.10_

  - [ ]* 3.3 Write property test for case-insensitive column matching (Property 7)
    - **Property 7: Case-insensitive column matching**
    - **Validates: Requirements 12.9**
    - Generate column names with random casing, assert match regardless of case

- [x] 4. Implement tag application logic
  - [x] 4.1 Implement `apply_tag_to_column(column_node, ai_correction)` that adds or updates `config.tags` with `secure_field=<AI_CORRECTION>`
    - If column has no `config` block: create `config.tags: [secure_field=<VALUE>]`
    - If column has `config` but no `tags`: add `tags` list inside existing `config`
    - If column has `config.tags` with no `secure_field=*`: append the tag
    - If column has `config.tags` with `secure_field=<DIFFERENT>`: replace it
    - If column already has `secure_field=<AI_CORRECTION>`: no change (idempotent)
    - Return boolean indicating whether a change was made
    - _Requirements: 12.3, 12.6, 12.7, 12.8, 12.11_

  - [ ]* 4.2 Write property test for tag addition on untagged columns (Property 4)
    - **Property 4: Tag addition for untagged columns**
    - **Validates: Requirements 12.6**
    - Generate column nodes with no `config.tags`, assert tag is correctly added

  - [ ]* 4.3 Write property test for tag update on mismatched columns (Property 5)
    - **Property 5: Tag update for mismatched columns**
    - **Validates: Requirements 12.7**
    - Generate column nodes with existing `secure_field=<WRONG>`, assert replacement occurs

  - [ ]* 4.4 Write property test for idempotency (Property 6)
    - **Property 6: Idempotency of tag application**
    - **Validates: Requirements 12.8**
    - Apply tag twice, assert YAML output is identical both times

  - [ ]* 4.5 Write property test for config.tags structure (Property 9)
    - **Property 9: Tags placed under config.tags structure**
    - **Validates: Requirements 12.11**
    - Assert tag is always nested under column's `config.tags` path

- [x] 5. Implement main orchestration and summary reporting
  - [x] 5.1 Implement `process_corrections(csv_path)` main loop that ties together filtering, path resolution, model lookup, column lookup, and tag application
    - Group corrections by (CATALOG, SCHEMA) for efficient YAML file loading
    - Write modified YAML files back to disk using `ruamel.yaml` round-trip dump
    - Track and print summary: applied count, skipped count, warnings list
    - _Requirements: 12.1–12.13_

  - [ ]* 5.2 Write property test for graceful handling of unresolvable rows (Property 8)
    - **Property 8: Graceful handling of unresolvable rows**
    - **Validates: Requirements 12.10**
    - Generate rows with non-existent TABLE_NAME/COLUMN_NAME, assert no exception raised

  - [ ]* 5.3 Write property test for non-modification of columns not in CSV (Property 10)
    - **Property 10: Non-modification of columns not in CSV**
    - **Validates: Requirements 12.12, 12.13**
    - Generate YAML with multiple columns, apply corrections to subset, assert other columns unchanged

- [x] 6. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 7. Run script against actual Anomaly CSV and validate results
  - [x] 7.1 Execute `python scripts/apply_anomaly_tags.py TAG-Anomalies-Extraction-AI.csv` against the real CSV file
    - Review summary output for applied/skipped/warning counts
    - Verify no unexpected errors in log output
    - _Requirements: 12.1–12.13_

  - [x] 7.2 Run validation grep checks on modified YAML files
    - Confirm all new tags follow `secure_field=<UPPERCASE>` pattern
    - Confirm no standalone `pi_*` or `PI_*` tags were introduced
    - Confirm all tags are under `config.tags` (not direct column properties)
    - _Requirements: 12.3, 12.11_

  - [x] 7.3 Run `dbt compile` to confirm all modified YAML files parse correctly
    - Ensure no syntax errors or broken YAML structure
    - _Requirements: 12.10_

- [ ] 8. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- The implementation language is Python (as specified in the design document)
- `ruamel.yaml` is required for round-trip YAML editing (preserves comments, formatting, key order)
- `hypothesis` is used for property-based testing
- Requirements 1–11 are already implemented; this plan covers only Requirement 12
- Each property test references a specific correctness property from the design document
