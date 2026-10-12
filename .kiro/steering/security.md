# Security & Data Governance

## PI (Personal Information) Classification
All models containing personal information are tagged and masked. Tags are applied via `dbt_tags` post-hooks on every `dbt run`/`dbt build`.

### PI Tag Types
- `PI_SENSITIVE_FINANCIAL` — Financial data (account numbers, balances)
- `PI_CONTACT_NUMBER` — Phone numbers
- `PI_DOB` — Date of birth
- `PI_EMAIL` — Email addresses
- `PI_FAX` — Fax numbers
- `PI_FREE_TEXT_FIELD` — Free-form text that may contain PI
- `PI_FULL_ADDRESS` — Complete addresses
- `PI_PARTIAL_ADDRESS` — Partial address components
- `PI_FULL_NAME` — Full name fields
- `PI_NAME` — Individual name components
- `PI_SENSITIVE` — General sensitive data
- `PI_USERID` — User identifiers
- `PI_MULTI` — Columns containing multiple PI types
- `PI_BUSINESS_NAME` — Business/organization names
- `PI_FLAG_SENSITIVE` — Boolean flags indicating sensitivity

### Masking Policies
Each PI tag has a corresponding masking policy created via `create_masking_policy__<tag_name>` macros. Policies are stored in the governance database (`DBT_GOVERNANCE_DB.DBT_GOVERNANCE_SCHEMA`).

### Row Access Policies
- FMS staging models have row access policies: `stage_row_access_policy on (id)`
- Raw layer materialized views reference `compliance.raw_layer_row_access_policy`

## Credential Management
- Git credentials for private package repo use `DBT_ENV_SECRET_GIT_CREDENTIAL` (dbt Cloud secret)
- All database/schema references use environment variables — no hardcoded values
- dbt Cloud manages Snowflake connection credentials per environment

## Data Sharing (External)
- Bespoke bank reports (ANZ, CBA, Westpac, NAB) are materialized as views in `DBT_GROUP_EXT_DATASERVICES_DB`
- Kapiche outbound data shared via external data services
- Salesforce outbound data unloaded to S3 via macro operations

## When Modifying Models
- Always check if the model has PI tags in its YML definition
- New columns containing PI must be tagged appropriately in the model's YML
- Run `Tag all PI tables` job after any build that adds/modifies PI columns
- Run `Job_to_create_tags_and_masking_policies` if introducing a new PI tag type
- Never expose raw PI data in external data services without masking
