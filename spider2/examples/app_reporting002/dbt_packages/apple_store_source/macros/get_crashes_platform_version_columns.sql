{% macro get_crashes_platform_version_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "app_id", "datatype": dbt.type_int()},
    {"name": "crashes", "datatype": dbt.type_int()},
    {"name": "date", "datatype": dbt.type_timestamp()},
    {"name": "device", "datatype": dbt.type_string()},
    {"name": "meets_threshold", "datatype": "boolean"},
    {"name": "platform_version", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
