# dbt_facebook_pages v0.3.0

[PR #11](https://github.com/fivetran/dbt_facebook_pages/pull/11) includes the following breaking changes:
## 🚨 Breaking Changes 🚨:
- This change is made breaking since columns have been removed in the source package (see the [dbt_facebook_pages_source v0.3.0 CHANGELOG](https://github.com/fivetran/dbt_facebook_pages_source/blob/main/CHANGELOG.md#dbt_facebook_pages_source-v030) for more details). 
    - No columns were removed from the end models in this package, however if you use the staging models independently, you will need to update your downstream use cases accordingly.
    - Columns removed from staging model `stg_facebook_pages__daily_page_metrics_total`:
        - `consumptions`
        - `content_activity`
        - `engaged_users`
        - `places_checkin_mobile`
        - `views_external_referrals`
        - `views_logged_in_total`
        - `views_logout`
    - Columns removed from staging model `stg_facebook_pages__lifetime_post_metrics_total`:
        - `impressions_fan_paid`

## Documentation Update
- Updated documentation to reflect the current schema. 

## Under the Hood:
- Incorporated the new `fivetran_utils.drop_schemas_automation` macro into the end of each Buildkite integration test job.
- Updated the pull request templates.
- Included auto-releaser GitHub Actions workflow to automate future releases.

# dbt_facebook_pages v0.2.0

## 🚨 Breaking Changes 🚨:
[PR #6](https://github.com/fivetran/dbt_facebook_pages/pull/6/) includes the following breaking changes:
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

# dbt_facebook_pages v0.1.0

The original release! The main focus of the package is to transform the core social media object tables into analytics-ready models that can be easily unioned in to other social media platform packages to get a single view. This is especially easy using our [Social Media Reporting package](https://github.com/fivetran/dbt_social_media_reporting).
