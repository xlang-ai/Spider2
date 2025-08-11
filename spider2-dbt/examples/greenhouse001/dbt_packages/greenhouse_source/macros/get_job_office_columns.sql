{% macro get_job_office_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "job_id", "datatype": dbt.type_int()},
    {"name": "office_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
