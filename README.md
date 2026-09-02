# Semantic Layer (dbt)

Built as part of the Data Enablement initiative. The goal is a single, governed source of truth for business metrics that any downstream tool (Tableau, Metabase, an internal GPT interface) can consume, instead of each team maintaining its own definitions.

## What's in here

**Data model** (dbt, DuckDB)
- `staging/` – cleaned views on the raw Marketplace and Finance tables (bookings, offers, drivers, order financials). Fixes type casting, string `'null'` values, mixed date formats and duplicates.
- `intermediate_curated/` – `int_bookings` and `int_offers`, one row per booking / per offer, joined with driver and financial data and flagged for outliers.
- `mart_semantic/` – MetricFlow semantic models, metric definitions and the time spine.

**Metrics**
Consolidates previously conflicting definitions across Marketplace, Supply and Finance. Key decisions:
- `gmv` uses Finance's actual post-trip value, not the pre-trip fare estimate.
- The ambiguous "Acceptance Rate" is split into `booking_acceptance_rate` (did a booking get a driver) and `offer_acceptance_rate` (how often drivers accept an offer).
- "Active Drivers" is split into `active_drivers` (received an offer) and `accepting_drivers` (accepted one).
- `success_rate` and `cancellation_rate` are defined once at the booking level.

**Governance**
Every metric carries `meta` with an owner, a tier (1 = exec/cross-domain, 2 = team-internal) and RACI contacts. `governance/check_metrics.py` runs as a CI step and fails the build if a metric is missing a description or owner, or if a metric name is defined twice.