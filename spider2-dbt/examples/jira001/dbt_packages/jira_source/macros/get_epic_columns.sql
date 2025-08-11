{% macro get_epic_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "done", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "key", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "summary", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}