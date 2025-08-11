# dbt_greenhouse_source v0.6.0
## 🎉 Feature Update 🎉
- Databricks and PostgreSQL compatibility! ([#25](https://github.com/fivetran/dbt_greenhouse_source/pull/25))

## 🚘 Under the Hood 🚘
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. ([#23](https://github.com/fivetran/dbt_greenhouse_source/pull/23))
- Updated the pull request [templates](/.github). ([#23](https://github.com/fivetran/dbt_greenhouse_source/pull/23))

# dbt_greenhouse_source v0.5.0
[PR #20](https://github.com/fivetran/dbt_greenhouse_source/pull/20) includes the following breaking changes:
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
- Dependencies on `fivetran/fivetran_utils` have been upgraded, previously `[">=0.3.0", "<0.4.0"]` now `[">=0.4.0", "<0.5.0"]`.

## 🎉 Documentation and Feature Updates 🎉:
- Updated README documentation for easier navigation and dbt package setup.
- Included the `greenhouse_[source_table_name]_identifier` variables for easier flexibility of the package models to refer to differently named sources tables.

# dbt_greenhouse_source v0.4.1
## Under the Hood
- Leveraged the `{{ dbt_utils.type_timestamp() }}` macro within the staging models for all timestamp fields. 
  - This is needed as certain Redshift warehouses sync these fields as `timestamptz` by default which causes compilation errors in downstream models. This macro safely removes timezone values from the UTC timestamps and ensures success in downstream transformations.
# dbt_greenhouse_source v0.4.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_fivetran_utils`. The latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_greenhouse_source v0.3.1

## Bug Fixes
- Addition of the `meta` config within the relevant `src_greenhouse.yml` tables that are able to be disabled by the user. These configs allow the source freshness tests to skip over the disabled models. ([#15](https://github.com/fivetran/dbt_greenhouse_source/pull/15))

# dbt_greenhouse_source v0.1.0 -> v0.3.0
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
