# dbt_google_ads_source v0.11.0

[PR #59](https://github.com/fivetran/dbt_google_ads_source/pull/59) includes the following updates:

## Feature Updates: Conversion Support!
- We have added the following source fields to each `stg_google_ads__<entity>_stats` model:
  - `conversions`: The number of conversions you've received, across your conversion actions. Conversions are measured with conversion tracking and may include [modeled](https://support.google.com/google-ads/answer/10081327?sjid=12862894247631803415-NC) conversions in cases where you are not able to observe all conversions that took place. You can use this column to see how often your ads led customers to actions that you’ve defined as valuable for your business.
  - `conversions_value`: The sum of monetary values for your `conversions`. You have to enter a value in the Google Ads UI for your conversion actions to make this metric useful.
  - `view_through_conversions`: For video campaigns, view-through conversions tell you when an _impression_ of your video ad leads to a conversion on your site. The last impression of a video ad will get credit for the view-through conversion. An impression is different than a “view” of a video ad. A “view” is counted when someone watches 30 seconds (or the whole ad if it’s shorter than 30 seconds) or clicks on a part of the ad. A “view” that leads to a conversion is counted in the `conversions` column.
- In the event that you were already passing the above fields in via our [passthrough columns](https://github.com/fivetran/dbt_google_ads_source?tab=readme-ov-file#passing-through-additional-metrics), the package will dynamically avoid "duplicate column" errors.
> The above new field additions are 🚨 **breaking changes** 🚨 for users who were not already bringing in conversion fields via passthrough columns.

## Under the Hood
- Updated the package maintainer PR template.
- Created `google_ads_fill_pass_through_columns` and `google_ads_add_pass_through_columns` macros to ensure that the new conversion fields are backwards compatible with users who have already included them via passthrough fields.

## Contributors
- [Seer Interactive](https://www.seerinteractive.com/?utm_campaign=Fivetran%20%7C%20Models&utm_source=Fivetran&utm_medium=Fivetran%20Documentation)
- [@fivetran-poonamagate](https://github.com/fivetran-poonamagate)

# dbt_google_ads_source v0.10.1

[PR #54](https://github.com/fivetran/dbt_google_ads_source/pull/54) includes the following updates: 
## Bug Fixes 
- This package now leverages the new `google_ads_extract_url_parameter()` macro for use in parsing out url parameters. This was added to create special logic for Databricks instances not supported by `dbt_utils.get_url_parameter()`.
  - This macro will be replaced with the `fivetran_utils.extract_url_parameter()` macro in the next breaking change of this package.

## Under the Hood 
- Included auto-releaser GitHub Actions workflow to automate future releases.

# dbt_google_ads_source v0.10.0

[PR #43](https://github.com/fivetran/dbt_google_ads_source/pull/43) includes the following updates:
## Feature update 🎉
- Unioning capability! This adds the ability to union source data from multiple google_ads connectors. Refer to the [Union Multiple Connectors README section](https://github.com/fivetran/dbt_google_ads_source/blob/main/README.md#union-multiple-connectors) for more details.

## Under the Hood 🚘
- Updated tmp models to union source data using the `fivetran_utils.union_data` macro. 
- To distinguish which source each field comes from, added `source_relation` column in each staging model and applied the `fivetran_utils.source_relation` macro. 
- Updated tests to account for the new `source_relation` column.

[PR #47](https://github.com/fivetran/dbt_google_ads_source/pull/47) includes the following update:
## Dependency Updates
- Removes the dependency on [dbt-expectations](https://github.com/calogica/dbt-expectations/releases). Specifically we removed the `dbt_expectations.expect_column_values_to_not_match_regex_list` test.

# dbt_google_ads_source v0.9.5
## Rollback
[PR #46](https://github.com/fivetran/dbt_google_ads_source/pull/46) rolls back [PR #45](https://github.com/fivetran/dbt_google_ads_source/pull/45) 

- This was causing conflicting dbt-expectation versions because of the version required in other packages.


# dbt_google_ads_source v0.9.4

[PR #45](https://github.com/fivetran/dbt_google_ads_source/pull/45) includes the following updates:
## Under the Hood:
- Updates the [dbt-expectations](https://github.com/calogica/dbt-expectations/releases) dependency to the latest version.
- Updates the [DECISIONLOG](DECISIONLOG.md) to clarify why there exist differences among aggregations across different grains.

# dbt_google_ads_source v0.9.3

This release addresses a bug that was introduced via a grain change in the Google Ads connector `*_history` tables. This bug introduced duplicates and uniqueness test failures in staging `*_history` models ([PR #41](https://github.com/fivetran/dbt_google_ads_source/pull/41)).
## 🐛 Bug fix
- Added the new `_fivetran_active` field to the `get_<table>_history_columns()` macros. This will create a `null` version of the column if `_fivetran_active` is not found in your source tables yet.
- Added a `where coalesce(_fivetran_active, true)` filter to the final CTEs of the staging `*_history` models.

# dbt_google_ads_source v0.9.2
## 🐛 Bug fix
- Updated configuration to allow the source database to be set as `target.database` when using Databricks. ([#38](https://github.com/fivetran/dbt_google_ads_source/pull/38))

## Under the Hood:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. ([#37](https://github.com/fivetran/dbt_google_ads_source/pull/37))
- Updated the pull request [templates](/.github). ([#37](https://github.com/fivetran/dbt_google_ads_source/pull/37))

# dbt_google_ads_source v0.9.1
## Under the Hood Updates
- The dbt-expectations [regex_inst macro received an update](https://github.com/calogica/dbt-expectations/pull/247) that included a new `flags` argument. This argument is not included in the replica macro located within this package. As such, the update needs to be reflected in order to allow the downstream references of the macro to succeed. ([#35](https://github.com/fivetran/dbt_google_ads_source/pull/35))
# dbt_google_ads_source v0.9.0

## 🚨 Breaking Changes 🚨:
[PR #31](https://github.com/fivetran/dbt_google_ads_source/pull/31) includes the following breaking changes:
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
- `packages.yml` has been updated to reflect the most up to date version of dbt-expectations `[">=0.8.0", "<0.9.0"]`.
- The `regexp_instr` macro has been added to the macros folder as a shim for spark adapters. Additional details for how to disaptch the macro have been added to the README Databricks compatibility section.

# dbt_google_ads_source v0.8.1

## Updates
- Added `'databricks'` in `src_google_ads.yml` for database configs in order to be compatible for an earlier release of the dbt-databricks adapter. [#32](https://github.com/fivetran/dbt_google_ads_source/pull/32)
- Updated `README.md` to reflect `dbt-labs/spark_utils` in dependency matrix. [#32](https://github.com/fivetran/dbt_google_ads_source/pull/32)

# dbt_google_ads_source v0.8.0
## 🚨 Breaking Changes 🚨
- The `adwords` api version of the package has been fully removed. As the Fivetran Google Ads connector now requires the Google Ads API, this functionality is no longer used. ([#29](https://github.com/fivetran/dbt_google_ads_source/pull/29))
- The declaration of passthrough variables within your root `dbt_project.yml` has changed. To allow for more flexibility and better tracking of passthrough columns, you will now want to define passthrough metrics in the following format: ([#29](https://github.com/fivetran/dbt_google_ads_source/pull/29))
> This applies to all passthrough metrics within the `dbt_google_ads_source` package and not just the `google_ads__ad_stats_passthrough_metrics` example.
```yml
vars:
  google_ads__ad_stats_passthrough_metrics:
    - name: "my_field_to_include" # Required: Name of the field within the source.
      alias: "field_alias" # Optional: If you wish to alias the field within the staging model.
```

## 🎉 Feature Enhancements 🎉
PR [#29](https://github.com/fivetran/dbt_google_ads_source/pull/29) includes the following changes:

- Addition of the following staging models which pull from the source counterparts. The inclusion of the additional `_stats` source tables is to generate a more accurate representation of the Google Ads data. For example, not all Ad types are included within the `ad_stats` table. Therefore, the addition of the further grain reports will allow for more flexibility and accurate Google Ad reporting. 
  - `stg_google_ads__account_stats`
  - `stg_google_ads__ad_group_criterion_history`
  - `stg_google_ads__ad_group_stats`
  - `stg_google_ads__campaign_stats`
  - `stg_google_ads__keyword_stats`

- Inclusion of additional passthrough metrics: 
  - `google_ads__ad_group_stats_passthrough_metrics`
  - `google_ads__campaign_stats_passthrough_metrics`
  - `google_ads__keyword_stats_passthrough_metrics`
  - `google_ads__account_stats_passthrough_metrics`

- README updates for easier navigation and use of the package. 
- Addition of identifier variables for each of the source tables to allow for further flexibility in source table direction within the dbt project.
- Included grain uniqueness tests for each staging table. 


## Contributors
- [@bnealdefero](https://github.com/bnealdefero) ([#20](https://github.com/fivetran/dbt_google_ads/pull/20))

# dbt_google_ads_source v0.7.0
## 🚨 Breaking Changes 🚨
- The `api_source` variable is now defaulted to `google_ads` as opposed to `adwords`. The Adwords API has since been deprecated by Google and is now no longer the standard API for the Google Ads connector. Please ensure you are using a Google Ads API version of the Fivetran connector before upgrading this package. ([#28](https://github.com/fivetran/dbt_google_ads_source/pull/28))
  - Please note, the `adwords` version of this package will be fully removed from the package in August of 2022. This means, models under `models/adwords_connector` will be removed in favor of `models/google_ads_connector` models.
# dbt_google_ads_source v0.6.0
## 🚨 Breaking Changes 🚨
- The `account` source table has been renamed to be `account_history`. This has been reflected in this release. ([#25](https://github.com/fivetran/dbt_google_ads_source/pull/25))
- The `ad_final_url_history` model has been removed from the connector. The url fields are now references within the `final_urls` field within the `ad_history` table. ([#25](https://github.com/fivetran/dbt_google_ads_source/pull/25))
  - Please be aware that the logic in the `stg_google_ads__ad_history` model for the Google Ads API will only pull through the first url in the `final_urls` list. This column should contain only one url. However, in the even that two are include a test will warn you that the other urls have been removed from the final model.

# dbt_google_ads_source v0.5.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_fivetran_utils`. The latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.


# dbt_google_ads_source v0.4.1

## Bug Fixes
- Renaming of the folder names within the `dbt_project.yml` to match the current spelling of the `/models/` folder names. This allows for the materialization of the `tmp` models to accurately be materialized as views. ([#19](https://github.com/fivetran/dbt_google_ads_source/pull/19))

## Contributors
- [NoToWarAlways](https://github.com/NoToWarAlways) ([#19](https://github.com/fivetran/dbt_google_ads_source/pull/19))

# dbt_google_ads_source v0.1.0 -> v0.4.0
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!