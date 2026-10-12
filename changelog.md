# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog and this project adheres to Semantic Versioning.

## [1.6] 2024-11-06

### Updated

**- Update PI Tag and Masking policy for Kapich Inbound**
- The **Customer Feedback** table, column **Subscriber Name** from <em>PI_FULL_NAME</em> to <em>PI_BUSINESS_NAME</em>.

## [1.5] 2024-10-17

### New

- Added send product related changes
    - send_subscriber_match_process
    - manual_send_subscriber_match
    - send_subscriber_match
    - send_subscriber_match_exception
    - send_transaction_details
    - buyer_seller_volume_per_workspace
    - send_product_holdings

### Updated

- product_servicestatus
- property
to include send fields

## [1.4] 2024-10-07
### Fixed

**- Fix '(No Value)' for kapiche inbound data**
- This occurs due to data issues from the source where we are casting Subscriber ID to a number its throwing because of the data its a string '(No Value)'
When we can also see there are multiple columns with '(No Value)' - for those fields, use a case statement to resolve.

**- Fix FSS Query**
- All the data in foreign address has been populated as incremental with an assumption that participant id can be treated as unique. However FSS line item query dint have a unique key. based on inputs provided by maddie we can assess and see if I can have it as incremental or full load

**- Update salesforce curate tests**
- Update correct target model when testing `expect_table_row_count_to_equal_other_table` for `stage_sendfx` model

### New

**- Kapiche inbound <em>customer_feedback</em> model with tagging and masking applied**

**- Kapiche outbound <em>customer_feedback_master</em> model with tagging and masking applied**

**- New <em>copy_from_src_to_target</em> macro**
- Copies delta (latest file/s) from <em>source_stage</em> to a <em>target_stage</em>.
Archive function on the Kapiche inbound <em><em>customer_feedback</em> model. When on model run it will run a `COPY FILES INTO` statement.


### Updated

**- modified foreign_address seed to include filter condition while unloading to s3**

**- refactor tests to use column_count_check macro**
- Standardizing the call we make for our data quality tests. Efforts towards keeping things DRY

**- Amendments to internaional_parties model**
- fix inmoment queries so that incremental strategy is standardized


## [1.3] No Version 1.3 due to versioning issues we've jumped to 1.4


## [1.2] 2024-07-29
### Fixed

- fixing party details
- inmoment fixes

### New

- Enabling masking in contacts and international_party tables
- Add delta column in scd2 exclude list

### Updated
- Changing path_prefix of logging seeds
- Handling case sensitive view names

## [1.1] 2024-07-08

### New

- Added deoendabot
- Contains changes for Salesforce, Send, Inmoment and Salesforce Outbound


## [1.0] 2024-06-07

### New

**Ingest INMOMENT data**

Newly ingested tables also are incremental
- TRANSACTIONS
- WORKSPACE_REVENUE
- PROJECTS_WORKSPACE
- PRODUCT_SERVICESTAUS
- USER_DETAILS
- CONTACTS

