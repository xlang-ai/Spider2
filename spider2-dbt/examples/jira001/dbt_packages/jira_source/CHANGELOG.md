# dbt_jira_source v0.7.0
[PR #39](https://github.com/fivetran/dbt_jira_source/pull/39) introduces the following changes: 
## 🚨 Breaking Changes 🚨
- To reduce storage, updated default materialization of staging models to views. 
>  ⚠️ Running a `--full-refresh` will be required if you have previously run these staging models as tables and get the following error: 
> ```
> Trying to create view <model path> but it currently exists as a table. Either drop <model path> manually, or run dbt with `--full-refresh` and dbt will drop it for you.
> ```

## Under the Hood:
- Added integration testing pipeline for Databricks SQL Warehouse.
- Included auto-releaser GitHub Actions workflow to automate future releases.
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the maintainer pull request [template](https://github.com/fivetran/dbt_jira_source/tree/main/.github/PULL_REQUEST_TEMPLATE).

# dbt_jira_source v0.6.1
## 🎉 Feature Updates 🎉
- Databricks compatibility 🧱 ([#35](https://github.com/fivetran/dbt_jira_source/pull/35))

# dbt_jira_source v0.6.0

## 🚨 Breaking Changes 🚨:
[PR #33](https://github.com/fivetran/dbt_jira_source/pull/33) includes the following breaking changes:
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

# dbt_jira_source v0.5.0
## 🚨 Breaking Changes 🚨
- The default schema for the source tables are now built within a schema titled (`<target_schema>` + `_jira_source`) in your destination. The previous default schema was (`<target_schema>` + `_stg_jira`). This may be overwritten if desired.
## 🎉 Documentation and Feature Updates
- Updated README documentation updates for easier navigation and setup of the dbt package
- Added `jira_[source_table_name]_identifier` variables to allow for easier flexibility of the package to refer to source tables with different names.
- Source config has been added to the `sprint`, `component`, `priority`, and `version` sources. This ensures the source freshness will not be run if they are disabled within the package.
# dbt_jira_source v0.4.2
## Features
- Added the `parent_id` field in the `stg_jira__field_option` model. This field is used when defining custom fields as parent and child custom fields can be created to define a variety of main categories and subcategories. ([#32](https://github.com/fivetran/dbt_jira_source/pull/32))

## Contributors
- [@sergiisolaa](https://github.com/sergiisolaa) ([#32](https://github.com/fivetran/dbt_jira_source/pull/32))

# dbt_jira_source v0.4.1
## Features
- Makes Priority data optional. If `jira_using_priorities: false` in `dbt_project.yml`, then `stg_jira__priority_tmp` and `stg_jira__priority` won't build. ([#30](https://github.com/fivetran/dbt_jira_source/pull/30))

## Contributors
- @everettttt ([#30](https://github.com/fivetran/dbt_jira_source/pull/30))
# dbt_jira_source v0.4.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_fivetran_utils`. The latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.
 
 
# dbt_jira_source v0.3.2
## Fixes
- Adjusted the `stg_jira__issue` and `stg_jira__issue_field_history` timestamp fields for `redshift` warehouses to explicitly cast the data type as `timestamp without time zone`. This ensures downstream `datediff` and `dateadd` functions to not result in an error if the timestamps are synced as `timestamp_tz`. ([#24](https://github.com/fivetran/dbt_jira_source/pull/24))

# dbt_jira_source v0.1.0 -> v0.3.1
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
