{% macro get_archive_reason_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "text", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
