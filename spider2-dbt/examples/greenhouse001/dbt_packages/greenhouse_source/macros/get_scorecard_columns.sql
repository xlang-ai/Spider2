{% macro get_scorecard_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "application_id", "datatype": dbt.type_int()},
    {"name": "candidate_id", "datatype": dbt.type_int()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "interview", "datatype": dbt.type_string()},
    {"name": "interviewed_at", "datatype": dbt.type_timestamp()},
    {"name": "overall_recommendation", "datatype": dbt.type_string()},
    {"name": "submitted_at", "datatype": dbt.type_timestamp()},
    {"name": "submitted_by_user_id", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
