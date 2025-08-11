{% macro get_job_application_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "application_id", "datatype": dbt.type_int()},
    {"name": "job_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
