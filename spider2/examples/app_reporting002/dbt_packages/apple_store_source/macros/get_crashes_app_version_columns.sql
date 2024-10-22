{% macro get_crashes_app_version_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "app_id", "datatype": dbt.type_int()},
    {"name": "app_version", "datatype": dbt.type_string()},
    {"name": "crashes", "datatype": dbt.type_int()},
    {"name": "date", "datatype": dbt.type_timestamp()},
    {"name": "device", "datatype": dbt.type_string()},
    {"name": "meets_threshold", "datatype": "boolean"}
] %}

{{ return(columns) }}

{% endmacro %}
