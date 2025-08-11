# dbt_google_play v0.4.0
[PR #14](https://github.com/fivetran/dbt_google_play/pull/14) includes the following updates:

## 🚨 Breaking Changes 🚨
- Updated the source identifier format for consistency with other packages and for compatibility with the `fivetran_utils.union_data` macro. The identifier variables now are:

previous | current
--------|---------
`stats_installs_app_version_identifier` | `google_play_stats_installs_app_version_identifier`
`stats_crashes_app_version_identifier` | `google_play_stats_crashes_app_version_identifier`
`stats_ratings_app_version_identifier` | `google_play_stats_ratings_app_version_identifier`
`stats_installs_device_identifier` | `google_play_stats_installs_device_identifier`
`stats_ratings_device_identifier` | `google_play_stats_ratings_device_identifier`
`stats_installs_os_version_identifier` | `google_play_stats_installs_os_version_identifier`
`stats_ratings_os_version_identifier` | `google_play_stats_ratings_os_version_identifier`
`stats_crashes_os_version_identifier` | `google_play_stats_crashes_os_version_identifier`
`stats_installs_country_identifier` | `google_play_stats_installs_country_identifier`
`stats_ratings_country_identifier` | `google_play_stats_ratings_country_identifier`
`stats_store_performance_country_identifier` | `google_play_stats_store_performance_country_identifier`
`stats_store_performance_traffic_source_identifier` | `google_play_stats_store_performance_traffic_source_identifier`
`stats_installs_overview_identifier` | `google_play_stats_installs_overview_identifier`
`stats_crashes_overview_identifier` | `google_play_stats_crashes_overview_identifier`
`stats_ratings_overview_identifier` | `google_play_stats_ratings_overview_identifier`
`earnings_identifier` | `google_play_earnings_identifier`
`financial_stats_subscriptions_country_identifier` | `google_play_financial_stats_subscriptions_country_identifier`

- If you are using the previous identifier, be sure to update to the current version!

## Feature update 🎉
- Unioning capability! This adds the ability to union source data from multiple google_play connectors. Refer to the [README](https://github.com/fivetran/dbt_google_play/blob/main/README.md#union-multiple-connectors) for more details.
- Added a `source_relation` column in each staging model for tracking the source of each record.
  - The `source_relation` column is also persisted from the staging models to the end models.

## Under the hood 🚘
- Added the `source_relation` column to necessary joins. 
- In the source package:
  - Updated tmp models to union source data using the `fivetran_utils.union_data` macro. 
  - Applied the `fivetran_utils.source_relation` macro in each staging model to determine the `source_relation`.
  - Updated tests to account for the new `source_relation` column.
- Included auto-releaser GitHub Actions workflow to automate future releases.

# dbt_google_play v0.3.0

## 🚨 Breaking Changes 🚨:
[PR #10](https://github.com/fivetran/dbt_google_play/pull/10) includes the following changes:
- This version of the transform package points to a [breaking change in the source package](https://github.com/fivetran/dbt_google_play_source/blob/main/CHANGELOG.md) in which the the [country code](https://github.com/fivetran/dbt_google_play_source/blob/main/seeds/google_play__country_codes.csv) mapping table to align with Apple's [format and inclusion list](https://developer.apple.com/help/app-store-connect/reference/app-store-localizations/) of country names. This was change was made in parallel with the [Apple App Store](https://github.com/fivetran/dbt_apple_store/tree/main) dbt package in order to maintain parity for proper aggregating in the combo [App Reporting](https://github.com/fivetran/dbt_app_reporting) package.
  - This is a 🚨**breaking change**🚨 as you will need to re-seed (`dbt seed --full-refresh`) the `google_play__country_codes` file again.

## Under the Hood:
[PR #9](https://github.com/fivetran/dbt_google_play/pull/9) includes the following changes:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request [templates](/.github).

# dbt_google_play v0.2.0

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
- `dbt_utils.surrogate_key` has also been updated to `dbt_utils.generate_surrogate_key`. Since the method for creating surrogate keys differ, we suggest all users do a `full-refresh` for the most accurate data. For more information, please refer to dbt-utils [release notes](https://github.com/dbt-labs/dbt-utils/releases) for this update.
- `packages.yml` has been updated to reflect new default `fivetran/fivetran_utils` version, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

# dbt_google_play v0.1.0

## Initial Release
This is the initial release of this package. 

__What does this dbt package do?__
- Produces modeled tables that leverage Google Play data from [Fivetran's connector](https://fivetran.com/docs/applications/google-play) in the format described [here](https://fivetran.com/docs/applications/google-play#schemainformation) and builds off the output of our [Google Play source package](https://github.com/fivetran/dbt_google_play_source).
- The above mentioned models enable you to better understand your Google Play app performance metrics at different granularities. It achieves this by:
  - Providing intuitive reporting at the App Version, OS Version, Device Type, Country, Overview, and Product (Subscription + In-App Purchase) levels
  - Aggregates all relevant application metrics into each of the reporting levels above
- Generates a comprehensive data dictionary of your source and modeled Google Play data via the [dbt docs site](fivetran.github.io/dbt_google_play/)