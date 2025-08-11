{% macro get_interview_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "interview_kit_content", "datatype": dbt.type_string()},
    {"name": "job_stage_id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
