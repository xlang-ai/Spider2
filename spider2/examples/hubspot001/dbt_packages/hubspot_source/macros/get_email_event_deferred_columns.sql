{% macro get_email_event_deferred_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "attempt", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "response", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
