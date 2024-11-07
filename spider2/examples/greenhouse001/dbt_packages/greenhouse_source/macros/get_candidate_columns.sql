{% macro get_candidate_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "company", "datatype": dbt.type_string()},
    {"name": "coordinator_id", "datatype": dbt.type_int()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "is_private", "datatype": "boolean"},
    {"name": "last_activity", "datatype": dbt.type_timestamp()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "new_candidate_id", "datatype": dbt.type_int()},
    {"name": "recruiter_id", "datatype": dbt.type_int()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
