{% macro get_job_department_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "department_id", "datatype": dbt.type_int()},
    {"name": "job_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
