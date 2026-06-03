# analytics

An analytics-engineering project built with **dbt**, running on both **DuckDB** and **Snowflake** from a single codebase.

## What it demonstrates

- **Dual-warehouse from one codebase** — the same models, tests, and lineage build on DuckDB (local, zero-setup) or Snowflake, selected entirely through dbt targets. No per-warehouse forks.
- **AI-native workflow** — built with [Claude Code](https://claude.com/claude-code) and a set of dbt skills driving model creation, testing, and documentation, with the analyst reviewing each step.
- **Hardened Snowflake connection** — a dedicated, least-privilege **service account** using **key-pair (JWT) auth** instead of a password, scoped to a sandbox role and database. The private key and real `profiles.yml` are git-ignored; only `profiles.example.yml` (placeholders) is committed.

## Architecture

![dbt lineage graph: seeds → staging → marts](docs/lineage.png)

```
seeds                staging (views)        marts (table)
─────                ───────────────        ─────────────
raw_customers  ──►   stg_customers   ──┐
                                       ├──►  customer_orders
raw_orders     ──►   stg_orders      ──┘
```

- **seeds/** — `raw_customers`, `raw_orders` (CSV sample data).
- **staging/** — `stg_customers`, `stg_orders`: 1:1 cleanup of the seeds (rename keys, cast types), materialized as **views**. `unique` + `not_null` tests on each primary key.
- **marts/** — `customer_orders`: one row per customer, built from `stg_customers LEFT JOIN stg_orders` so customers with no orders appear with zeroed metrics. Materialized as a **table**, with `unique` + `not_null` tests on `customer_id`.
- Models reference each other with `ref()`, so dbt resolves the full DAG and lineage automatically.

## Tech stack

`dbt-core` · `dbt-duckdb` · `dbt-snowflake` · **DuckDB** · **Snowflake**

## How to run

```bash
# 1. Clone
git clone <repo-url> && cd analytics

# 2. Install dbt and both adapters (a virtualenv is recommended)
pip install dbt-core dbt-duckdb dbt-snowflake

# 3. Configure your connection
cp profiles.example.yml ~/.dbt/profiles.yml
#    then edit ~/.dbt/profiles.yml and fill in your own values

# 4. Build (defaults to the local DuckDB target)
dbt seed          # load the CSV seeds
dbt build         # run models + tests
dbt docs generate # build the docs site (then: dbt docs serve)
```

Add `--target snowflake` to any command to run against Snowflake instead of DuckDB:

```bash
dbt build --target snowflake
```

## Data note

The seeds are currently small sample data, enough to exercise the models, tests, and dual-warehouse lineage end to end. The roadmap is to swap in real payments/transactions data, keeping the same staging → marts structure.
