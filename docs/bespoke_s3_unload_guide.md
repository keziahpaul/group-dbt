# Bespoke S3 Unload Process — Guide (Westpac Example)

This document describes how to configure a new bespoke bank extract for unloading data from Snowflake views to S3 using the `get_objects_to_unload` macro. It uses the existing **Westpac** configuration as a worked example.

---

## Overview

The end-to-end flow is:

1. **Create a dbt model (view)** in `models/external_data_services/bespoke_reporting/<bank>/` — this is the SQL that produces the report data.
2. **Create a seed CSV** in `seeds/bespoke/` — this is the configuration table that tells the macro which views to export, where to put them in S3, and how to name the files.
3. **Run `dbt seed`** to load the config into Snowflake (`<ENV>_GROUP_EXT_DATASERVICES.OUTBOUND_SEEDS`).
4. **Run `dbt run`** to materialise the report views into the bank's schema.
5. **Run `dbt run-operation get_objects_to_unload`** to unload the view data as files to S3 via a Snowflake external stage.

---

## Step 1 — Create the Report Model (View)

Location: `models/external_data_services/bespoke_reporting/westpac/`

Each report is a standalone SQL view. The view name **must exactly match** the `table_name` value in the seed CSV.

Example: `Westpac_Monthly_RAM_report.sql` produces a view called `Westpac_Monthly_RAM_report` in schema `WESTPAC_DATASERVICES`.

The `dbt_project.yml` routes these models:

```yaml
external_data_services:
  bespoke_reporting:
    +query_tag: bespoke_extracts
    +materialized: view
    +database: "{{env_var('DBT_GROUP_EXT_DATASERVICES_DB')}}"
    westpac:
      +schema: "WESTPAC_DATASERVICES"
```

---

## Step 2 — Create the Seed Config CSV

Location: `seeds/bespoke/westpac_extracts.csv`

This CSV is loaded as a Snowflake table and drives the unload macro. Each row represents one file to export.

### Column Definitions

| Column | Type | Description |
|--------|------|-------------|
| `table_name` | STRING | **Exact** name of the view/table to export (case-sensitive match against `information_schema.tables`). |
| `incremental_timestamp_column` | STRING (nullable) | Column used for incremental exports. If populated, only rows newer than the last exported timestamp are included. Leave **empty** for full-refresh exports. |
| `path_prefix` | STRING | S3 folder prefix under the environment root. Becomes part of the S3 key. |
| `path_date_format` | STRING | Python `strftime` format for the date folder in the S3 path (e.g. `%Y-%m-%d`). |
| `file_datetime_format` | STRING | Python `strftime` format for the datetime stamp embedded in the filename (e.g. `%Y%m%d`, `%b%y`). |
| `need_file_ext` | BOOLEAN | Whether to append a file extension. |
| `file_ext` | STRING | File extension including the dot (e.g. `.csv`, `.dat`). |
| `output_path_format` | STRING (optional) | Custom Python format string overriding the default S3 path template. Uses `%(variable)s` placeholders. |
| `unload_single_file` | BOOLEAN (optional) | If `true`, Snowflake produces a single file (`SINGLE = TRUE`). If `false`/null, data may be split across multiple files. |

### Available Path Placeholders (for `output_path_format`)

| Placeholder | Description | Example Value |
|-------------|-------------|---------------|
| `%(prefix)s` | Value of `path_prefix` column | `Westpac_Monthly_report` |
| `%(au_path_date)s` | Melbourne-timezone date formatted with `path_date_format` | `2025-05-22` |
| `%(au_file_date)s` | Melbourne-timezone datetime formatted with `file_datetime_format` | `20250522` or `May25` |
| `%(au_file_lastmonthdate)s` | First day of previous month (Melbourne TZ) formatted with `file_datetime_format` | `Apr25` |
| `%(table)s` | Original `table_name` (preserves case) | `Westpac_Monthly_RAM_report` |
| `%(lower_table)s` | Lowercased `table_name` | `westpac_monthly_ram_report` |
| `%(ext)s` | Value of `file_ext` column | `.csv` |
| `%(path_date)s` | UTC date formatted with `path_date_format` | `2025-05-22` |
| `%(file_date)s` | UTC datetime formatted with `file_datetime_format` | `20250522` |
| `%(log)s` | Literal `logs/` (only for logging fmt_version) | `logs/` |

### Westpac Seed Data (Full Example)

```csv
table_name,incremental_timestamp_column,path_prefix,path_date_format,file_datetime_format,need_file_ext,file_ext,output_path_format,unload_single_file
Westpac_Daily_report,,Westpac_Daily_report,%Y-%m-%d,%Y%m%d,true,.csv,/%(au_path_date)s/Westpac_Daily_report_%(au_file_date)s%(ext)s,true
A00671_D_AE_WBC,,A00671_D_AE_WBC,%Y-%m-%d,%Y%m%d,true,.dat,/%(au_path_date)s/A00671_D_AE_WBC_%(au_file_date)s%(ext)s,true
A00671_D_AE_SGB,,A00671_D_AE_SGB,%Y-%m-%d,%Y%m%d,true,.dat,/%(au_path_date)s/A00671_D_AE_SGB_%(au_file_date)s%(ext)s,true
A00671_W_ED_WBC,,A00671_W_ED_WBC,%Y-%m-%d,%Y%m%d,true,.dat,/%(au_path_date)s/A00671_W_ED_WBC_%(au_file_date)s%(ext)s,true
A00671_W_ED_SGB,,A00671_W_ED_SGB,%Y-%m-%d,%Y%m%d,true,.dat,/%(au_path_date)s/A00671_W_ED_SGB_%(au_file_date)s%(ext)s,true
Westpac_Monthly_WBG_report,,Westpac_Monthly_report,%Y-%m-%d,%b%y,true,.csv,/%(au_path_date)s/Westpac_Monthly_report_%(au_file_lastmonthdate)s%(ext)s,true
Westpac_Monthly_RAM_report,,Westpac_Monthly_report,%Y-%m-%d,%b%y,true,.csv,/%(au_path_date)s/Westpac_Rams_Monthly_report_%(au_file_lastmonthdate)s%(ext)s,true
Westpac_Weekly_WBG_report,,Westpac_Weekly_report,%Y-%m-%d,%Y%m%d,true,.csv,/%(au_path_date)s/Westpac_weekly_report%(ext)s,true
Westpac_Weekly_RAM_report,,Westpac_Weekly_report,%Y-%m-%d,%Y%m%d,true,.csv,/%(au_path_date)s/Westpac_Rams_weekly_report%(ext)s,true
```

---

## Step 3 — Seed Configuration in `dbt_project.yml`

Seeds under `seeds/bespoke/` are loaded into the external data services database:

```yaml
seeds:
  pexa_one_data_au_group_dbt:
    bespoke:
      +database: "{{env_var('DBT_GROUP_EXT_DATASERVICES_DB')}}"
      +schema: "OUTBOUND_SEEDS"
```

After running `dbt seed`, the table `PRD_GROUP_EXT_DATASERVICES.OUTBOUND_SEEDS.WESTPAC_EXTRACTS` exists in Snowflake.

---

## Step 4 — The Unload Macro

### `get_objects_to_unload`

This macro:
1. Saves and sets a `QUERY_TAG` for observability.
2. Selects the smallest available warehouse (cost optimisation).
3. Reads the seed config table via `{{ ref(loads_for) }}`.
4. Joins config rows against `information_schema.tables` to confirm the source view exists.
5. Optionally filters to a single object via `unload_object`.
6. Delegates to `pexa_one_data_au_dbt_common_lib.do_unload_to_s3(...)` which:
   - Lists existing files on the S3 stage to determine incremental state.
   - For each table: builds a temp table of rows to export, then runs `COPY INTO <stage>/<path>`.
   - Uses `SINGLE = TRUE/FALSE` based on the `unload_single_file` config.
   - Applies `HEADER = TRUE` so output files include column headers.
7. Resets warehouse and query tag.

### Macro Parameters

| Parameter | Description | Example |
|-----------|-------------|---------|
| `loads_for` | Name of the seed (used as `ref()`) | `westpac_extracts` |
| `table_catalog` | Database containing the source views | `PRD_GROUP_EXT_DATASERVICES` |
| `table_schema` | Schema containing the source views | `WESTPAC_DATASERVICES` |
| `db_name` | Database where the Snowflake stage lives | `PRD_GROUP_EXT_DATASERVICES` |
| `schema_name` | Schema where the Snowflake stage lives | `WESTPAC_DATASERVICES` |
| `stage_name` | Name of the external stage pointing to S3 | `PRD_BESPOKE_OUTBOUND_STAGE` |
| `file_format` | Named file format for COPY INTO | `CSV_FILE_FORMAT` |
| `filter_condition` | (Optional) Additional WHERE clause for filtering rows | `None` |
| `unload_object` | (Optional) Comma-separated list of specific table names to export | `Westpac_Monthly_RAM_report` |

---

## Step 5 — Running the Unload

### Full Westpac export (all objects)

```bash
dbt run-operation get_objects_to_unload --args "{
  loads_for: 'westpac_extracts',
  table_catalog: 'PRD_GROUP_EXT_DATASERVICES',
  table_schema: 'WESTPAC_DATASERVICES',
  db_name: 'PRD_GROUP_EXT_DATASERVICES',
  schema_name: 'WESTPAC_DATASERVICES',
  stage_name: 'PRD_BESPOKE_OUTBOUND_STAGE',
  file_format: 'CSV_FILE_FORMAT'
}"
```

### Single object export (e.g. monthly RAM report only)

```bash
dbt run-operation get_objects_to_unload --args "{
  loads_for: 'westpac_extracts',
  table_catalog: 'PRD_GROUP_EXT_DATASERVICES',
  table_schema: 'WESTPAC_DATASERVICES',
  db_name: 'PRD_GROUP_EXT_DATASERVICES',
  schema_name: 'WESTPAC_DATASERVICES',
  stage_name: 'PRD_BESPOKE_OUTBOUND_STAGE',
  file_format: 'CSV_FILE_FORMAT',
  unload_object: 'Westpac_Monthly_RAM_report'
}"
```

---

## S3 Output — File Paths

The stage `PRD_BESPOKE_OUTBOUND_STAGE` points to an S3 bucket. The final S3 key is constructed as:

```
<stage_root>/<ENV>/<path_prefix>/<output_path_format resolved>
```

### Westpac Examples (run date: 2025-05-22, Melbourne timezone)

| Report | Resulting S3 Path (relative to stage root) |
|--------|---------------------------------------------|
| Daily report | `PRD/Westpac_Daily_report/2025-05-22/Westpac_Daily_report_20250522.csv` |
| Daily users WBC | `PRD/A00671_D_AE_WBC/2025-05-22/A00671_D_AE_WBC_20250522.dat` |
| Daily users SGB | `PRD/A00671_D_AE_SGB/2025-05-22/A00671_D_AE_SGB_20250522.dat` |
| Weekly workgroups WBC | `PRD/A00671_W_ED_WBC/2025-05-22/A00671_W_ED_WBC_20250522.dat` |
| Weekly workgroups SGB | `PRD/A00671_W_ED_SGB/2025-05-22/A00671_W_ED_SGB_20250522.dat` |
| Monthly WBG report | `PRD/Westpac_Monthly_report/2025-05-22/Westpac_Monthly_report_Apr25.csv` |
| Monthly RAM report | `PRD/Westpac_Monthly_report/2025-05-22/Westpac_Rams_Monthly_report_Apr25.csv` |
| Weekly WBG report | `PRD/Westpac_Weekly_report/2025-05-22/Westpac_weekly_report.csv` |
| Weekly RAM report | `PRD/Westpac_Weekly_report/2025-05-22/Westpac_Rams_weekly_report.csv` |

Note: Monthly reports use `%(au_file_lastmonthdate)s` which resolves to the first day of the previous month formatted as `%b%y` (e.g. `Apr25` when run in May 2025).

---

## Incremental vs Full-Refresh Exports

| Mode | `incremental_timestamp_column` | Behaviour |
|------|-------------------------------|-----------|
| **Full refresh** | Empty/null | Exports all rows from the view every run. Used by all Westpac extracts. |
| **Incremental** | Column name (e.g. `RUN_STARTED_AT`) | Macro finds the latest timestamp in the most recent file on S3, then only exports rows newer than that timestamp. Used by logging exports. |

---

## Adding a New Bank / New Report

### To add a new report to an existing bank (e.g. Westpac):

1. Create the SQL view in `models/external_data_services/bespoke_reporting/westpac/`.
2. Add a row to `seeds/bespoke/westpac_extracts.csv` with the matching `table_name`.
3. Document the model in `westpac_model.yml`.
4. Run: `dbt seed --select westpac_extracts`
5. Run: `dbt run --select <new_model_name>`
6. Test the unload: `dbt run-operation get_objects_to_unload --args "{...unload_object: '<new_model_name>'}"` 

### To add a new bank:

1. Create directory: `models/external_data_services/bespoke_reporting/<bank>/`
2. Add schema routing in `dbt_project.yml` under `external_data_services.bespoke_reporting`:
   ```yaml
   <bank>:
     +schema: "<BANK>_DATASERVICES"
   ```
3. Create seed CSV: `seeds/bespoke/<bank>_extracts.csv` with the same column structure.
4. Create SQL views for each report.
5. Ensure the Snowflake stage and file format exist in the target schema.
6. Run seed, build models, then run the unload operation.

---

## Prerequisites (Snowflake Objects)

These must exist before the unload macro can run:

| Object | Example | Purpose |
|--------|---------|---------|
| External Stage | `PRD_GROUP_EXT_DATASERVICES.WESTPAC_DATASERVICES.PRD_BESPOKE_OUTBOUND_STAGE` | Points to the S3 bucket/prefix for file delivery |
| File Format | `PRD_GROUP_EXT_DATASERVICES.WESTPAC_DATASERVICES.CSV_FILE_FORMAT` | Defines CSV output format (delimiter, quoting, compression, etc.) |
| Source Views | `PRD_GROUP_EXT_DATASERVICES.WESTPAC_DATASERVICES.Westpac_Monthly_RAM_report` | The dbt models materialised as views |
| Seed Table | `PRD_GROUP_EXT_DATASERVICES.OUTBOUND_SEEDS.WESTPAC_EXTRACTS` | Config table loaded by `dbt seed` |

---

## Comparison: Bespoke (Westpac) vs Logging Exports

| Aspect | Bespoke (Westpac) | Logging |
|--------|-------------------|---------|
| `fmt_version` | `other` | `logging` |
| Incremental | No (full refresh) | Yes (timestamp-based) |
| File ext | `.csv` / `.dat` | None |
| Path structure | `<ENV>/<prefix>/<date>/<filename>` | `logs/<ENV>/<prefix>/<date>/<table>/<table>_<datetime>` |
| Single file | Yes (`SINGLE = TRUE`) | No (multi-part) |
| `output_path_format` | Custom per row | Not used (default template) |
