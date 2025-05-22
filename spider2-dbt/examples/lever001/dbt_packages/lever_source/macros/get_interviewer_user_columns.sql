{% macro get_interviewer_user_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "interview_id", "datatype": dbt.type_string()},
    {"name": "user_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
