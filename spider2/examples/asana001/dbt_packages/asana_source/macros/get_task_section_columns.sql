{% macro get_task_section_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "section_id", "datatype": dbt.type_string()},
    {"name": "task_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
