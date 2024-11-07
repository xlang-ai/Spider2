{% macro get_campaign_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "active", "datatype": "boolean"},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "program_id", "datatype": dbt.type_int()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "workspace_name", "datatype": dbt.type_string()},
    {"name": "computed_url", "datatype": dbt.type_string()},
    {"name": "flow_id", "datatype": dbt.type_int()},
    {"name": "folder_id", "datatype": dbt.type_int()},
    {"name": "folder_type", "datatype": dbt.type_string()},
    {"name": "is_communication_limit_enabled", "datatype": dbt.type_boolean()},
    {"name": "is_requestable", "datatype": dbt.type_boolean()},
    {"name": "is_system", "datatype": dbt.type_boolean()},
    {"name": "max_members", "datatype": dbt.type_int()},
    {"name": "qualification_rule_type", "datatype": dbt.type_string()},
    {"name": "qualification_rule_interval", "datatype": dbt.type_int()},
    {"name": "qualification_rule_unit", "datatype": dbt.type_string()},
    {"name": "recurrence_start_at", "datatype": dbt.type_timestamp()},
    {"name": "recurrence_end_at", "datatype": dbt.type_timestamp()},
    {"name": "recurrence_interval_type", "datatype": dbt.type_string()},
    {"name": "recurrence_interval", "datatype": dbt.type_int()},
    {"name": "recurrence_weekday_only", "datatype": dbt.type_boolean()},
    {"name": "recurrence_day_of_month", "datatype": dbt.type_int()},
    {"name": "recurrence_day_of_week", "datatype": dbt.type_string()},
    {"name": "recurrence_week_of_month", "datatype": dbt.type_int()},
    {"name": "smart_list_id", "datatype": dbt.type_int()},
    {"name": "status", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
