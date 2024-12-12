# dbt_recharge_source v0.3.1
[PR #15](https://github.com/fivetran/dbt_recharge_source/pull/15) includes the following updates:

## Bugfix
- Updated the `is_most_recent_record` field in `stg_recharge__subscription_history` to partition by `id`, or by `subscription_id` if `id` is unavailable in the source table. Previously, partitioning occurred solely on `subscription_id` (prior to applying COALESCE), which was unintended and caused errors in Redshift when the source table only contained `id`.

# dbt_recharge_source v0.3.0
[PR #13](https://github.com/fivetran/dbt_recharge_source/pull/13) includes the following updates:
## Breaking Changes
- The following columns were added to model `stg_recharge__address`:
  - country
  - payment_method_id
  - Note: If you have already added any of these fields as passthrough columns to the `recharge__address_passthrough_columns` var, you will need to remove or alias these fields from the var to avoid duplicate column errors.

## Features
- Added staging model `stg_recharge__checkout`. See [this doc](https://fivetran.github.io/dbt_recharge_source/#!/model/model.recharge_source.stg_recharge__checkout) for the fields added and their definitions.
  - This model is disabled by default but can be enabled by setting variable `recharge__checkout_enabled` to true in your `dbt_project.yml` file. See the [Enable/disable models and sources section](https://github.com/fivetran/dbt_recharge_source/blob/main/README.md#step-4-enable-disable-models-and-sources) of the README for more information.
  - This model can also be passed additional columns beyond the predefined columns by using the variable `recharge__checkout_passthrough_columns`. See the [Passing Through Additional Columns](https://github.com/fivetran/dbt_recharge_source/blob/main/README.md#passing-through-additional-columns) section of the README for more information on how to set this variable.

- Added the following columns to model `stg_recharge__customer`. See [this doc](https://fivetran.github.io/dbt_recharge_source/#!/model/model.recharge_source.stg_recharge__customer) for field definitions.
  - `billing_first_name`
  - `billing_last_name`
  - `billing_company`
  - `billing_city`
  - `billing_country`

## Under the hood
- Updated `stg_recharge__subscription_history` to coalesce `id` and `subscription_id` as the `subscription_id` since either version can be present in the source.

# dbt_recharge_source v0.2.0
[PR #12](https://github.com/fivetran/dbt_recharge_source/pull/12) includes the following updates:

## Features
- For Fivetran Recharge connectors created on or after June 18, 2024, the `ORDER` source table has been renamed to `ORDERS`. The package will now use the `ORDERS` table if it exists and then `ORDER` if not.  
  - If you have both versions but wish to use the `ORDER` table instead, you can set the variable `recharge__using_orders` to false in your `dbt_project.yml`.
  - See the [June 2024 connector release notes](https://fivetran.com/docs/connectors/applications/recharge/changelog#june2024) and the related
   [README section](https://github.com/fivetran/dbt_recharge_source/blob/main/README.md##leveraging-orders-vs-orders-source) for more details.

## Under the Hood:
- Updated the pull request templates.
- Included auto-releaser GitHub Actions workflow to automate future releases.

# dbt_recharge_source v0.1.1
[PR #10](https://github.com/fivetran/dbt_recharge_source/pull/10) includes the following updates:
## Bug fixes
- In `stg_recharge__subscription_history`, updated model to use the source's `updated_at` column to determine most recent record. This column is part of the primary key for the history table and is definitive, while the prior `_fivetran_synced` was less meaningful.

# dbt_recharge_source v0.1.0
🎉 This is the initial release of this package! 🎉
## 📣 What does this dbt package do?
- Materializes [Recharge staging tables](https://fivetran.github.io/dbt_recharge_source/#!/overview/recharge_source/models/?g_v=1&g_e=seeds), which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/recharge#schemainformation). These staging tables clean, test, and prepare your Recharge data from [Fivetran's connector](https://fivetran.com/docs/applications/recharge) for analysis by doing the following:
  - Names columns for consistency across all packages and for easier analysis
  - Adds freshness tests to source data
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your Recharge data through the [dbt docs site](https://fivetran.github.io/dbt_recharge_source/).
- These tables are designed to work simultaneously with our [Recharge transformation package](https://github.com/fivetran/dbt_recharge).
- For more information refer to the [README](/README.md).
