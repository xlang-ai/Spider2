{% macro get_application_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "applied_at", "datatype": dbt.type_timestamp()},
    {"name": "candidate_id", "datatype": dbt.type_int()},
    {"name": "credited_to_user_id", "datatype": dbt.type_int()},
    {"name": "current_stage_id", "datatype": dbt.type_int()},

    {"name": "id", "datatype": dbt.type_int()},
    {"name": "is_deleted", "datatype": "boolean"},
    {"name": "last_activity_at", "datatype": dbt.type_timestamp()},
    {"name": "location_address", "datatype": dbt.type_string()},
    {"name": "prospect", "datatype": "boolean"},
    {"name": "prospect_owner_id", "datatype": dbt.type_int()},
    {"name": "prospect_pool_id", "datatype": dbt.type_int()},
    {"name": "prospect_stage_id", "datatype": dbt.type_int()},
    {"name": "rejected_at", "datatype": dbt.type_timestamp()},
    {"name": "rejected_reason_id", "datatype": dbt.type_int()},
    {"name": "source_id", "datatype": dbt.type_int()},
    {"name": "status", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
