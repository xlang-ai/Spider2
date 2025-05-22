{% macro get_interview_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "canceled_at", "datatype": dbt.type_timestamp()},
    {"name": "candidate_id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "creator_id", "datatype": dbt.type_string()},
    {"name": "date", "datatype": dbt.type_timestamp()},
    {"name": "duration", "datatype": dbt.type_int()},
    {"name": "feedback_reminder", "datatype": dbt.type_string()},
    {"name": "gcal_event_url", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "location", "datatype": dbt.type_string()},
    {"name": "note", "datatype": dbt.type_string()},
    {"name": "opportunity_id", "datatype": dbt.type_string()},
    {"name": "panel_id", "datatype": dbt.type_string()},
    {"name": "stage_id", "datatype": dbt.type_string()},
    {"name": "subject", "datatype": dbt.type_string()},
    {"name": "timezone", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
