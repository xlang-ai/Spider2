{% macro get_feedback_form_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "candidate_id", "datatype": dbt.type_string()},
    {"name": "completed_at", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "creator_id", "datatype": dbt.type_string()},
    {"name": "deleted_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "instructions", "datatype": dbt.type_string()},
    {"name": "interview_id", "datatype": dbt.type_string()},
    {"name": "opportunity_id", "datatype": dbt.type_string()},
    {"name": "score_system_value", "datatype": dbt.type_string()},
    {"name": "template_id", "datatype": dbt.type_string()},
    {"name": "text", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
