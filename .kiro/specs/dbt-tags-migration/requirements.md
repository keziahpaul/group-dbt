# Requirements Document

## Introduction

Migrate all PI (Personal Information) tagging in the dbt project from the legacy per-tag-type format (e.g. `pi_full_name`, `PI_EMAIL`) to the new dbt-tags 1.9.0+ governance tag format using two allowed tags (`secure_field`, `variant_mask`) with an `=` separator and uppercase values (e.g. `secure_field=PI_FULL_NAME`). This includes updating `dbt_project.yml` vars, converting all column-level tags in model YAML files, removing legacy masking policy macros, removing legacy `pre_sql` config items, and adding a new project-wide `+pre_sql` that calls the tag-removal stored procedure. Additionally, all column-level `tags` properties are relocated from direct column properties to `config.tags` to comply with the dbt 1.10 `PropertyMovedToConfigDeprecation`. The migration also incorporates AI-corrected tag anomalies from a validated CSV extraction, applying confirmed corrections to model YAML files where columns are missing tags or have incorrect tag values.

## Glossary

- **dbt_tags**: A dbt package (`infinitelambda/dbt_tags`) that manages Snowflake column-level governance tags. Currently at version 1.9.0 via the common lib transitive dependency.
- **PI_Tag**: A Personal Information tag identifying the masking type for a sensitive column (e.g. `PI_FULL_NAME`, `PI_EMAIL`, `PI_USERID`).
- **Allowed_Tag**: One of the two governance tag names permitted under the new format: `secure_field` or `variant_mask`.
- **Tag_Value**: The uppercase masking type that follows the `=` separator in the new tag format (e.g. `PI_FULL_NAME`, `PI_EMAIL`).
- **Tag_Separator**: The `=` character used to separate the allowed tag name from the tag value.
- **Legacy_Tag**: A tag in the old format where the PI type is the entire tag name (e.g. `pi_full_name`, `PI_EMAIL`).
- **Tag_Removal_Procedure**: A Snowflake stored procedure that removes stale governance tags from models prior to applying the current set.
- **dbt_project.yml**: The root project configuration file that defines vars, model configs, hooks, and materializations.
- **Model_YAML**: A YAML file (e.g. `models.yml`, `cdm_models.yml`) that defines column metadata, tests, and tags for dbt models.
- **Common_Lib**: The private `pexa-one-data-au-dbt-common-lib` Git package providing shared macros for masking policies, tagging, schema generation, and SCD2.
- **Masking_Policy_Macro**: A macro in `common_macros.sql` that wraps a Common_Lib masking policy creation function (e.g. `create_masking_policy__pi_email`).
- **Migration_Engine**: The combination of scripts, manual edits, and dbt operations that execute this tag migration.
- **PropertyMovedToConfigDeprecation**: A dbt 1.10 deprecation warning triggered when column-level properties like `tags` are defined as direct properties instead of under the `config` block. Requires moving `tags` from a direct column property to `config.tags`.
- **Anomaly_CSV**: A CSV file (TAG-Anomalies-Extraction-AI) containing column-level tag anomalies identified across Snowflake tables. Columns include CATALOG, SCHEMA, TABLE_NAME, COLUMN_NAME, DATA_TYPE, COMMENT, COLUMN_DEFAULT, CURRENT_TAG_DATABASE, CURRENT_TAG_SCHEMA, CURRENT_TAG_NAME, CURRENT_TAG_VALUE, AI_TAG, AI_CORRECTION, and CONFIRMED.
- **AI_Correction**: The corrected tag value provided by AI analysis in the Anomaly_CSV (e.g. `PI_FULL_NAME`, `PI_BUSINESS_NAME`, `PI_EMAIL`). This value becomes the Tag_Value in the `secure_field=<AI_CORRECTION>` format.
- **CONFIRMED_Row**: A row in the Anomaly_CSV where the CONFIRMED column equals `CONFIRMED`, indicating the AI correction has been validated and approved for application.

## Requirements

### Requirement 1: Update dbt_tags Package Version

**User Story:** As a data engineer, I want the dbt_tags package to be at version 1.9.0 or higher, so that the new governance tag features are available.

#### Acceptance Criteria

1. THE Migration_Engine SHALL verify that the dbt_tags package resolved in `package-lock.yml` is at version 1.9.0 or higher.
2. IF the dbt_tags package version is below 1.9.0, THEN THE Migration_Engine SHALL update the Common_Lib dependency or add a direct dbt_tags dependency in `packages.yml` to resolve version 1.9.0 or higher.
3. WHEN `dbt deps` is executed after the version update, THE Migration_Engine SHALL confirm that dbt_tags 1.9.0 or higher is installed without dependency conflicts.

### Requirement 2: Configure New Governance Tag Vars in dbt_project.yml

**User Story:** As a data engineer, I want the `dbt_project.yml` vars section to include the new governance tag configuration, so that dbt_tags enforces the allowed tag names and separator.

#### Acceptance Criteria

1. THE Migration_Engine SHALL add the var `dbt_tags__opt_in_default_naming_config` with value `false` to the `vars` section of `dbt_project.yml`.
2. THE Migration_Engine SHALL add the var `dbt_tags__allowed_tags` with value `["secure_field", "variant_mask"]` to the `vars` section of `dbt_project.yml`.
3. THE Migration_Engine SHALL add the var `dbt_tags__tag_name_separator` with value `"="` to the `vars` section of `dbt_project.yml`.
4. THE Migration_Engine SHALL retain all existing `dbt_tags__` vars (`dbt_tags__database`, `dbt_tags__schema`, `dbt_tags__resource_types`, `dbt_tags__policy_data_types`) unchanged.

### Requirement 3: Convert Column-Level Tags to New Format

**User Story:** As a data engineer, I want all column-level PI tags in Model_YAML files to use the new `secure_field=<VALUE>` format, so that masking is governed by the new tag structure.

#### Acceptance Criteria

1. WHEN a column in a Model_YAML file has a Legacy_Tag (e.g. `pi_full_name`, `PI_EMAIL`), THE Migration_Engine SHALL replace the Legacy_Tag with the format `<Allowed_Tag>=<TAG_VALUE>` where the Allowed_Tag is `secure_field` (lowercase) and the Tag_Value is the legacy PI type in uppercase (e.g. `secure_field=PI_FULL_NAME`).
2. THE Migration_Engine SHALL preserve the tag case convention: the Allowed_Tag portion is lowercase (`secure_field`) and the Tag_Value portion after the separator is uppercase (e.g. `PI_FULL_NAME`).
3. THE Migration_Engine SHALL convert tags in all Model_YAML files across all layers: raw, staging, curate, common_data_layer, internal_data_services, and external_data_services.
4. THE Migration_Engine SHALL handle tags defined both inside `config.tags` blocks and as direct `tags` properties on columns.
5. IF a column has multiple Legacy_Tags, THEN THE Migration_Engine SHALL convert each Legacy_Tag individually to the new format.

### Requirement 4: Remove All Model-Level Tags from dbt_project.yml

**User Story:** As a data engineer, I want all model-level `+tags` lists in `dbt_project.yml` removed entirely, so that tag governance is managed exclusively through column-level tags in Model_YML files.

#### Acceptance Criteria

1. THE Migration_Tool SHALL remove any `+tags` list under any model section in the dbt_project_config (e.g. `data_services.exchange.+tags`)
2. THE Migration_Tool SHALL NOT add replacement tags in the dbt_project_config — all tag definitions are managed at the column level in Model_YML files
3. THE Migration_Tool SHALL preserve all other model configuration properties (e.g. `+schema`, `+copy_grants`, `+materialized`) unchanged

### Requirement 5: Remove Legacy Masking Policy Macros

**User Story:** As a data engineer, I want all legacy masking policy creation macros removed from the project, so that the codebase no longer references the old masking approach.

#### Acceptance Criteria

1. THE Migration_Engine SHALL remove all `create_masking_policy__*` macro definitions from `macros/common_macros.sql`.
2. THE Migration_Engine SHALL remove the `create_additional_masking_policies_and_tags` macro definition from `macros/common_macros.sql`.
3. THE Migration_Engine SHALL remove the `tag_PI_table` macro definition from `macros/common_macros.sql`.
4. THE Migration_Engine SHALL remove the `apply_tags_to_source` macro definition from `macros/common_macros.sql`.
5. IF any SQL model files reference the removed macros directly, THEN THE Migration_Engine SHALL remove those references.

### Requirement 6: Remove Legacy pre_sql Config Items

**User Story:** As a data engineer, I want all pre-existing `pre_sql` config items that alter tags to be removed, so that stale tag manipulation logic does not conflict with the new approach.

#### Acceptance Criteria

1. THE Migration_Engine SHALL scan all model SQL files and Model_YAML files for `pre_sql` config items that reference tag alteration operations.
2. WHEN a `pre_sql` config item references legacy tag operations, THE Migration_Engine SHALL remove the `pre_sql` config item from the model.
3. THE Migration_Engine SHALL not remove `pre_sql` config items that are unrelated to tag operations.

### Requirement 7: Add Tag Removal Pre-Hook at Project Level

**User Story:** As a data engineer, I want a `+pre-hook` configuration added at the top model level to execute the tag removal stored procedure before tag application on all models, so that stale tags from previous runs are cleaned up.

#### Acceptance Criteria

1. THE dbt_project_config SHALL define a `+pre-hook` configuration at the top `models.pexa_one_data_au_exchange_dbt` level that calls `STRIP_COLUMN_TAGS` for all models
2. WHEN any model is built, THE Migration_Tool SHALL execute the Tag_Removal_Stored_Procedure before the Post_Hook applies new tags
3. THE `+pre-hook` configuration SHALL be placed alongside the existing `+post-hook` at the top model level, not scoped to individual layers
4. THE Tag_Removal_Stored_Procedure is assumed to already exist in the governance schema and is not created as part of this migration

### Requirement 8: Validate Tag Migration Completeness

**User Story:** As a data engineer, I want to verify that no Legacy_Tags remain in the project after migration, so that the migration is complete and consistent.

#### Acceptance Criteria

1. WHEN the migration is complete, THE Migration_Engine SHALL confirm that zero Legacy_Tags (matching pattern `pi_*` or `PI_*` as standalone tag values) remain in any Model_YAML file.
2. WHEN the migration is complete, THE Migration_Engine SHALL confirm that zero Legacy_Tags remain in any `+tags` list in `dbt_project.yml`.
3. WHEN the migration is complete, THE Migration_Engine SHALL confirm that all column tags in Model_YAML files follow the pattern `<allowed_tag>=<UPPERCASE_VALUE>` where `<allowed_tag>` is one of `secure_field` or `variant_mask`.
4. WHEN the migration is complete, THE Migration_Engine SHALL confirm that zero `create_masking_policy__*` macros remain in `macros/common_macros.sql`.

### Requirement 9: Preserve Existing dbt Functionality

**User Story:** As a data engineer, I want the migration to preserve all existing dbt functionality (model materialization, tests, hooks, incremental strategies), so that the tag migration does not introduce regressions.

#### Acceptance Criteria

1. THE Migration_Engine SHALL not modify any SQL model logic, materialization configs, test definitions, or incremental strategies.
2. THE Migration_Engine SHALL retain the existing `+post-hook` that calls `dbt_tags.apply_column_tags()` in `dbt_project.yml`.
3. WHEN `dbt build` is executed after migration, THE Migration_Engine SHALL confirm that all models compile and run without errors related to tag configuration.
4. THE Migration_Engine SHALL not modify any environment variable references, database/schema routing, or seed configurations.

### Requirement 11: Move Column-Level Tags Under config.tags (dbt 1.10 PropertyMovedToConfigDeprecation)

**User Story:** As a data engineer, I want all column-level `tags` properties in Model_YAML files moved under `config.tags` instead of being direct column properties, so that the project complies with the dbt 1.10 `PropertyMovedToConfigDeprecation` and avoids deprecation warnings.

#### Acceptance Criteria

1. WHEN a column in a Model_YAML file has a `tags` property defined as a direct sibling of `name`, `description`, or `config`, THE Migration_Engine SHALL move the `tags` list under the column's `config` block as `config.tags`.
2. THE Migration_Engine SHALL preserve the tag values unchanged during the relocation (e.g. `secure_field=PI_FULL_NAME` remains `secure_field=PI_FULL_NAME`).
3. THE Migration_Engine SHALL relocate column-level tags in all Model_YAML files across all layers: raw, staging, curate, common_data_layer, internal_data_services, and external_data_services.
4. IF a column already has a `config` block (e.g. containing `meta`), THEN THE Migration_Engine SHALL merge the `tags` list into the existing `config` block rather than creating a duplicate `config` key.
5. IF a column does not have an existing `config` block, THEN THE Migration_Engine SHALL create a new `config` block containing the `tags` list.
6. WHEN the migration is complete, THE Migration_Engine SHALL confirm that zero direct column-level `tags` properties remain outside of `config` blocks in any Model_YAML file.
7. THE Migration_Engine SHALL perform this relocation in the same editing pass as the tag format conversion (Requirement 3) to avoid touching files twice.

### Requirement 10: Production Deployment Sequencing

**User Story:** As a data engineer, I want the tag migration deployed to production before proceeding to subsequent migration steps, so that governance tags are active in production before downstream changes depend on them.

#### Acceptance Criteria

1. THE Migration_Engine SHALL be deployable to the `onedata-au-pexa-group` non-production environments (DEV, TEST) for validation before production.
2. WHEN validation passes in non-production, THE Migration_Engine SHALL be deployable to the `onedata-au-pexa-group-prod` environments (PST, PRD).
3. THE Migration_Engine SHALL complete production deployment before any subsequent migration steps (step 3 and beyond) are initiated.

### Requirement 12: Apply AI-Corrected Tags from Anomaly CSV

**User Story:** As a data engineer, I want AI-corrected tag values from the Anomaly_CSV applied to the appropriate Model_YAML files, so that columns identified as incorrectly tagged or missing tags are corrected based on validated AI analysis.

#### Acceptance Criteria

1. THE Migration_Engine SHALL process only rows in the Anomaly_CSV where the CONFIRMED column equals `CONFIRMED`.
2. THE Migration_Engine SHALL ignore rows where CONFIRMED is empty, `FALSE`, or any value other than `CONFIRMED`.
3. WHEN a CONFIRMED_Row has an AI_CORRECTION value, THE Migration_Engine SHALL apply the tag `secure_field=<AI_CORRECTION>` to the corresponding column in the Model_YAML file, where `<AI_CORRECTION>` is the uppercase value from the AI_CORRECTION column (e.g. `secure_field=PI_FULL_NAME`).
4. THE Migration_Engine SHALL resolve the target Model_YAML file by mapping the Anomaly_CSV TABLE_NAME to the dbt model name, accounting for the project's layer structure (raw, staging, curate, common_data_layer, internal_data_services, external_data_services) and any model aliases defined in `dbt_project.yml`.
5. THE Migration_Engine SHALL use the CATALOG and SCHEMA columns from the Anomaly_CSV to disambiguate models that share a TABLE_NAME across different databases or schemas.
6. WHEN a CONFIRMED_Row identifies a column that currently has no tag in the Model_YAML file, THE Migration_Engine SHALL add a new `config.tags` entry with `secure_field=<AI_CORRECTION>` to that column definition.
7. WHEN a CONFIRMED_Row identifies a column that has an existing tag value differing from the AI_CORRECTION, THE Migration_Engine SHALL update the existing tag to `secure_field=<AI_CORRECTION>`.
8. WHEN a CONFIRMED_Row identifies a column whose existing tag already matches `secure_field=<AI_CORRECTION>`, THE Migration_Engine SHALL leave the tag unchanged.
9. THE Migration_Engine SHALL match the COLUMN_NAME from the Anomaly_CSV to the column `name` property in the Model_YAML file using case-insensitive comparison.
10. IF a TABLE_NAME or COLUMN_NAME from a CONFIRMED_Row cannot be resolved to a model or column in the project, THEN THE Migration_Engine SHALL log a warning identifying the unresolved row without failing the overall process.
11. THE Migration_Engine SHALL place all new or updated tags under `config.tags` on the column definition, consistent with Requirement 11 (PropertyMovedToConfigDeprecation compliance).
12. THE Migration_Engine SHALL ONLY apply corrections to columns explicitly listed in the Anomaly_CSV — it SHALL NOT modify tags on any table or column that does not appear as a row in the CSV.
13. THE Migration_Engine SHALL scope corrections strictly to the CATALOG, SCHEMA, TABLE_NAME, and COLUMN_NAME combination specified in each CONFIRMED_Row — no inference or expansion to other columns within the same table is permitted.
