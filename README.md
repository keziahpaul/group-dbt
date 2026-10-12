# pexa-one-data-au-group-dbt

This repo is used to model data for various sources such as; salesforce, sendfx, finance and people applying business logic, protecting sensitive information and documenting models that are available for analysis.

This repo is the source for two different DBT Group projects:

- onedata-au-pexa-group (non-production)
- onedata-au-pexa-group-prod (production)

## Project Overview

This project implements the [Medallion Architecture](https://www.databricks.com/glossary/medallion-architecture), which is a data lake architecture pattern that champions the ELT methodology, prioritizing agility and speed in data ingestion while deferring complex transformations to later stages.

- **dbt_project.yml**: Central configuration for the project, instructs dbt how to interact with models, sources and more.

-  **models/curate**: Parsing, flattening, cleaning, transforming raw data into curated datasets

-  **models/data_services**: Analytics-ready data marts built from curated models

- **tests/generic**: Macros for data quality tests

- **macros**: Commonly used macros such as tagging and masking policies

- **helpers**: Python scripts to help automate manual tasks


## Getting Started

### Requirements

You may need to request access via PEXA access catalogue if don't already have access.

- DBT Cloud (developer)
- Snowflake Group AU (engineer)

### Setup on DBT Cloud

Reach out to ONEData team if assistance is required

**Project Credentials**: One time setup (already done)

**User Credentials**: One time setup (already done)
- For `Schema` - input your own name;  this will be the projects default if no schema is specificied in source code


## Environments

#### Non-Production

- **DEV**: runs against your `feature/**` branch
- **TEST**: runs against `develop` branch

#### Production

- **PST**: runs against a `release/**` branch
- **PRD**: runs against `main` branch

## Usage

### Local Development

We mostly do our development on DBT Cloud IDE, to deploy changes into DEV dbt commands are executed in Cloude IDE command. You can also validate your changes in Snowflake.

_future exploration:_ [dbt cloud cli](https://docs.getdbt.com/docs/cloud/cloud-cli-installation)

### DBT CI Jobs

DBT Jobs are abstracted by `environments` and `source`. This is so jobs can run in isolation without impacting downstreams of other sources.

In this project dbt jobs are separated by:


**Deploy Jobs**

Order of job execution is important; run these jobs if applicable to your development

1. `Job_to_create_tags_and_masking_policies`
- Only required to run when need to create new tags or new masking policies

2. `Sendfx Build Job`

3. `Salesforce outbound build job`

4. `Tag all PI tables`
- This needs to be run after build, if a table/view contains PI it will tag it with (yes / no ) values

5. `unload salesforce tables to s3`

6. `job_to_log_Group_objects_in_test`

## Contributing
**Issues:** Report bugs or request new features by creating a new issue or raising a JIRA ticket

**Pull Requests:** Follow the existing coding style and standards. Refer to the [contribution guidelines](CONTRIBUTING.md) for more details.

**Communication:** Join the #pexa-data-engineering-and-delivery channel on Slack