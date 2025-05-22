{% macro get_sprint_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "board_id", "datatype": dbt.type_int()},
    {"name": "complete_date", "datatype": dbt.type_timestamp()},
    {"name": "end_date", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "start_date", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
