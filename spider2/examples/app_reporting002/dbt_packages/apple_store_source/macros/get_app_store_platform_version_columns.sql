{% macro get_app_store_platform_version_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "app_id", "datatype": dbt.type_int()},
    {"name": "date", "datatype": dbt.type_timestamp()},
    {"name": "impressions", "datatype": dbt.type_int()},
    {"name": "impressions_unique_device", "datatype": dbt.type_int()},
    {"name": "meets_threshold", "datatype": "boolean"},
    {"name": "page_views", "datatype": dbt.type_int()},
    {"name": "page_views_unique_device", "datatype": dbt.type_int()},
    {"name": "platform_version", "datatype": dbt.type_string()},
    {"name": "source_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
