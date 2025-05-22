{% macro get_task_tag_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "tag_id", "datatype": dbt.type_string()},
    {"name": "task_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
