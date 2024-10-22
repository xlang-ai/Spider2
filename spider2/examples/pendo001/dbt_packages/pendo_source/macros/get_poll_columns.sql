{% macro get_poll_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "attribute_display", "datatype": dbt.type_string()},
    {"name": "attribute_follow_up", "datatype": dbt.type_string()},
    {"name": "attribute_max_length", "datatype": dbt.type_string()},
    {"name": "attribute_placeholder", "datatype": dbt.type_string()},
    {"name": "attribute_type", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "question", "datatype": dbt.type_string()},
    {"name": "reset_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
