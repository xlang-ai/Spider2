{% macro get_task_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "activity_date", "datatype": dbt.type_timestamp()},
    {"name": "call_disposition", "datatype": dbt.type_string()},
    {"name": "call_duration_in_seconds", "datatype": dbt.type_int()},
    {"name": "call_object", "datatype": dbt.type_string()},
    {"name": "call_type", "datatype": dbt.type_string()},
    {"name": "completed_date_time", "datatype": dbt.type_timestamp()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "is_archived", "datatype": "boolean"},
    {"name": "is_closed", "datatype": "boolean"},
    {"name": "is_deleted", "datatype": "boolean"},
    {"name": "is_high_priority", "datatype": "boolean"},
    {"name": "last_modified_by_id", "datatype": dbt.type_string()},
    {"name": "last_modified_date", "datatype": dbt.type_timestamp()},
    {"name": "owner_id", "datatype": dbt.type_string()},
    {"name": "priority", "datatype": dbt.type_string()},
    {"name": "record_type_id", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "subject", "datatype": dbt.type_string()},
    {"name": "task_subtype", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "what_count", "datatype": dbt.type_int()},
    {"name": "what_id", "datatype": dbt.type_string()},
    {"name": "who_count", "datatype": dbt.type_int()},
    {"name": "who_id", "datatype": dbt.type_string()}
] %}

{{ salesforce_source.add_renamed_columns(columns) }}

{{ fivetran_utils.add_pass_through_columns(columns, var('salesforce__task_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
