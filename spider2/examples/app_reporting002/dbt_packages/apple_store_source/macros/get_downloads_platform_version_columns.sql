{% macro get_downloads_platform_version_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "app_id", "datatype": dbt.type_int()},
    {"name": "date", "datatype": dbt.type_timestamp()},
    {"name": "first_time_downloads", "datatype": dbt.type_int()},
    {"name": "meets_threshold", "datatype": "boolean"},
    {"name": "platform_version", "datatype": dbt.type_string()},
    {"name": "redownloads", "datatype": dbt.type_int()},
    {"name": "source_type", "datatype": dbt.type_string()},
    {"name": "total_downloads", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
