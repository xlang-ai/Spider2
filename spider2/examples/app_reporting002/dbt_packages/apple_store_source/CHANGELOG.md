# dbt_apple_store_source v0.4.0
[PR #14](https://github.com/fivetran/dbt_apple_store_source/pull/14) includes the following updates:

## 🚨 Breaking Changes 🚨
- Updated the source identifier format for consistency with other packages and for compatibility with the `fivetran_utils.union_data` macro. The identifier variables now are:

previous | current
--------|---------
`app_identifier` | `apple_store_app_identifier`
`app_store_platform_version_source_type_report_identifier` | `apple_store_app_store_platform_version_source_type_report_identifier`
`app_store_source_type_device_report_identifier` | `apple_store_app_store_source_type_device_report_identifier`
`app_store_territory_source_type_report_identifier` | `apple_store_app_store_territory_source_type_report_identifier`
`crashes_app_version_device_report_identifier` | `apple_store_crashes_app_version_device_report_identifier`
`crashes_platform_version_device_report_identifier` | `apple_store_crashes_platform_version_device_report_identifier`
`downloads_platform_version_source_type_report_identifier` | `apple_store_downloads_platform_version_source_type_report_identifier`
`downloads_source_type_device_report_identifier` | `apple_store_downloads_source_type_device_report_identifier`
`downloads_territory_source_type_report_identifier` | `apple_store_downloads_territory_source_type_report_identifier`
`sales_account_identifier` | `apple_store_sales_account_identifier`
`sales_subscription_event_summary_identifier` | `apple_store_sales_subscription_event_summary_identifier`
`sales_subscription_summary_identifier` | `apple_store_sales_subscription_summary_identifier`
`usage_app_version_source_type_report_identifier` | `apple_store_usage_app_version_source_type_report_identifier`
`usage_platform_version_source_type_report_identifier` | `apple_store_usage_platform_version_source_type_report_identifier`
`usage_source_type_device_report_identifier` | `apple_store_usage_source_type_device_report_identifier`
`usage_territory_source_type_report_identifier` | `apple_store_usage_territory_source_type_report_identifier`

- If you are using the previous identifier, be sure to update to the current version!

## Feature update 🎉
- Unioning capability! This adds the ability to union source data from multiple apple_store connectors. Refer to the [README](https://github.com/fivetran/dbt_apple_store_source/blob/main/README.md#union-multiple-connectors) for more details.
- Added a `source_relation` column in each staging model for tracking the source of each record.
- Updated tests to account for the new `source_relation` column.
- Added casting to staging columns that are used in any downstream COALESCEs, UNIONs, or JOINs to prevent datatype conflicts.
  - Metric fields, such as `crashes`, `impressions`, `page_views`, etc., are now cast as the datatype determined by the `dbt.type_bigint()` macro for your warehouse. 

## Under the hood 🚘
- Updated tmp models to union source data using the `fivetran_utils.union_data` macro. 
- Applied the `fivetran_utils.source_relation` macro in each staging model to determine the `source_relation`.
- Updated `src_apple_store.yml` to use the current method to enable/disable sources.
- Included auto-releaser GitHub Actions workflow to automate future releases. 

# dbt_apple_store_source v0.3.1

## Bug Fix
[PR #11](https://github.com/fivetran/dbt_apple_store_source/pull/11) includes the following update:
- Shortened the field description for `source_type`. This was causing an error if the persist docs config was enabled because the description size exceeded warehouse constraints.

# dbt_apple_store_source v0.3.0

## Bug Fixes
[PR #10](https://github.com/fivetran/dbt_apple_store_source/pull/10) includes the following changes:
- Updated the [country code](https://github.com/fivetran/dbt_apple_store_source/blob/main/seeds/apple_store_country_codes.csv) mapping table to align with Apple's [format and inclusion list](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) of country names.
  - This is a 🚨**breaking change**🚨 as you will need to re-seed (`dbt seed --full-refresh`) the `apple_store_country_codes` file again.

## Under the Hood
[PR #9](https://github.com/fivetran/dbt_apple_store_source/pull/9) includes the following changes:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request [templates](/.github).

# dbt_apple_store_source v0.2.1

## Bug Fixes
[PR #7](https://github.com/fivetran/dbt_apple_store_source/pull/7) includes the following breaking changes:
- Column `date_day` of `stg_apple_store__sales_subscription_events` model is now casted to `date` type. This change might affect downstream models.

## Contributors
- [@lch88](https://github.com/lch88) ([#7](https://github.com/fivetran/dbt_apple_store_source/pull/7))

# dbt_apple_store_source v0.2.0

## 🚨 Breaking Changes 🚨:
[PR #6](https://github.com/fivetran/dbt_google_play/pull/6) includes the following breaking changes:
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
- `packages.yml` has been updated to reflect new default `fivetran/fivetran_utils` version, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

# dbt_apple_store_source v0.1.0

## Initial Release
This is the initial release of this package. 

__What does this dbt package do?__
- Cleans, tests, and prepares your GitHub data from [Fivetran's connector](https://fivetran.com/docs/applications/apple-app-store) for analysis.
- Generates a comprehensive data dictionary of your Apple Store data via the [dbt docs site](https://fivetran.github.io/dbt_apple_store_source/)
- Materializes staging tables which leverage data in the format described by [this ERD](https://docs.google.com/presentation/d/1zeV9F1yakOQbgx-L0xQ7h8I3KRuJL_tKc7srX_ctaYw/edit?usp=sharing) and is intended to work simultaneously with our [Apple Store modeling package](https://github.com/fivetran/dbt_apple_store)
- Refer to our [Docs site](https://fivetran.github.io/dbt_apple_store_source/#!/overview/apple_store_source/models/?g_v=1) for more details about these materialized models. 

__References__
- [lukes/ISO-3166-Countries-with-Regional-Codes](https://github.com/lukes/ISO-3166-Countries-with-Regional-Codes) for the foundation of our `country_codes` mapping table

For more information refer to the [README](/README.md).
