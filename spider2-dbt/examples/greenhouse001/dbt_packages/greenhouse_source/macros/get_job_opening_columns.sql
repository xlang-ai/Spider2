{% macro get_job_opening_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "application_id", "datatype": dbt.type_int()},
    {"name": "close_reason_id", "datatype": dbt.type_int()},
    {"name": "closed_at", "datatype": dbt.type_timestamp()},

    {"name": "id", "datatype": dbt.type_int()},
    {"name": "job_id", "datatype": dbt.type_int()},
    {"name": "opened_at", "datatype": dbt.type_timestamp()},
    {"name": "opening_id", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
