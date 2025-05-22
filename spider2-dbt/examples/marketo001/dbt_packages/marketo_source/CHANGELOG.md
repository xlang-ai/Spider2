# dbt_marketo_source v0.11.0
[PR #35](https://github.com/fivetran/dbt_marketo_source/pull/35) includes the following updates:

## Feature Updates (includes 🚨 breaking changes 🚨)
- Ensures that `stg_marketo__lead` has and documents the below columns, all [standard](https://developers.marketo.com/rest-api/lead-database/fields/list-of-standard-fields/) fields from Marketo. Previously, peristed all fields found in your `LEAD` source table but only _ensured_ that the `id`, `created_at`, `updated_at`, `email`, `first_name`, `last_name`, and `_fivetran_synced` fields were included. If any of the following default columns are missing from your `LEAD` table, `stg_marketo__lead` will create a NULL version with the proper data type:
  - `phone`
  - `main_phone`
  - `mobile_phone`
  - `company`
  - `inferred_company`
  - `address_lead`
  - `address`
  - `city`
  - `state`
  - `state_code`
  - `country`
  - `country_code`
  - `postal_code`
  - `billing_street`
  - `billing_city`
  - `billing_state`
  - `billing_state_code`
  - `billing_country`
  - `billing_country_code`
  - `billing_postal_code`
  - `inferred_city`
  - `inferred_state_region`
  - `inferred_country`
  - `inferred_postal_code`
  - `inferred_phone_area_code`
  - `anonymous_ip`
  - `unsubscribed` -> aliased as `is_unsubscribed` (🚨 breaking change 🚨)
  - `email_invalid` -> aliased as `is_email_invalid` (🚨 breaking change 🚨)
  - `do_not_call`

> Note: the above fields will persist downstream into the [transform](https://github.com/fivetran/dbt_marketo/blob/main/models/marketo__leads.sql) `marketo__leads` model.

## Under the Hood
- Updated the maintainer PR template to resemble the most up to date format.
- Included auto-releaser GitHub Actions workflow to automate future releases.

# dbt_marketo_source v0.10.0
## 🚨 Breaking Changes 🚨:
[PR #33](https://github.com/fivetran/dbt_marketo_source/pull/33) includes the following updates in connection with the Fivetran Marketo connector's [June 2023](https://fivetran.com/docs/applications/marketo/changelog#june2023) and [May 2023](https://fivetran.com/docs/applications/marketo/changelog#may2023) releases:
- Added passthrough column support for the following sources. (**Note**: If you are missing any columns from the prior version of this package, utilize the passthrough capability to bring these columns in. Only non-custom columns are included going forward. For more information refer to the [Passing Through Additional Columns section](https://github.com/fivetran/dbt_marketo_source#optional-step-5-additional-configurations) in the README.)
  - activity_send_email
  - program
- Following the connector upgrade, a number of fields were removed and added to the source tables. These added and removed fields have been accounted for appropriately within the staging models. See the full list below:
  - Fields *added* to `lead`:
    - email
    - first_name
    - last_name
  - Fields *added* to `program`:
    - _fivetran_deleted
  - Fields *removed* from `campaign`:
    - program_name
  - Fields *added* to `campaign`:
    - computed_url
    - flow_id
    - folder_id
    - folder_type
    - is_communication_limit_enabled
    - is_requestable
    - is_system
    - max_members
    - qualification_rule_type
    - qualification_rule_interval
    - qualification_rule_unit
    - recurrence_start_at
    - recurrence_end_at
    - recurrence_interval_type
    - recurrence_interval
    - recurrence_weekday_only
    - recurrence_day_of_month
    - recurrence_day_of_week
    - recurrence_week_of_month
    - smart_list_id
    - status
    - _fivetran_deleted

## 🚘 Under the Hood:
[PR #33](https://github.com/fivetran/dbt_marketo_source/pull/33) includes the following updates:
- Updated the following models to filter out records where `_fivetran_deleted`is true. 
  - `stg_marketo__campaigns`
  - `stg_marketo__program`
- Updated documentation and testing seed data
[PR #31](https://github.com/fivetran/dbt_marketo_source/pull/31) includes the following updates:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request [templates](/.github).

# dbt_marketo_source v0.9.0

## 🚨 Breaking Changes 🚨:
[PR #30](https://github.com/fivetran/dbt_marketo_source/pull/30) includes the following breaking changes:
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

# dbt_marketo_source v0.8.0
PR [#28](https://github.com/fivetran/dbt_marketo_source/pull/28) incorporates the following updates:
## 🚨 Breaking Changes 🚨
Some of the more complex transformation logic has been moved from the Marketo source package to the transform package. This was done so the delineation between staging and intermediate models is in line with Fivetran's other packages. This does not affect the final tables created by the transform package, but this will affect the staging tables as outlined below. 
- Model `stg_marketo__lead_base` from `dbt_marketo_source` has been rolled into [`stg_marketo__lead`](https://github.com/fivetran/dbt_marketo_source/blob/main/models/stg_marketo__lead.sql).
- Parts from model `stg_marketo__lead` from `dbt_marketo_source` have been moved to a new model [`int_marketo__lead`](https://github.com/fivetran/dbt_marketo/blob/feature/create-intermediates/models/intermediate/int_marketo__lead.sql) in `dbt_marketo`.
- The default schema for the source tables are now built within a schema titled (`<target_schema>` + `_marketo_source`) in your destination. The previous default schema was (`<target_schema>` + `_stg_marketo`). This may be overwritten if desired.
## Features
- 🎉 Databricks and Postgres compatibility 🎉
- Ability to disable `activity_delete_lead` model if necessary (see [README](link) for instructions). 
- Updated structure of config default variables for enabling `campaigns` and `program` models to avoid conflicting with a user's settings. 
- Added `marketo_[source_table_name]_identifier` variables to allow for easier flexibility of the package to refer to source tables with different names.

# dbt_marketo_source v0.7.2
## Bug Fixes
- Updated surrogate key `email_send_id` to include `primary_attribute_value_id`. The previous key was at a campaign level grain, not an email level grain. This is pertinent in the case where there are multiple emails that are part of the same campaign.
[#26](https://github.com/fivetran/dbt_marketo_source/pull/26)
## Contributors
- [sfc-gh-sugupta](https://github.com/sfc-gh-sugupta) [#25](https://github.com/fivetran/dbt_marketo_source/issues/25)
# dbt_marketo_source v0.7.1

## Bug Fixes
- Explicitly cast the activity_timestamp field as `timestamp without time zone`, otherwise in Redshift this would be passed down as `timestamp with time zone` and cause date functions to fail (https://github.com/fivetran/dbt_marketo_source/issues/22)
[#23](https://github.com/fivetran/dbt_marketo_source/pull/23)
# dbt_marketo_source v0.7.0

## Bug Fixes
- Previously, `merged_into_lead_id` and `lead_id` were erroneously switched in `stg_marketo__lead`. This release switches them back, appropriately casting `merged_into_lead_id` as a string (it can have multiple comma-separated values) and `lead_id` as an integer (https://github.com/fivetran/dbt_marketo/issues/17).

This is a **BREAKING CHANGE** as you will need to run a full refresh due to the columns' differing data types. 

# dbt_marketo_source v0.6.0
🎉 dbt v1.0.0 Compatibility 🎉
## 🚨 Breaking Changes 🚨
- Adjusts the `require-dbt-version` to now be within the range [">=1.0.0", "<2.0.0"]. Additionally, the package has been updated for dbt v1.0.0 compatibility. If you are using a dbt version <1.0.0, you will need to upgrade in order to leverage the latest version of the package.
  - For help upgrading your package, I recommend reviewing this GitHub repo's Release Notes on what changes have been implemented since your last upgrade.
  - For help upgrading your dbt project to dbt v1.0.0, I recommend reviewing dbt-labs [upgrading to 1.0.0 docs](https://docs.getdbt.com/docs/guides/migration-guide/upgrading-to-1-0-0) for more details on what changes must be made.
- Upgrades the package dependency to refer to the latest `dbt_fivetran_utils`. The latest `dbt_fivetran_utils` package also has a dependency on `dbt_utils` [">=0.8.0", "<0.9.0"].
  - Please note, if you are installing a version of `dbt_utils` in your `packages.yml` that is not in the range above then you will encounter a package dependency error.

# dbt_marketo_source v0.1.0 -> v0.5.0
Refer to the relevant release notes on the Github repository for specific details for the previous releases. Thank you!