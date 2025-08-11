{% macro get_application_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "agent_policy_prod", "datatype": dbt.type_string()},
    {"name": "agent_policy_staging", "datatype": dbt.type_string()},
    {"name": "agent_version_prod", "datatype": dbt.type_string()},
    {"name": "agent_version_staging", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "created_by_user_id", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "disabled_at", "datatype": dbt.type_timestamp()},
    {"name": "display_name", "datatype": dbt.type_string()},
    {"name": "event_count", "datatype": dbt.type_int()},
    {"name": "event_rate", "datatype": dbt.type_int()},
    {"name": "first_event_time", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "integrated", "datatype": "boolean"},
    {"name": "is_deleted", "datatype": "boolean"},
    {"name": "last_updated_at", "datatype": dbt.type_timestamp()},
    {"name": "last_updated_by_user_id", "datatype": dbt.type_string()},
    {"name": "marked_for_deletion_at", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "platform", "datatype": dbt.type_string()},
    {"name": "push_application_id", "datatype": dbt.type_string()},
    {"name": "record_until", "datatype": dbt.type_timestamp()},
    {"name": "sampling_rate", "datatype": dbt.type_timestamp()},
    {"name": "starting_event_time", "datatype": dbt.type_timestamp()},
    {"name": "subscription_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
