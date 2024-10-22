# dbt_hubspot_source v0.15.0
[PR #126](https://github.com/fivetran/dbt_hubspot_source/pull/126) includes the following updates:

## 🚨 Breaking Changes 🚨
- Added field `_fivetran_end` to macro `get_ticket_property_history_columns()` to ensure the column is available for use downstream.
  - While this should not affect most users, this will add a new column `_fivetran_end` to `stg_hubspot__ticket_property_history` if you do not have `_fivetran_end` in your source `TICKET_PROPERTY_HISTORY` table.

## Documentation
- Update documentation to include `_fivetran_end` under model `stg_hubspot__ticket_property_history`.

## Under the hood
- Updated the maintainer PR template to the current format.
- Included auto-releaser GitHub Actions workflow to automate future releases.
- Added integration testing for Databricks SQL Warehouse.

# dbt_hubspot_source v0.14.1
[PR #125](https://github.com/fivetran/dbt_hubspot_source/pull/125) includes the following updates:

## Features
- Adds the `stg_hubspot__merged_deal` model. Downstream, this model is used to remove stale deals and aggregate them to the deal they have been merged into. This is disabled by default as not every user has the `merged_deal` table.
  - To enable this model and filter out merged deals downstream, make sure the following is set to `true` in your dbt_project.yml: `hubspot_sales_enabled`, `hubspot_deal_enabled`, and `hubspot_merged_deal_enabled`. See [Step 4 of the README](https://github.com/fivetran/dbt_hubspot_source#step-4-disable-models-for-non-existent-sources) for more details. 

# dbt_hubspot_source v0.14.0
[PR #122](https://github.com/fivetran/dbt_hubspot_source/pull/122) includes the following updates:

## Features
- Added the following staging models, along with documentation and tests:
  - `stg_hubspot__property`
  - `stg_hubspot__property_option`
  - These tables can be disabled by setting `hubspot_property_enabled: False` in your dbt_project.yml vars. See [Step 4 of the README](https://github.com/fivetran/dbt_hubspot_source#step-4-disable-models-for-non-existent-sources) for more details. 

- When including a passthrough `property_hs_*` column, you now have the option to include the corresponding, human-readable label in the staging models. 
  - The above-mentioned `property` tables are required for this feature. If you do not have them and have to disable them, unfortunately you will not be able to use this feature.
  - See the [Adding property label section](https://github.com/fivetran/dbt_hubspot_source#adding-property-label) of the README for instructions on how to enable this feature! 
  - We recommend being selective with the label columns you add. As you add more label columns, your run time will increase due to the underlying logic requirements.
  - This update applies to models:
    - `stg_hubspot__company`
    - `stg_hubspot__contact`
    - `stg_hubspot__deal`
    - `stg_hubspot__ticket`

## Bug fixes
- Updated macro `remove_duplicate_and_prefix_from_columns` to accommodate incoming custom column names containing characters such as `-` or `$` that are not permitted. The resulting column name will have these characters removed or replaced in its `stg_*` model. 
- Removed extra comma from `stg_hubspot__ticket`, which was causing compilation issues when passing through all columns. 

# dbt_hubspot_source v0.13.0

## 🚨 Breaking Changes 🚨
- The `created_at` and `closed_at` fields in the below mentioned staging models have been renamed to `created_date` and `closed_date` respectively to be consistent with the source data. Additionally, this will ensure there are no duplicate column errors when passing through all `property_*` columns, which could potentially conflict with `property_created_at` or `property_closed_at` ([PR #119](https://github.com/fivetran/dbt_hubspot_source/pull/119)).
  - `stg_hubspot__company`
  - `stg_hubspot__contact`
  - `stg_hubspot__deal`
  - `stg_hubspot__ticket`

## Features
- Addition of the following variables to allow the disabling of the `*_property_history` models if they are not being leveraged. All variables are `true` by default ([PR #119](https://github.com/fivetran/dbt_hubspot_source/pull/119)).
  - `hubspot_company_property_history_enabled`
  - `hubspot_contact_property_history_enabled`
  - `hubspot_deal_property_history_enabled`

## Under the Hood
- All `stg_hubspot__*_tmp` models have been updated to leverage the `dbt_utils.star()` macro. This ensures if the source dimension changes there is no potential for a mismatch in columns error that is commonly seen in Snowflake destinations ([PR #119](https://github.com/fivetran/dbt_hubspot_source/pull/119)).
- Updates to the seed files and seed file configurations for the package integration tests to ensure updates are properly tested ([PR #119](https://github.com/fivetran/dbt_hubspot_source/pull/119)).
- V3 of the Hubspot Service endpoint contains the field `_fivetran_deleted` in the `TICKET` table, whereas V2 has a field called `is_deleted`. Previously, the package only looked at `is_deleted`. Now, it will fold in `_fivetran_deleted` and coalesce it with `is_deleted` to more fully represent `is_ticket_deleted` ([PR #120](https://github.com/fivetran/dbt_hubspot_source/pull/120)).

# dbt_hubspot_source v0.12.0
## 🚨 Breaking Changes 🚨
- The following models now use a custom macro to remove the property_hs_ prefix in staging columns, while also preventing duplicates. If de-prefixed columns match existing ones (e.g., `property_hs_meeting_outcome` vs. `meeting_outcome`), the macro favors the `property_hs_`field, aligning with the latest HubSpot API update. ([PR #115](https://github.com/fivetran/dbt_hubspot_source/pull/115))
  - `stg_hubspot__engagement_call`
  - `stg_hubspot__engagement_company`
  - `stg_hubspot__engagement_contact`
  - `stg_hubspot__engagement_deal`
  - `stg_hubspot__engagement_email`
  - `stg_hubspot__engagement_meeting`
  - `stg_hubspot__engagement_note`
  - `stg_hubspot__engagement_task`
  - `stg_hubspot__ticket`
  - `stg_hubspot__ticket_company`
  - `stg_hubspot__ticket_contact`
  - `stg_hubspot__ticket_deal`
  - `stg_hubspot__ticket_engagement`
  - `stg_hubspot__ticket_property_history`

## Feature Updates
- A new macro `remove_duplicate_and_prefix_from_columns` has been included which expands off the `fivetran_utils.remove_prefix_columns` macro by removing any duplicate columns that result from the prefix removal. ([PR #115](https://github.com/fivetran/dbt_hubspot_source/pull/115) and [PR #114](https://github.com/fivetran/dbt_hubspot_source/pull/114))

## Contributors
- [@greg-finley](https://github.com/greg-finley) ([PR #114](https://github.com/fivetran/dbt_hubspot_source/pull/114))

# dbt_hubspot_source v0.11.0
[PR #112](https://github.com/fivetran/dbt_hubspot_source/pull/112) includes the following updates:
## 🚨 Breaking Changes 🚨
- Following the [May 2023 connector update](https://fivetran.com/docs/applications/hubspot/changelog#may2023) the HubSpot connector now syncs the below parent and child tables from the new v3 API. As a result the dependent fields and field names from the downstream staging models have changed depending on the fields available in your HubSpot data. Now the respective staging models will sync the required fields for the dbt_hubspot downstream transformations and **all** of your `property_hs_*` fields. Please be aware that the `property_hs_*` will be truncated from the field name in the staging and downstream models. The impacted sources (and relevant staging models) are below:
```txt
  - `ENGAGEMENT`
    - `ENGAGEMENT_CALL`
    - `ENGAGEMENT_COMPANY`
    - `ENGAGEMENT_CONTACT`
    - `ENGAGEMENT_DEAL`
    - `ENGAGEMENT_EMAIL`
    - `ENGAGEMENT_MEETING`
    - `ENGAGEMENT_NOTE`
    - `ENGAGEMENT_TASK`
  - `TICKET`
    - `TICKET_COMPANY`
    - `TICKET_CONTACT`
    - `TICKET_DEAL`
    - `TICKET_ENGAGEMENT`
    - `TICKET_PROPERTY_HISTORY`
```
  - Please note that while these changes are breaking, the package has been updated to ensure backwards compatibility with the pre HubSpot v3 API updates. As a result, you may see some `null` fields which are artifacts of the pre v3 API HubSpot version. Be sure to inspect the relevant field descriptions for an understanding of which fields remain for backwards compatibility purposes. These fields will be removed once all HubSpot connectors are upgraded to the v3 API.

## Documentation Updates
- As new fields were added in the v3 API updates, and old fields were removed, the documentation was updated to reflect the v3 API consistent fields. Please take note if you are still using the pre v3 API, you will find the above mentioned source (and respective staging) models no longer have complete field documentation coverage.

# dbt_hubspot_source v0.10.0
## 🚨 Breaking Changes 🚨
- In the [May 2023 connector update](https://fivetran.com/docs/applications/hubspot/changelog#may2023) `type_id` was added to sources `DEAL_COMPANY` and `DEAL_CONTACT` as a part of the composite primary key for these tables. This column has been adding to the corresponding staging models. ([PR #109](https://github.com/fivetran/dbt_hubspot_source/pull/109))
- Updated tests for these tables with `type_id` as part of the primary key. ([PR #109](https://github.com/fivetran/dbt_hubspot_source/pull/109))
- Also resulting from the connector update, columns `updated_at` and `created_at` have been added to the following sources and their corresponding staging models: ([PR #109](https://github.com/fivetran/dbt_hubspot_source/pull/109))
  - `DEAL_PIPELINE`
  - `DEAL_PIPELINE_STAGE`
  - `TICKET_PIPELINE`
  - `TICKET_PIPELINE_STAGE`
- Updated docs with these changes and a little housekeeping. ([PR #109](https://github.com/fivetran/dbt_hubspot_source/pull/109))

## Feature Updates
- Updated README to include the variable `hubspot_owner_enabled`. ([PR #109](https://github.com/fivetran/dbt_hubspot_source/pull/109))

## 🚘 Under the Hood
- Updated seed data for testing newly added columns. ([PR #109](https://github.com/fivetran/dbt_hubspot_source/pull/109))

# dbt_hubspot_source v0.9.1
## Feature Updates
- A new variable was added `hubspot_using_all_email_events` to allow package users to remove filtered email events from the `stg_hubspot__email_event` staging model as well as the relevant downstream reporting models. This is crucial for HubSpot users who greatly take advantage of marking events as filtered in order to provide accurate reporting. ([PR #104](https://github.com/fivetran/dbt_hubspot_source/pull/104))
  - The `hubspot_using_all_email_events` variable is `true` by default. Set the variable to `false` to filter out specified email events in your staging and downstream models.

## Under the Hood
- The `email_event_data.csv` seed file was updated to include events that are listed as `true` for filtered_events. This is to effectively test the above mentioned feature update. ([PR #104](https://github.com/fivetran/dbt_hubspot_source/pull/104))
- Included `hubspot_using_all_email_events: false` as a variable declared in the final `run_models.sh` step to ensure our integration tests gain coverage over this new feature and variable. ([PR #104](https://github.com/fivetran/dbt_hubspot_source/pull/104))
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job. ([PR #103](https://github.com/fivetran/dbt_hubspot_source/pull/103))
- Updated the pull request [templates](/.github). ([PR #103](https://github.com/fivetran/dbt_hubspot_source/pull/103))

# dbt_hubspot_source v0.9.0

## 🚨 Breaking Changes 🚨
In [November 2022](https://fivetran.com/docs/applications/hubspot/changelog#november2022), the Fivetran Hubspot connector switched to v3 of the Hubspot CRM API, which deprecated the `CONTACT_MERGE_AUDIT` table and stored merged contacts in a field in the `CONTACT` table. **This has not been rolled out to BigQuery warehouses yet.** BigQuery connectors with the `CONTACT_MERGE_AUDIT` table enabled will continue to sync this table until the new `CONTACT.property_hs_calculated_merged_vids` field and API version becomes available to them.

This release introduces breaking changes around how contacts are merged in order to align with the above connector changes. It is, however, backwards-compatible.

[PR #98](https://github.com/fivetran/dbt_hubspot_source/pull/98) applies the following changes:
- Updates logic around the recently deprecated `CONTACT_MERGE_AUDIT` table.
  - The package now brings in the new `property_hs_calculated_merged_vids` field (and removes the `property_hs_` prefix) for all customers, including those on BigQuery (the field will just be `null`).
  - **Backwards-compatibility:** the package will only reference the old `CONTACT_MERGE_AUDIT` table and create `stg_hubspot__contact_merge_audit` if `hubspot_contact_merge_audit_enabled` is explicitly set to `true` in your root `dbt_project.yml` file.

## Bug Fixes
- The `CONTACT`, `COMPANY`, `DEAL`, and `TICKET` staging models have been updated to ensure users enabling the `hubspot__pass_through_all_columns` will have all required columns. ([PR #100](https://github.com/fivetran/dbt_hubspot_source/pull/100))
## Under the Hood
- Updates seed data to test new merging paradigm. ([PR #98](https://github.com/fivetran/dbt_hubspot_source/pull/98))
- Ensures that all timestamp fields are explicitly cast as timestamps without timezone, as recent API changes also introduced inconsistent timestamp formats. ([PR #98](https://github.com/fivetran/dbt_hubspot_source/pull/98))
- Creation of the `get_macro_columns` macro to help perform a check when enabling the `hubspot__pass_through_all_columns` to ensure the required fields are captured regardless of their existence in the source table. ([PR #100](https://github.com/fivetran/dbt_hubspot_source/pull/100))
- Creation of the `all_passthrough_column_check` macro to help ensure that the operation to bring in all fields for the `CONTACT`, `COMPANY`, `DEAL`, and `TICKET` staging models is performed **only** if additional fields from the required are present in the source. ([PR #100](https://github.com/fivetran/dbt_hubspot_source/pull/100))

See the transform package [CHANGELOG](https://github.com/fivetran/dbt_hubspot/blob/main/CHANGELOG.md) for updates made to end models in `dbt_hubspot v0.9.0`.

# dbt_hubspot_source v0.8.0

## 🚨 Breaking Changes 🚨:
[PR #96](https://github.com/fivetran/dbt_hubspot_source/pull/96) incorporates the following updates: 
- The `is_deleted` field has been renamed within the below models:
  - `stg_hubspot__company` ( `is_company_deleted`)
  - `stg_hubspot__deal` (`is_deal_deleted`)
  - `stg_hubspot__ticket` (`is_ticket_deleted`)

- The `_fivetran_deleted` field has been renamed within the below models:
  - `stg_husbpot__contact_list_member` (`is_contact_list_member_deleted`)
  - `stg_hubspot__contact_list` (`is_contact_list_deleted`)
  - `stg_hubspot__contact` (`is_contact_deleted`)
  - `stg_hubspot__deal_pipeline_stage` (`is_deal_pipeline_stage_deleted`)
  - `stg_hubspot__deal_pipeline` (`is_deal_pipeline_deleted`)
  - `stg_hubspot__ticket_pipeline_stage` (`is_ticket_pipeline_stage_deleted`)
  - `stg_hubspot__ticket_pipeline` (`is_ticket_pipeline_deleted`)

- Filtering deleted records with the methods `where not coalesce(is_deleted, false)` or `where not coalesce(_fivetran_deleted, false)` has been removed from the above models. Instead, the new `is_<model>_deleted` flags will now offer customers flexibility to filter models for deleted records as necessary.

## Under the Hood
- `stg*.yml` documentation has been updated such that all `is_<model>_deleted` fields point to the `is_deleted` definition rather than respective `is_deleted` and `_fivetran_deleted` since the two fields are equivalent and in order to maintain consistency. ([PR #96](https://github.com/fivetran/dbt_hubspot_source/pull/96)).

# dbt_hubspot_source v0.7.0
## 🚨 Breaking Changes 🚨:
[PR #89](https://github.com/fivetran/dbt_hubspot_source/pull/89/files) includes the following breaking changes:
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

## 🎉 Features
- 🧱 Databricks compatibility! [(PR #91)](https://github.com/fivetran/dbt_hubspot_source/pull/91)

# dbt_hubspot_source v0.6.4
PR [#88](https://github.com/fivetran/dbt_hubspot_source/pull/88) incorporates the following updates:
## Fixes
- Added column descriptions that were missing in [our documentation](https://fivetran.github.io/dbt_hubspot_source/#!/overview).

# dbt_hubspot_source v0.6.3
## Fixes
- Fixes a bug in the models `stg_hubspot__engagement_meeting.sql` and `stg_hubspot__engagement_meeting_tmp.sql` where the `fivetran_utils.enabled_vars` macro was referencing the wrong variable (`hubspot_engagement_email_enabled`) from the vars list in the `dbt_project.yml`. 
- Also updates `src_hubspot.yml` variable to `hubspot_engagement_meeting_enabled`. This was preventing users from disabling these enagagement_meeting models in their projects. ([#85](https://github.com/fivetran/dbt_hubspot_source/pull/85))

## Contributors
- [@fivetran-seanodriscoll](https://github.com/fivetran-seanodriscoll) ([#83](https://github.com/fivetran/dbt_hubspot_source/pull/83))

# dbt_hubspot_source v0.6.2
## Fixes
- Removes the `fivetran_utils.enabled_vars` macro from the configuration blocks of models dependent on `hubspot_service_enabled`, `hubspot_contact_merge_audit_enabled`, and `hubspot_ticket_deal_enabled`. This macro assumes its arguments to be true by default, which these variables are not. This produces conflicts if you do not provide explicit values for these variables in your root dbt_project.yml file.

# dbt_hubspot_source v0.6.1
## Fixes
- Removes default variable configs in the `dbt_project.yml` for `hubspot_service_enabled`, `hubspot_contact_merge_audit_enabled`, and `hubspot_ticket_deal_enabled`. Otherwise it will conflict with enable configs in the source tables. 
- Toggle default enable in the `src.yml` to false for `hubspot_service_enabled`, `hubspot_contact_merge_audit_enabled`, and `hubspot_ticket_deal_enabled`. 

# dbt_hubspot_source v0.6.0
## 🎉 Documentation and Feature Updates
- Updated README documentation updates for easier navigation and setup of the dbt package
- Included `hubspot_[source_table_name]_identifier` variable for additional flexibility within the package when source tables are named differently.
- Adds `hubspot_ticket_deal_enabled` variable (default value=`False`) to disable modelling and testing of the `ticket_deal` source table. If there are no associations between tickets and deals in your Hubspot environment, this table will not exist ([#79](https://github.com/fivetran/dbt_hubspot_source/pull/79)).

## Fixes
- Consistently renames `property_dealname`, `property_closedate`, and `property_createdate` to `deal_name`, `closed_at`, and `created_at`, respectively, in the `deals` staging model. Previously, if `hubspot__pass_through_all_columns = true`, only the prefix `property_` was removed from the names of these fields, while they were completely renamed to `deal_name`, `closed_at`, and `created_at` if `hubspot__pass_through_all_columns = false` ([#79](https://github.com/fivetran/dbt_hubspot_source/pull/79)).
- Bypass freshness tests for when a source is disabled by adding an enable/disable config to the source yml ([#77](https://github.com/fivetran/dbt_hubspot_source/pull/77))
**Notice**: You must have dbt v1.1.0 or greater for the config to work. 
## Contributors
- [@gabriel-inventa](https://github.com/gabriel-inventa) ([#72](https://github.com/fivetran/dbt_hubspot_source/issues/72))

# dbt_hubspot_source v0.5.7
## Fixes
- Spelling correction of variable names within the README. ([#73](https://github.com/fivetran/dbt_hubspot_source/pull/73))

## Contributors
- [@mp56](https://github.com/moreaupascal56) ([#73](https://github.com/fivetran/dbt_hubspot_source/pull/73))

# dbt_hubspot_source v0.5.6
## Bug Fixes
- The below staging tables contain a `where` clause to filter out soft deletes. However, this where clause was conducted in the first CTE of the staging model before the `fill_staging_columns` macro. Therefore, if the field doesn't exist, the dbt run would fail. These updates have moved the CTE to the final one to avoid this error. ([#68](https://github.com/fivetran/dbt_hubspot_source/pull/68))
  - `stg_hubspot__company`, `stg_hubspot__contact`, `stg_hubspot__contact_list`, `stg_hubspot__deal`, `stg_hubspot__deal_pipeline`, `stg_hubspot__deal_pipeline_stage`, `stg_hubspot__ticket`, and `stg_hubspot__contact_list`.

## Contributors
- [@sambradbury](https://github.com/sambradbury) ([#67](https://github.com/fivetran/dbt_hubspot_source/pull/67))

# dbt_hubspot_source v0.5.5
## Fixes
- Adds missing `stg_hubspot__deal_contact` model. ([#64](https://github.com/fivetran/dbt_hubspot_source/pull/64))

## Contributors
- [@dietofworms](https://github.com/dietofworms) ([#64](https://github.com/fivetran/dbt_hubspot_source/pull/64))

# dbt_hubspot_source v0.5.4
## Fixes
- Updated the README to reference the proper `hubspot_email_event_spam_report_enabled` variable name. ([#59](https://github.com/fivetran/dbt_hubspot_source/pull/59))
- Adds missing `is_deleted` field when using custom columns. ([#61](https://github.com/fivetran/dbt_hubspot_source/pull/61))

## Contributors
- [@cmcau](https://github.com/cmcau) ([#59](https://github.com/fivetran/dbt_hubspot_source/pull/59))
- [@ABCurado](https://github.com/ABCurado) ([#61](https://github.com/fivetran/dbt_hubspot_source/pull/61))
# dbt_hubspot_source v0.5.3

## Under the Hood
- Cast the `deal_pipeline_stage_id` and `deal_pipeline_id` fields within the stg_hubspot__deal_pipeline, stg_hubspot__deal_pipeline_stage, stg_hubspot__deal using the `dbt_utils.type_string()` macro. This ensures joins in downstream models are accurate across warehouses. ([#57](https://github.com/fivetran/dbt_hubspot_source/pull/57))

# dbt_hubspot_source v0.5.2

## Updates
- Removing unused models `stg_hubspot__engagement_email_cc` and `stg_hubspot__engagement_email_to` from `stg_hubspot__engagement.yml` ([#56](https://github.com/fivetran/dbt_hubspot_source/pull/56))

## Contributors
- @ericalouie ([#60](https://github.com/fivetran/dbt_hubspot/issues/60)).

# dbt_hubspot_source v0.5.1

## Updates
- Updating `README.md` to reflect global variable references in `dbt_project.yml` to be consistent with `dbt_hubspot` package.
# dbt_hubspot_source v0.5.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_fivetran_utils`. The latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_hubspot_source v0.1.0 -> v0.4.3
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!
