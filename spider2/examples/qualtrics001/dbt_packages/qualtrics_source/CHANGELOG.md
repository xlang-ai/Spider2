# dbt_qualtrics_source v0.2.2
[PR #9](https://github.com/fivetran/dbt_qualtrics_source/pull/9) includes the following updates: 

## Bug Fix
- Updated unique combination of columns test on `stg_qualtrics__distribution_contact` to include `contact_lookup_id`. [This is due to a connector update](https://fivetran.com/docs/connectors/applications/qualtrics/changelog#january2024) that changes the primary composite key of the `distribution_contact` source table to include `contact_lookup_id`. ([PR #8](https://github.com/fivetran/dbt_qualtrics_source/pull/8))

## Contributors
- [@dmcmtntp](https://github.com/dmcmtntp) ([PR #8](https://github.com/fivetran/dbt_qualtrics_source/pull/8))

# dbt_qualtrics_source v0.2.1

[PR #6](https://github.com/fivetran/dbt_qualtrics_source/pull/6) includes the following updates: 

## Bug Fix
- Updated model `stg_qualtrics__survey_response` to use a case statement to determine the `is_finished` boolean value instead of a straight cast to boolean. 
    - This is necessary for warehouses that do not support the straight cast.

## Under the Hood
- Updated the integration tests seed `survey_response` to test both possible values for `finished`.

# dbt_qualtrics_source v0.2.0

[PR #5](https://github.com/fivetran/dbt_qualtrics_source/pull/5) includes the following updates: 

## 🚨 Breaking Changes: Bug Fixes 🚨
- Casted the following timestamp fields in the below models using the `dbt.type_timestamp()` macro. This is necessary to ensure all timestamps are consistently casted and do not experience datatype mismatches in downstream transformations.
    - `stg_qualtrics__contact_mailing_list_membership`
        - unsubscribed_at
    - `stg_qualtrics__directory_contact`
        - created_at
        - unsubscribed_from_directory_at
        - last_modified_at
    - `stg_qualtrics__directory_mailing_list`
        - created_at
        - last_modified_at
    - `stg_qualtrics__distribution_contact`
        - opened_at
        - response_completed_at
        - response_started_at
        - sent_at
    - `stg_qualtrics__distribution`
        - created_at
        - last_modified_at
        - send_at
        - survey_link_expires_at
    - `stg_qualtrics__survey_response`
        - finished_at
        - last_modified_at
        - recorded_date
        - started_at
    - `stg_qualtrics__survey_version`
        - created_at
    - `stg_qualtrics__survey`
        - last_accessed_at
        - last_activated_at
        - last_modified_at
    - `stg_qualtrics__user`
        - account_created_at
        - account_expires_at
        - last_login_at
        - password_expires_at
        - password_last_changed_at

> Please note: this update will likely only impact Redshift destinations as it was found the connector synced these fields as `timestamp with time zone` when in fact they were without. Most users will not see any changes following this release. But we marked this as breaking to ensure no possible datatype conflicts downstream.

## Under the Hood
- Updated the maintainer PR template to resemble the most up to date format.
- Added the auto release GitHub Action for easier deployment.

# dbt_qualtrics_source v0.1.1
[PR #4](https://github.com/fivetran/dbt_qualtrics_source/pull/4) includes the following update:
## Bug fix
- Shortened the documentation description for field `distribution_status`, so no character limit error occurs when persisting docs.

# dbt_qualtrics_source v0.1.0
This is the initial release of the Qualtrics dbt source package!

# 📣 What does this dbt package do?
<!--section="qualtrics_source_model"-->
- Materializes [Qualtrics staging tables](https://fivetran.github.io/dbt_qualtrics_source/#!/overview/github_source/models/?g_v=1) which leverage data in the format described by [this ERD](https://fivetran.com/docs/applications/qualtrics/#schemainformation). These staging tables clean, test, and prepare your Qualtrics data from [Fivetran's connector](https://fivetran.com/docs/applications/qualtrics) for analysis by doing the following:
  - Name columns for consistency across all packages and for easier analysis
    - Primary keys are renamed from `id` to `<table name>_id`. 
    - Foreign key names explicitly map onto their related tables (ie `owner_id` -> `owner_user_id`).
    - Datetime fields are renamed to `<event happened>_at`.
  - Adds column-level testing where applicable. For example, all primary keys are tested for uniqueness and non-null values.
- Generates a comprehensive data dictionary of your Qualtrics data through the [dbt docs site](https://fivetran.github.io/dbt_qualtrics_source/).
- These tables are designed to work simultaneously with our [Qualtrics transformation package](https://github.com/fivetran/dbt_qualtrics).
