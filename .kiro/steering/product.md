---
inclusion: always
---

# Product Overview

This is **pexa-one-data-au-group-dbt** — a dbt project that models data for PEXA's Australian Group business unit.

PEXA is a digital property exchange platform. This project ingests, transforms, and serves data from multiple sources:

- **Exchange** (core PEXA platform): workspaces, settlements, participants, subscribers, properties
- **Salesforce**: CRM data (accounts, contacts, opportunities, cases)
- **SendFX**: foreign exchange / payment data
- **FMS (Finance Management System)**: D365 financial data (invoices, journals, vendors, customers)
- **Jira**: project and incident tracking
- **Genesys**: call centre data
- **Kapiche**: customer feedback / NPS

## Key Domain Concepts

- **Workspace**: a transaction workspace in the PEXA Exchange for property settlements
- **Subscriber**: an organisation registered on the PEXA platform (law firms, banks, etc.)
- **Settlement**: the financial settlement event for a property transaction
- **Jurisdiction**: Australian state/territory governing the transaction
- **SCD2**: Slowly Changing Dimension Type 2, used extensively in the common data layer for historical tracking via `effective_from` / `effective_to` columns

## Environments

Two dbt Cloud projects consume this repo:
- `onedata-au-pexa-group` (non-production: DEV, TEST)
- `onedata-au-pexa-group-prod` (production: PST, PRD)
