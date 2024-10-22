# dbt_intercom_source v0.8.0

[PR #36](https://github.com/fivetran/dbt_intercom_source/pull/36) includes the following updates:
## 🚨 Breaking Changes 🚨
- In [July 2023 the Intercom API upgraded from 2.9 to 2.10](https://fivetran.com/docs/applications/intercom/changelog#july2023) which resulted in the connector schema receiving updates. These updates have downstream impacts on the data models within this package. The following changes are a result of the Intercom API and connector upgrades:
  - The `_fivetran_deleted` column within the `*_history` staging models have been removed as they were deprecated in the connector.

## Feature Updates
- The `_fivetran_active`, `_fivetran_start`, and `_fivetran_end` fields have been added to all `*_history` staging models to address the removal of the `_fivetran_deleted` columns and properly track historical records.

## Test Updates
- Removal of the "author is not null" test within the `stg_intercom__conversation_history` model.
- Updated the source freshness test enablement/disablement to leverage the dbt-core `config: enabled:` architecture.

## Dependency Updates
- Removal of the dbt_expectations dependency.

# dbt_intercom_source v0.7.1
[PR #31](https://github.com/fivetran/dbt_intercom_source/pull/31) includes the following updates:
## 🐛 Bugfix
- Remove erroneous uniqueness test from `company_id` in model `stg_intercom__company_history` since `company_id` could have multiple associated records.

## Contributors
- [@matthew-LL](https://github.com/matthew-LL) ([PR #31](https://github.com/fivetran/dbt_intercom_source/pull/31))

# dbt_intercom_source v0.7.0
## 🎉 Feature Update 🎉
- Databricks compatibility! ([#28](https://github.com/fivetran/dbt_intercom_source/pull/28))

## 🚘 Under the Hood 🚘
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. ([#25](https://github.com/fivetran/dbt_intercom_source/pull/25))
- Updated the pull request [templates](/.github). ([#25](https://github.com/fivetran/dbt_intercom_source/pull/25))

# dbt_intercom_source v0.6.1
## ⭐ Features ⭐
- Passthrough columns variables can now be configured with an alias and a transform. Refer to [Passthrough Columns](https://github.com/fivetran/dbt_intercom_source#passthrough-columns) of the README for more information. ([#22](https://github.com/fivetran/dbt_intercom_source/pull/22))
- Added passthrough custom column capability for models depending on source table `conversation_history`. ([#22](https://github.com/fivetran/dbt_intercom_source/pull/22))
- Addition of the `body` field to the `stg_intercom__conversation_part_history` model. The addition of this field will help users understand the context of the conversation parts. ([#23](https://github.com/fivetran/dbt_intercom_source/pull/23))

## 🚘 Under the hood 🚘
- Updated staging for sources `company_history` and `contact_history` to utilize passthrough column macros from the fivetran/fivetran_utils package, which provides the configuration ability. ([#22](https://github.com/fivetran/dbt_intercom_source/pull/22))

## 🔧 Fixes 🔧
- Removed the `assigned_to_id` null test from `stg_intercom__conversation_part_history`. This test does not apply to instances where a conversation is not assigned, so `assigned_to_id` could accurately be null. ([#22](https://github.com/fivetran/dbt_intercom_source/pull/22))

# dbt_intercom_source v0.6.0

## 🚨 Breaking Changes 🚨:
[PR #19](https://github.com/fivetran/dbt_intercom_source/pull/19) includes the following breaking changes:
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

# dbt_intercom_source v0.5.0
## 🚨 Breaking Changes 🚨
- Added dbt_expectations packages to more easily setup more complex data validation tests.
- Added not null tests for both author and assigned_to fields, conditional on author_type and assigned_to_type not being null.
## Features
- 🎉 Postgres Compatibility 🎉 ([#18](https://github.com/fivetran/dbt_intercom_source/pull/18))
## Under the Hood
We have added the below feature enhancements to this package in PR #18  ([#18](https://github.com/fivetran/dbt_intercom_source/pull/18)):
- Added `{{ dbt_utils.type_timestamp() }}` casting to timestamp fields for safe casting across warehouses. ([#18](https://github.com/fivetran/dbt_intercom_source/pull/18))

# dbt_intercom_source v0.4.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_fivetran_utils`. The latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

## Bug Fixes
- Addition of the `meta` config within the relevant `src_intercom.yml` tables that are able to be disabled by the user. These configs allow the source freshness tests to skip over the disabled models.

## Under the Hood
- Removed unnecessary duplicate `company_id` field definition and test from `stg_intercom.yml`.

# dbt_intercom_source v0.1.0 -> v0.3.0
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
