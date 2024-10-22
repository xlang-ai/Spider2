# dbt_asana_source v0.8.0
## 🎉 Feature Update 🎉
- Databricks compatibility! ([#30](https://github.com/fivetran/dbt_asana_source/pull/30))

## 🚘 Under the Hood 🚘
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. ([#28](https://github.com/fivetran/dbt_asana_source/pull/28))
- Updated the pull request [templates](/.github). ([#28](https://github.com/fivetran/dbt_asana_source/pull/28))

# dbt_asana_source v0.7.0

## 🚨 Breaking Changes 🚨:
[PR #27](https://github.com/fivetran/dbt_asana_source/pull/27) includes the following breaking changes:
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

# dbt_asana_source v0.6.0
🛠 Deprecated columns fix 🛠
## 🚨 Breaking Changes 🚨
- As per our [Release Notes](https://fivetran.com/docs/applications/asana/changelog#june2021) for the Asana connector, this new version of the package removes deprecated columns from the Task table - please refer to the June 2021 and May 2021 release notes. The following columns have been deprecated from the Task table:
  - `assignee_status`
  - `hearted` - the `liked` column has been added to replace hearted
  - `num_hearts` - the `num_likes` column has been added to replace num_hearts
Please be sure to update your queries.

## 🎉 Features 🎉
PR [#24](https://github.com/fivetran/dbt_asana_source/pull/24) introduced the following updates.
- PostgreSQL compatibility 
- Updated README for enhanced user experience
- Add source identifiers to give users more dynamic flexibility

## Contributors
- @fivetran-poonamagate ([#21](https://github.com/fivetran/dbt_asana_source/pull/21)).

# dbt_asana_source v0.5.1
## Under the Hood
- Leveraged the `{{ dbt_utils.type_timestamp() }}` macro within the staging models for all timestamp fields. 
  - This is needed as certain Redshift warehouses sync these fields as `timestamptz` by default which causes compilation errors in downstream models. This macro safely removes timezone values from the UTC timestamps and ensures success in downstream transformations.

## Contributors
- @shreveasaurus ([#18](https://github.com/fivetran/dbt_asana_source/pull/18)).

# dbt_asana_source v0.5.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_fivetran_utils`. The latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_asana_source v0.1.0 -> v0.4.0
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
