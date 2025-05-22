# dbt_apple_store v0.4.0
[PR #22](https://github.com/fivetran/dbt_apple_store/pull/22) includes the following updates:

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
- Unioning capability! This adds the ability to union source data from multiple apple_store connectors. Refer to the [README](https://github.com/fivetran/dbt_apple_store/blob/main/README.md#union-multiple-connectors) for more details.
- Added a `source_relation` column in each staging model for tracking the source of each record.
  - The `source_relation` column is also persisted from the staging models to the end models.

## Under the hood 🚘
- Added the `source_relation` column to necessary joins. 
- In the source package:
  - Updated tmp models to union source data using the `fivetran_utils.union_data` macro. 
  - Applied the `fivetran_utils.source_relation` macro in each staging model to determine the `source_relation`.
  - Updated tests to account for the new `source_relation` column.

# dbt_apple_store v0.3.2

[PR #18](https://github.com/fivetran/dbt_apple_store/pull/18) includes the following updates:
## Bug Fix
- Enhanced the `state` join condition in `apple_store__subscription_report`. The new condition will now check for null values correctly. Previously this was causing wrong metrics for countries that do not specify or require a state.

## Under the Hood
- Included auto-releaser GitHub Actions workflow to automate future releases.
- Updated the maintainer PR template to resemble the most up to date format.

## Contributors
- [@awoehrl](https://github.com/awoehrl) ([PR #18](https://github.com/fivetran/dbt_apple_store/pull/18))

# dbt_apple_store v0.3.1

This package version includes the following updates:
## Bug Fix
- Shortened the field description for `source_type`. This was causing an error if the persist docs config was enabled because the description size exceeded warehouse constraints. This was updated upstream in the dbt_apple_store_source package ([PR #11](https://github.com/fivetran/dbt_apple_store_source/pull/11))

## Under the Hood:
- Added rows to seed data `app_store_territory_source_type` to test for countries with variant spellings in the  `territory` column ([PR #13](https://github.com/fivetran/dbt_apple_store/pull/13))
- Removed/added fields in the yml file ([PR #14](https://github.com/fivetran/dbt_apple_store/pull/14))

# dbt_apple_store v0.3.0

## Bug Fixes
[PR #11](https://github.com/fivetran/dbt_apple_store/pull/11) includes the following changes:
- This version of the transform package points to a [breaking change in the source package](https://github.com/fivetran/dbt_apple_store_source/blob/main/CHANGELOG.md) in which the [country code](https://github.com/fivetran/dbt_apple_store_source/blob/main/seeds/apple_store_country_codes.csv) mapping table was updated to align with Apple's [format and inclusion list](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) of country names.
  - This is a 🚨**breaking change**🚨 as you will need to re-seed (`dbt seed --full-refresh`) the `apple_store_country_codes` file again.

## Under the Hood:
[PR #10](https://github.com/fivetran/dbt_apple_store/pull/10) includes the following changes:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request [templates](/.github).

# dbt_apple_store v0.2.0

## 🚨 Breaking Changes 🚨:
[PR #6](https://github.com/fivetran/dbt_apple_store/pull/6) includes the following breaking changes:
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

# dbt_apple_store v0.1.0

## Initial Release
This is the initial release of this package. 

__What does this dbt package do?__
- Produces modeled tables that leverage Apple App Store data from [Fivetran's connector](https://fivetran.com/docs/applications/apple-app-store) in the format described by [this ERD](https://docs.google.com/presentation/d/1zeV9F1yakOQbgx-L0xQ7h8I3KRuJL_tKc7srX_ctaYw/edit?usp=sharing) and builds off the output of our [Apple App Store source package](https://github.com/fivetran/dbt_apple_store_source).
- The above mentioned models enable you to better understand your Apple App Store metrics at different granularities. It achieves this by:
  - Providing intuitive reporting at the App Version, Platform Version, Device, Source Type, Territory, Subscription and Overview levels
  - Aggregates all relevant application metrics into each of the reporting levels above
- Generates a comprehensive data dictionary of your source and modeled Apple App Store data via the [dbt docs site](https://fivetran.github.io/dbt_apple_store/)

For more information refer to the [README](/README.md).
