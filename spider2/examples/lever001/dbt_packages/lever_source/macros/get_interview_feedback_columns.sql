{% macro get_interview_feedback_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "feedback_form_id", "datatype": dbt.type_string()},
    {"name": "interview_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
