# dbt_shopify_source v0.12.1

## 🪲 Bug Fixes 🪛
- Added support for a new `delayed` fulfillment event status from Shopify. `delayed` has been added to the `accepted_values` test on `stg_shopify__fulfillment_event` ([PR #84](https://github.com/fivetran/dbt_shopify_source/pull/84)).
- Added `product_id` to the unique `combination_of_columns` test for the `stg_shopify__product_image` model ([PR #86](https://github.com/fivetran/dbt_shopify_source/pull/86)).

## Contributors
- [@ryan-brainforge](https://github.com/ryan-brainforge) ([PR #86](https://github.com/fivetran/dbt_shopify_source/pull/86))
- [@shreveasaurus](https://github.com/shreveasaurus) ([PR #84](https://github.com/fivetran/dbt_shopify_source/pull/84))

# dbt_shopify_source v0.12.0

[PR #79](https://github.com/fivetran/dbt_shopify_source/pull/79) introduces the following changes: 
## 🚨 Breaking Changes 🚨
- To reduce storage, updated default materialization of staging models from tables to views. 
  - Note that `stg_shopify__metafield` will still be materialized as a table for downstream use.
>  ⚠️ Running a `--full-refresh` will be required if you have previously run these staging models as tables and get the following error: 
> ```
> Trying to create view <model path> but it currently exists as a table. Either drop <model path> manually, or run dbt with `--full-refresh` and dbt will drop it for you.
> ```

## Under the Hood
- Updated the maintainer PR template to the current format.
- Added integration testing pipeline for Databricks SQL Warehouse.

[PR #81](https://github.com/fivetran/dbt_shopify_source/pull/81) introduces the following changes: 
## 🪲 Bug Fixes 🪛
- Removed the `index` filter in `stg_shopify__order_discount_code`, as we were erroneously filtering out multiple discounts for an order since `index` is meant to pair with `order_id` as the unique identifier for this source.
- Added `index` as a field in `stg_shopify__order_discount_code`, as it is part of the primary key.

## 📝 Documentation Updates 📝
- Added `index` documentation to our `src_shopify.yml` and `stg_shopify.yml`.
- Updated the `unique_combination_of_columns` test on `stg_shopify__order_discount_code` to correctly check on `index` with `order_id` and `source_relation` rather than `code`.

## 🔧 Under the Hood 🔩
- Updated the pull request templates.

# dbt_shopify_source v0.11.0
[PR #78](https://github.com/fivetran/dbt_shopify_source/pull/78) introduces the following changes: 

## 🚨 Breaking Changes 🚨
- Added `source_relation` to the `partition_by` clauses that determine the `is_most_recent_record` in the `stg_shopify__metafield` table.
- Added `source_relation` to the `partition_by` clauses that determines the `index` in the `stg_shopify__abandoned_checkout_discount_code` table. 
- If the user is leveraging the union feature, this could change data values.

## 🐛 Bug Fixes 🪛 
- Updated partition logic in `stg_shopify__metafield` and `stg_shopify__abandoned_checkout_discount_code` to account for null table Redshift errors when handling null field cases. 

## 🚘 Under The Hood 🚘
- Included auto-releaser GitHub Actions workflow to automate future releases.
- Added additional casting in seed dependencies for above models `integration_tests/dbt_project.yml` to ensure local testing passed on null cases.

# dbt_shopify_source v0.10.0
## 🚨 Breaking Changes 🚨
- This release will be a breaking change due to the removal of below dependencies.
## Dependency Updates
- Removes the dependency on [dbt-expectations](https://github.com/calogica/dbt-expectations/releases) and updates the [dbt-date](https://github.com/calogica/dbt-date/releases) dependency to the latest version. ([PR #75](https://github.com/fivetran/dbt_shopify_source/pull/75))

# dbt_shopify_source v0.9.0
## Breaking Changes
- In [June 2023](https://fivetran.com/docs/applications/shopify/changelog#june2023) the Shopify connector received an update which upgraded the connector to be compatible with the new [2023-04 Shopify API](https://shopify.dev/docs/api). As a result, the following fields have been removed as they were deprecated in the API upgrade: ([PR #70](https://github.com/fivetran/dbt_shopify_source/pull/70))

| **model** | **field removed** |
|-------|--------------|
| [stg_shopify__customer](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__customer) | `lifetime_duration` |
| [stg_shopify__order_line](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order_line) | `fulfillment_service` |
| [stg_shopify__order_line](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order_line) | `destination_location_*` fields |
| [stg_shopify__order_line](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order_line) | `origin_location_*` fields |
| [stg_shopify__order](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order) | `total_price_usd` |
| [stg_shopify__order](https://fivetran.github.io/dbt_shopify/#!/model/model.shopify_source.stg_shopify__order) | `processing_method` |

## Under the Hood
- Removed `databricks` from the shopify_database configuration in the `src_shopify.yml` to allow Databricks Unity catalog users to define a unity Catalog as a database. ([PR #70](https://github.com/fivetran/dbt_shopify_source/pull/70))

## Documentation Updates
- Documentation provided in the README for how to connect sources when leveraging the union schema/database feature. ([PR #70](https://github.com/fivetran/dbt_shopify_source/pull/70))

# dbt_shopify_source v0.8.3

## Bug Fixes 🐛 🪛 
[PR #69](https://github.com/fivetran/dbt_shopify_source/pull/69) includes the following fixes:
- Lower casing `metafield_reference` field in `stg_shopify__metafield` to fix metafield table breakages upstream when the `key` field has different casing for otherwise identical strings.
- Lower casing `owner_resource` field in `stg_shopify__metafield` to ensure identical `value` fields with different casing are then correctly pivoted together upstream in the shopify transformation package `get_metafields` macro. 
 
## Contributors
- [@ZCrookston](https://github.com/ZCrookston) & [@FridayPush](https://github.com/FridayPush) ([Issue #64](https://github.com/fivetran/dbt_shopify_source/issues/64))

## Under the Hood:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. ([PR #65](https://github.com/fivetran/dbt_shopify_source/pull/65/files))
- Updated the pull request [templates](/.github). ([PR #65](https://github.com/fivetran/dbt_shopify_source/pull/65/files))

# dbt_shopify_source v0.8.2

## Bug Fixes
[PR #59](https://github.com/fivetran/dbt_shopify_source/pull/59) introduces the following changes:
- The `fivetan_utils.union_data` [macro](https://github.com/fivetran/dbt_fivetran_utils/pull/100) has been expanded to handle checking if a source table exists. Previously in the Shopify source package, this check happened outside of the macro and depended on the user having a defined shopify `source`. If the package anticipates a table that you do not have in any schema or database, it will return a **completely** empty table (ie `limit 0`) that will work seamlessly with downstream transformations.
  - A compilation message will be raised when a staging model is completely empty. This compiler warning can be turned off by the end user by setting the `fivetran__remove_empty_table_warnings` variable to `True` (see https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#union_data-source for details).
- A uniqueness test has been placed on the `order_line_id`, `index`, and `source_relation` columns in `stg_shopify__tax_line`, as it was previously missing a uniqueness test.

## Contributors
- [@dfagnan](https://github.com/dfagnan) (Issue https://github.com/fivetran/dbt_shopify_source/issues/57)

# dbt_shopify_source v0.8.1

## Bug Fixes
- Addresses [Issue #54](https://github.com/fivetran/dbt_shopify_source/issues/54), in which the deprecated `discount_id` field was used instead of `code` in `stg_shopify__abandoned_checkout_discount__code` ([PR #56](https://github.com/fivetran/dbt_shopify_source/pull/56)).

# dbt_shopify_source v0.8.0

Lots of new features ahead!! We've revamped the package to keep up-to-date with new additions to the Shopify connector and feedback from the community. 

This release includes 🚨 **Breaking Changes** 🚨.

## Documentation
- Created the [DECISIONLOG](https://github.com/fivetran/dbt_shopify_source/blob/main/DECISIONLOG.md) to log discussions and opinionated stances we took in designing the package ([PR #45](https://github.com/fivetran/dbt_shopify_source/pull/45)).
- README updated for easier package use and navigation ([PR #38](https://github.com/fivetran/dbt_shopify_source/pull/38)).

## Under the Hood 
- Ensured Postgres compatibility ([PR #38](https://github.com/fivetran/dbt_shopify_source/pull/38)).
- Got rid of the `shopify__using_order_adjustment`, `shopify__using_order_line_refund`, and `shopify__using_refund` variables. Instead, the package will automatically create empty versions of the related models until the source `refund`, `order_line_refund`, and `order_adjustment` tables exist in your schema. See DECISIONLOG for more details ([PR #45](https://github.com/fivetran/dbt_shopify_source/pull/45)).
- Adjusts the organization of the `get_<table>_columns()` macros ([PR #39](https://github.com/fivetran/dbt_shopify_source/pull/39), [PR #40](https://github.com/fivetran/dbt_shopify_source/pull/40)).

## Feature Updates
- Addition of the `shopify_timezone` variable, which converts ALL timestamps included in the package (including `_fivetran_synced`) to a single target timezone in IANA Database format, ie "America/Los_Angeles" ([PR #41](https://github.com/fivetran/dbt_shopify_source/pull/41)).
- `shopify_<default_source_table_name>_identifier` variables added if an individual source table has a different name than the package expects ([PR #38](https://github.com/fivetran/dbt_shopify_source/pull/38)).
- The declaration of passthrough variables within your root `dbt_project.yml` has changed (but is backwards compatible). To allow for more flexibility and better tracking of passthrough columns, you will now want to define passthrough columns in the following format ([PR #40](https://github.com/fivetran/dbt_shopify_source/pull/40)):
> This applies to all passthrough columns within the `dbt_shopify_source` package and not just the `customer_pass_through_columns` example. See the README for which models have passthrough columns.
```yml
vars:
  customer_pass_through_columns:
    - name: "my_field_to_include" # Required: Name of the field within the source.
      alias: "field_alias" # Optional: If you wish to alias the field within the staging model.
      transform_sql: "cast(field_alias as string)" # Optional: If you wish to define the datatype or apply a light transformation.
```
- The following fields have been added to (➕) or removed from (➖) their respective staging models ([PR #39](https://github.com/fivetran/dbt_shopify_source/pull/39), [PR #40](https://github.com/fivetran/dbt_shopify_source/pull/40)):
  - `stg_shopify__order`:
    - ➕ `total_discounts_set`
    - ➕ `total_line_items_price_set`
    - ➕ `total_price_usd`
    - ➕ `total_price_set`
    - ➕ `total_tax_set`
    - ➕ `total_tip_received`
    - ➕ `is_deleted`
    - ➕ `app_id`
    - ➕ `checkout_id`
    - ➕ `client_details_user_agent`
    - ➕ `customer_locale`
    - ➕ `order_status_url`
    - ➕ `presentment_currency`
    - ➕ `is_confirmed`
  - `stg_shopify__customer`:
    - ➕ `note`
    - ➕ `lifetime_duration`
    - ➕ `currency`
    - ➕ `marketing_consent_state` (coalescing of `email_marketing_consent_state` and deprecated `accepts_marketing` field)
    - ➕ `marketing_opt_in_level` (coalescing of `email_marketing_consent_opt_in_level` and deprecated `marketing_opt_in_level` field)
    - ➕ `marketing_consent_updated_at` (coalescing of `email_marketing_consent_consent_updated_at` and deprecated `accepts_marketing_updated_at` field)
    - ➖ `accepts_marketing`/`has_accepted_marketing`
    - ➖ `accepts_marketing_updated_at`
    - ➖ `marketing_opt_in_level`
  - `stg_shopify__order_line_refund`:
    - ➕ `subtotal_set`
    - ➕ `total_tax_set`
  - `stg_shopify__order_line`:
    - ➕ `pre_tax_price_set`
    - ➕ `price_set`
    - ➕ `tax_code`
    - ➕ `total_discount_set`
    - ➕ `variant_title`
    - ➕ `variant_inventory_management`
    - ➕ `properties`
    - ( ) `is_requiring_shipping` is renamed to `is_shipping_required`
  - `stg_shopify__product`:
    - ➕ `status`
  - `stg_shopify__product_variant`
    - ➖ `old_inventory_quantity` -> coalesced with `inventory_quantity`
    - ➕ `inventory_quantity` -> coalesced with `old_inventory_quantity`
- The following source tables have been added to the package with respective staging models ([PR #39](https://github.com/fivetran/dbt_shopify_source/pull/39)):
  - `abandoned_checkout`
  - `collection_product`
  - `collection`
  - `customer_tag`
  - `discount_code` -> if the table does not exist in your schema, the package will create an empty staging model and reference that ([PR #47](https://github.com/fivetran/dbt_shopify_source/pull/47/files), see [DECISIONLOG](https://github.com/fivetran/dbt_shopify/blob/main/DECISIONLOG.md))
  - `fulfillment`
  - `inventory_item`
  - `inventory_level`
  - `location`
  - `metafield` ([#PR 49](https://github.com/fivetran/dbt_shopify_source/pull/49) as well)
  - `order_note_attribute`
  - `order_shipping_line`
  - `order_shipping_tax_line`
  - `order_tag`
  - `order_url_tag`
  - `price_rule`
  - `product_image`
  - `product_tag`
  - `shop`
  - `tender_transaction`
  - `abandoned_checkout_discount_code`
  - `order_discount_code`
  - `tax_line`
  - `abandoned_checkout_shipping_line` ([(PR #47)](https://github.com/fivetran/dbt_shopify_source/pull/47) as well)
  - `fulfillment_event` -> This is NOT included by default. To include fulfillment events (used in the `shopify__daily_shop` model), set the `shopify_using_fulfillment_event` variable to `true` ([PR #48](https://github.com/fivetran/dbt_shopify_source/pull/48))

# dbt_shopify_source v0.7.0
## 🚨 Breaking Changes 🚨:
[PR #36](https://github.com/fivetran/dbt_shopify_source/pull/36) includes the following breaking changes:
- Dispatch update for dbt-utils to dbt-core cross-db macros migration. Specifically `{{ dbt_utils.<macro> }}` have been updated to `{{ dbt.<macro> }}` for the below macros:
    - `any_value`
    - `bool_or`
    - `cast_bool_to_text`
    - `concat`
    - `date_trunc`
    - `dateadd`
    - `datediff`
    - `escape_single_quotes`
    - `except`
    - `hash`
    - `intersect`
    - `last_day`
    - `length`
    - `listagg`
    - `position`
    - `replace`
    - `right`
    - `safe_cast`
    - `split_part`
    - `string_literal`
    - `type_bigint`
    - `type_float`
    - `type_int`
    - `type_numeric`
    - `type_string`
    - `type_timestamp`
    - `array_append`
    - `array_concat`
    - `array_construct`
- For `current_timestamp` and `current_timestamp_in_utc` macros, the dispatch AND the macro names have been updated to the below, respectively:
    - `dbt.current_timestamp_backcompat`
    - `dbt.current_timestamp_in_utc_backcompat`
- Dependencies on `fivetran/fivetran_utils` have been upgraded, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

# dbt_shopify_source v0.6.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_fivetran_utils`. The latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

- The `union_schemas` and `union_databases` variables have been replaced with `shopify_union_schemas` and `shopify_union_databases` respectively. This allows for multiple packages with the union ability to be used and not locked to a single variable that is used across packages.

# dbt_shopify_source v0.5.2
## Under the Hood
- Rearranged the ordering of the columns within the `get_order_columns` macro. This ensure the output of the models within the downstream [Shopify Holistic Reporting](https://github.com/fivetran/dbt_shopify_holistic_reporting) package are easier to understand and interpret. ([#29](https://github.com/fivetran/dbt_shopify_source/pull/29))

# dbt_shopify_source v0.1.0 -> v0.5.1
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
