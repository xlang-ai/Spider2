* Deprecation Warning: The "packages" argument of adapter.dispatch() has been
deprecated. Use the "macro_namespace" argument instead.
Raised during dispatch for: percentile
For more information, see:
https://docs.getdbt.com/reference/dbt-jinja-functions/dispatch
{% macro get_twitter_user_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "contributors_enabled", "datatype": "boolean"},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "default_profile", "datatype": "boolean"},
    {"name": "default_profile_image", "datatype": "boolean"},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "favourites_count", "datatype": dbt.type_int()},
    {"name": "followers_count", "datatype": dbt.type_int()},
    {"name": "friends_count", "datatype": dbt.type_int()},
    {"name": "geo_enabled", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "is_translation_enabled", "datatype": "boolean"},
    {"name": "is_translator", "datatype": "boolean"},
    {"name": "lang", "datatype": dbt.type_string()},
    {"name": "listed_count", "datatype": dbt.type_int()},
    {"name": "location", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "profile_background_image_url", "datatype": dbt.type_string()},
    {"name": "profile_background_image_url_https", "datatype": dbt.type_string()},
    {"name": "profile_background_tile", "datatype": "boolean"},
    {"name": "profile_banner_url", "datatype": dbt.type_string()},
    {"name": "profile_image_url", "datatype": dbt.type_string()},
    {"name": "profile_image_url_https", "datatype": dbt.type_string()},
    {"name": "profile_use_background_image", "datatype": dbt.type_string()},
    {"name": "protected_user", "datatype": "boolean"},
    {"name": "screen_name", "datatype": dbt.type_string()},
    {"name": "statuses_count", "datatype": dbt.type_int()},
    {"name": "time_zone", "datatype": dbt.type_string()},
    {"name": "url", "datatype": dbt.type_string()},
    {"name": "utc_offset", "datatype": dbt.type_int()},
    {"name": "verified", "datatype": "boolean"}
] %}

{{ return(columns) }}

{% endmacro %}
