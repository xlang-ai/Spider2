# dbt_fivetran_utils v0.4.10

## Bug Fix
- This release addresses a bug caused by the introduction of the `date_spine()` macro. Users who employed the Fivetran Utils [dispatch recommendations](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest?tab=readme-ov-file#step-2-using-the-macros) reported a recursion error that was resolved by ensuring that this macro had a different name from `dbt_utils.date_spine()`.
  - Thus, the `date_spine()` macro has been renamed to `fivetran_date_spine()` ([PR #136](https://github.com/fivetran/dbt_fivetran_utils/pull/136)).


## Contributors
- [@nydnarb](https://github.com/nydnarb): Huge shoutout to Brandyn Lee for helping us troubleshoot and resolve this quickly.

# dbt_fivetran_utils v0.4.9

## Feature Update
- Added macro `extract_url_parameter` to create special logic for Databricks instances not supported by `dbt_utils.get_url_parameter()`. The macro uses `dbt_utils.get_url_parameter()` for default, non-Databricks targets. See [README](https://github.com/fivetran/dbt_fivetran_utils/blob/releases/v0.4.latest/README.md#extract_url_parameter-source) for more details ([PR #130](https://github.com/fivetran/dbt_fivetran_utils/pull/130)).
- Made the `try_cast()` [macro](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#try_cast-source) compatible with SQL Server ([PR #131](https://github.com/fivetran/dbt_fivetran_utils/pull/131)).
- Made the  `json_parse()` [macro](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#date_spine-source) compatible with SQL Server ([PR #131](https://github.com/fivetran/dbt_fivetran_utils/pull/131)).
- Added a `date_spine()` [macro](https://github.com/fivetran/dbt_fivetran_utils/tree/releases/v0.4.latest#json_parse-source) ([PR #131](https://github.com/fivetran/dbt_fivetran_utils/pull/131)).
  - For non-SQL Server databases, this will simply call [`dbt_utils.date_spine()`](https://github.com/dbt-labs/dbt-utils#date_spine-source). 
  - For SQL Server targets, this will manually create a spine, with code heavily leveraged from [`tsql-utils.date_spine()`](https://github.com/dbt-msft/tsql-utils/blob/main/macros/dbt_utils/datetime/date_spine.sql) but [adjusted for recent changes to dbt_utils](https://github.com/dbt-msft/tsql-utils/issues/96).

## Bug Fix
- Corrected the name of the default version of `try_cast()` from safe_cast to try_cast ([PR #131](https://github.com/fivetran/dbt_fivetran_utils/pull/131)).

# dbt_fivetran_utils v0.4.8
[PR #127](https://github.com/fivetran/dbt_fivetran_utils/pull/127) includes the following updates.
## Feature Updates
- Updated the `collect_freshness` macro for compatibility with dbt versions greater than v1.5.0 to prevent erroneous warnings from occurring during freshness tests.

# dbt_fivetran_utils v0.4.7
[PR #118](https://github.com/fivetran/dbt_fivetran_utils/pull/118) includes the following updates.
## Feature Updates
- Update to the `union_data` macro to ensure a source connection is established when just one schema is being used with the macro. ([code link for reference](https://github.com/fivetran/dbt_fivetran_utils/blob/bdece2dd5fcc47ae80f63b777d52a13eecb3416f/macros/union_data.sql#L112-L115)) 
    - The previous build did allow the macro to read data from the correct location; however, it did not leverage the source. Therefore, the models using this macro would result in not having a source connection. This has since been updated in this release and all versions of this macro (whether unioning or not) will attempt to leverage the source function.
- In addition to the above update, a specific code adjustment was provided for the LinkedIn Company Pages and Instagram Business Pages packages as the sources are not named the same as their default schema. This was the core issue that resulted in dbt_fivetran_utils v0.4.5 being rolled back. This has now been addressed and may be expanded in the future for any other packages with mismatching source/default_schema names. ([code link for reference](https://github.com/fivetran/dbt_fivetran_utils/blob/bdece2dd5fcc47ae80f63b777d52a13eecb3416f/macros/union_data.sql#L95-L108)) 
    - For additional context, this is the approach taken as renaming the sources could result in incompatible versions of base package and fivetran_utils. Particularly, this could result in package users having a different experience based on the version of their base package. Which is not the behavior we would prefer for this new feature.

## Under the Hood
- The `union_data` macro has been adjusted to leverage the identifier variable and the true relation when running on a single schema. This ensures a more accurate use of the macro and the ability for the macro to work as expected within the Fivetran integration test pipeline.
- The `.buildkite` folder has been overhauled to ensure full integration test coverage over **all** Fivetran dbt packages that reference the dbt_fivetran_utils package. The new pipeline updates will ensure the fivetran_utils release version will succeed and not cause errors on any Fivetran dependent package prior to release.
- Cleaned up a variety of integration test configurations that are no longer needed with the new approach to integration tests for Fivetran Utils.

# dbt_fivetran_utils v0.4.6
## Bug Fixes
- Rolling back an error within the v0.4.5 release that caused a breaking change for the LinkedIn Pages dbt Package

# dbt_fivetran_utils v0.4.5
## Feature Updates
[PR #110](https://github.com/fivetran/dbt_fivetran_utils/pull/110) includes the following feature updates:
- Update to the `union_data` macro to ensure a source connection is established when just one schema is being used with the macro. 
    - The previous build did allow the macro to read data from the correct location; however, it did not leverage the source. Therefore, the models using this macro would result in not having a source connection. This has since been updated in this release and all versions of this macro (whether unioning or not) will attempt to leverage the source function.
# dbt_fivetran_utils v0.4.4

## Feature Updates
[PR #106](https://github.com/fivetran/dbt_fivetran_utils/pull/106) introduces the following two new macros:
- [drop_schemas_automation](https://github.com/fivetran/dbt_fivetran_utils/tree/explore/drop-integration-test-schemas#drop_schemas_automation-source)
- [wrap_in_quotes](https://github.com/fivetran/dbt_fivetran_utils/tree/explore/drop-integration-test-schemas#wrap_in_quotes-source)

# dbt_fivetran_utils v0.4.3

## Feature Updates
- ([PR #100](https://github.com/fivetran/dbt_fivetran_utils/pull/100)) Expanded the `union_data` macro to create an empty table if none of the provided schemas or databases contain a source table. If the source table does not exist anywhere, `union_data` will return a **completely** empty table (ie `limit 0`) with just one string column (`_dbt_source_relation`) and raise a compiler warning message that the respective staging model is empty.
  - The compiler warning can be turned off by the end user by setting the `fivetran__remove_empty_table_warnings` variable to `True`.

## Under the Hood
- Added `dbt compile` tests for popular Fivetran packages in integration testing. ([PR #101](https://github.com/fivetran/dbt_fivetran_utils/pull/101))

# dbt_fivetran_utils v0.4.2
## Bug Fixes
- Fix broken anchor tags in README. ([PR #96](https://github.com/fivetran/dbt_fivetran_utils/pull/96))
- Expand `spark` adapter logic in the `fill_staging_columns` macro to `databricks` adapters. ([PR #98](https://github.com/fivetran/dbt_fivetran_utils/pull/98))
## Contributors
- [@kylemcnair](https://github.com/kylemcnair) ([PR #96](https://github.com/fivetran/dbt_hubspot/pull/96))

# dbt_fivetran_utils v0.4.1

## Bug Fixes
- Updates dispatch from `{{ dbt_utils.<macro> }}` to `{{ dbt.<macro> }}` for additional [cross-db macros](https://docs.google.com/spreadsheets/d/1xF_YwJ4adsnjFkUbUm8-EnEL1r_C-9_OI_pP4m4FlJU/edit#gid=1062533692) missed in the `fivetran_utils.union_relations()` macro. ([PR #91](https://github.com/fivetran/dbt_fivetran_utils/pull/91))


## Updates
- Updates the `pivot_json_extract` macro to include additional formats of fields using a new `name` and `alias` argument to be pivoted out into columns. Specifically, allowing for fields with `.` to be replaced with `_`, for metadata variables to accept dictionaries in addition to strings, and for aliasing of fields. ([PR #92](https://github.com/fivetran/dbt_fivetran_utils/pull/92))
- Updates the `add_pass_through_columns` and `fill_pass_through_columms` macros to be backwards compatible for _lists_ of pass through columns (ie those that do not have attributes like `name`, `alias`, or `transform_sql`) [(PR #93)](https://github.com/fivetran/dbt_fivetran_utils/pull/93).
- `packages.yml` update for `dbt_utils` from `1.0.0-b2` to `[">=1.0.0", "<2.0.0"]`

# dbt_fivetran_utils v0.4.0

## Bug Fixes
[PR #89](https://github.com/fivetran/dbt_fivetran_utils/pull/89) introduces the following change:
- The `union_data` macro has been adjusted to establish a source relation instead of a floating relation, though the default behavior still uses a floating relation. To establish relationships between sources and the models that union them:
  - Define the sources in `.yml` files in your project. Only the names of tables are required.
  - In your `dbt_project.yml` file, set the `has_defined_sources` variable to `true`. This variable has a generic name, so you must scope it to the package/project in which the `union_data` macro is called.

## Updates
[PR #85](https://github.com/fivetran/dbt_fivetran_utils/pull/85) updates are now incorporated into this package as a result of the cross-db macro migration from `dbt-utils` to `dbt-core` ([dbt-core v1.2.0](https://github.com/dbt-labs/dbt-core/releases/tag/v1.2.0)):
- Macro updates dispatch from `{{ dbt_utils.<macro> }}` to `{{ dbt.<macro> }}` for respective [cross-db macros](https://docs.google.com/spreadsheets/d/1xF_YwJ4adsnjFkUbUm8-EnEL1r_C-9_OI_pP4m4FlJU/edit#gid=1062533692):
    - `add_pass_through_columns.sql`
    - `source_relation.sql`
    - `timestamp_add.sql`
    - `timestamp_diff.sql`
- `packages.yml` update for `dbt_utils` from `[">=0.8.0", "<0.9.0"]` to `1.0.0-b2`

# dbt_fivetran_utils v0.3.9
## 🎉 Features 🎉 
- Addition of the `transform` argument to the `persist_pass_through_columns` macro. This argument is optional and will take in a SQL function (most likely an aggregate such as `sum`) you would like to apply to the passthrough columns ([81](https://github.com/fivetran/dbt_fivetran_utils/pull/81)).

# dbt_fivetran_utils v0.3.8
## Bug Fixes
- Adjustment within the `try_cast` macro to fix an error witch ocurred within Snowflake warehouses. ([#79](https://github.com/fivetran/dbt_fivetran_utils/pull/79))

## Under the Hood
- Removes automation macros used only by the Fivetran dbt package team when developing new dbt packages. These macros are not needed within the utility package for access by all Fivetran dbt packages. ([#79](https://github.com/fivetran/dbt_fivetran_utils/pull/79))
    - As a result of the above, these automations were removed and re-located to our Fivetran team's automations repo.

# dbt_fivetran_utils v0.3.7
- Rollback of the v0.3.6 release that introduced a bug for Snowflake users.
# dbt_fivetran_utils v0.3.6
## 🎉 Features 🎉 
- New macro `get_column_names_only` that further automates the staging model creation to prefill column fields in the final select statement. 
- Updated bash script `generate_models` to incorporate this new macro.
# dbt_fivetran_utils v0.3.5
## 🎉 Features 🎉 
- The `try_cast` macro has been added. This macro will try to cast the field to the specified datatype. If it cannot be cast, then a `null` value is provided. Please note, Postgres and Redshift destinations are only compatible with try_cast and the numeric datatype.
# dbt_fivetran_utils v0.3.4
## 🎉 Features 🎉 
Added a new macro called `generate_docs` which returns a `source` command leveraging `generate_docs.sh` to do the following:
- seeds, runs and creates documentation for integration tests models
- moves `catalog.json`, `index.html`, `manifest.json` and `run_results.json` into a `<project_name>/docs` folder

When ran, this feature will remove existing files in the `<project_name>/docs` if any exists.

# dbt_fivetran_utils v0.3.3

## Updates
([#63](https://github.com/fivetran/dbt_fivetran_utils/pull/63/files)) This release of the `dbt_fivetran_utils` package includes the following updates to the README:
- Add a Table of Contents to allow for quicker searches.
- Leverage new Categories to better organize macros.
- Update the `staging_models_automation` macro to reflect usage of the new `generate_columns.sh` and `generate_models.sh` scripts. 
- Update the `generate_models.sh` script to create the models/macros folders if empty or replace any existing content in the models/macros folders.
# dbt_fivetran_utils v0.3.2
## Fixes
- The `collect_freshness` macro was inadvertently causing non-package source freshness tests that were aliased with the `identifier` config to use the current date opposed to the loaded date. Therefore, the macro was adjusted to leverage the table identifier opposed to the name. As the identifier is the name of the table by default, this should resolve the error. ([#56](https://github.com/fivetran/dbt_fivetran_utils/pull/56))
# dbt_fivetran_utils v0.3.1
## Bug Fixes
- Updates `staging_models_automation` macro to refer to dbt_packages instead of dbt_modules re: dbt v1.0.0 updates
- Updates `staging_models_automation` macro to first create `macros/get_<table name>_columns`.sql files before creating `models/tmp` and `models/stg*`
- Incorporates fix for bignumeric data type in `get_columns_for_macro`
- Updates `README` to reflect new `.sh` files added for updated `staging_models_automation` macro

# dbt_fivetran_utils v0.3.0
## 🎉 Features 🎉
- dbt v1.0.0 compatibility release! All future release of fivetran/fivetran_utils compatible with dbt v1.0.0 will be based on the `releases/v0.3.latest`. ([#54](https://github.com/fivetran/dbt_fivetran_utils/pull/54))

## 🚨 Breaking Changes 🚨
- This release updates the dbt-utils `packages.yml` dependency to be within the `">=0.8.0", "<0.9.0"` range. If you have a dbt-utils version outside of this range then you will experience a package dependency error. ([#54](https://github.com/fivetran/dbt_fivetran_utils/pull/54))


# dbt_fivetran_utils v0.2.10
## Bug Fixes
- Added a `dbt_utils.type_string()` cast to the `source_relation` macro. There were accounts of failures occurring within Redshift where the casting was failing in downstream models. This will remedy those issues by casting on field creation if multiple schemas/databases are not provided. ([#53](https://github.com/fivetran/dbt_fivetran_utils/pull/53))

# dbt_fivetran_utils v0.2.9

## Bug Fixes
- Added a specific Snowflake macro designation for the `json_extract_path` macro. ([#50](https://github.com/fivetran/dbt_fivetran_utils/pull/50))
    - This Snowflake version of the macro includes a `try_parse_json` function within the `json_extract_path` function. This allows for the macro to succeed if not all fields are a json object that are being passed through. If a field is not a json object, then a `null` record is generated. 
- Updated the Redshift macro designation for the `json_extract_path` macro. ([#50](https://github.com/fivetran/dbt_fivetran_utils/pull/50))
    - Similar to the above, Redshift cannot parse the field if every record is not a json object. This update converts a non-json field to `null` so the function does not fail.

## Under the Hood
- Included a `union_schema_variable` and a `union_database_variable` which will allow the `source_relation` and `union_data` macros to be used with varying variable names. ([#49](https://github.com/fivetran/dbt_fivetran_utils/pull/49))
    - This allows for dbt projects that are utilizing more than one dbt package with the union source feature to have different variable names and not see duplicate errors.
    - This change needs to be applied at the package level to account for the variable name change. If this is not set, the macros looks for either `union_schemas` or `union_databases` variables.

# dbt_fivetran_utils v0.2.8

## Features
- Added this changelog to capture iterations of the package!
- Added the `add_dbt_source_relation()` macro, which passes the `dbt_source_relation` column created by `union_data()` to `source_relations()` in package staging models. See the README for more details on its appropriate usage.
