# dbt_pendo_source v0.5.0
PR [#21](https://github.com/fivetran/dbt_pendo_source/pull/21) includes the following updates:
## 🚨 Breaking Changes 🚨:
- Updated the following models to include the new `_fivetran_id` field, which was recently added per the Fivetran Pendo Connector's [March 2023 release notes](https://fivetran.com/docs/applications/pendo/changelog#march2023):
	  - `stg_pendo__guide_event`
	  - `stg_pendo__poll_event`
	  - `stg_pendo__event`
- `_fivetran_id` has also been added to the hashing formula used in the following fields:
  - `event_key` in `stg_pendo__guide_event`
  - `guide_event_key` in `stg_pendo__poll_event`
  - `poll_event_key` in `stg_pendo__event`
- These breaking changes persist to the transform package. (See the [Transform CHANGELOG](https://github.com/fivetran/dbt_pendo_source/blob/main/CHANGELOG.md) for more details.)

## Features
- Updated documentation for new `_fivetran_id` field.

# dbt_pendo_source v0.4.0

## 🚨 Breaking Changes 🚨:
## 🔧 Bug Fixes
- Updated models `stg_pendo__feature_event` and `stg_pendo__page_event` to include `_fivetran_id`, which was recently added per the Fivetran Pendo Connector's [December 2022 release notes](https://fivetran.com/docs/applications/pendo/changelog#december2022). ([#19](https://github.com/fivetran/dbt_pendo_source/pull/19))
- `_fivetran_id` has also been added to the hashing formula used in the following fields:
  - `feature_event_key` in `stg_pendo__feature_event`
  - `page_event_key` in `stg_page__event`

## ✨ Features
- Update documentation for `_fivetran_id`. ([#19](https://github.com/fivetran/dbt_pendo_source/pull/19))
- Revised source yml and readme instructions for setting up the `GROUP` table with Snowflake. ([#19](https://github.com/fivetran/dbt_pendo_source/pull/19))

# dbt_pendo_source v0.3.1
## Bug Fixes
- Updated readme for workaround if the pendo_<default_source_table_name>_identifer is having trouble with Snowflake reserved words. ([#17](https://github.com/fivetran/dbt_pendo_source/pull/17))
## Under the Hood
- Small adjustments to whitespace control in `src_pendo.yml`. ([#17](https://github.com/fivetran/dbt_pendo_source/pull/17))
## Contributors
- @RichardThRivera ([#16](https://github.com/fivetran/dbt_pendo_source/pull/16))

# dbt_pendo_source v0.3.0
[PR #13](https://github.com/fivetran/dbt_pendo_source/pull/13) includes the following breaking changes:
## 🚨 Breaking Changes 🚨:
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
- Dependencies on `fivetran/fivetran_utils` have been upgraded, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.
## 🎉 Documentation and Feature Updates 🎉:
- Updated README documentation for easier navigation and dbt package setup.
- Included the `pendo_[source_table_name]_identifier` variables for easier flexibility of the package models to refer to differently named sources tables.

# dbt_pendo_source v0.2.1

## Under the Hood
- The `valid_through` field within both the `stg_pendo__feature_history` and `stg_pendo__page_history` models have been updated to leverage the `dbt_utils.timestamp()` macro to be cast as timestamps. ([#10](https://github.com/fivetran/dbt_pendo_source/pull/10))

## Contributors
- [everettt](https://github.com/everettttt?tab=overview) ([#10](https://github.com/fivetran/dbt_pendo_source/pull/10))

# dbt_pendo_source v0.2.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_fivetran_utils`. The latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_pendo_source v0.1.1

## 🚨 Breaking Changes
- n/a

## Bug Fixes
- **For Snowflake warehouses:** Addressed issue [#6](https://github.com/fivetran/dbt_pendo/issues/6), in which users were seeing reserved keyword-related errors when the package selected from the source `GROUP` table. The package now incorporates appropriate quoting and casing for this table in Snowflake destinations. Thanks to both @leinemann and @payzer-mike for contributing! 

## Features
- Added this changelog to capture iterations of the package!

## Under the Hood
- n/a
