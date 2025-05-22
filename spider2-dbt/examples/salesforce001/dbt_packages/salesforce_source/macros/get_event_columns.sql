{% macro get_event_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "activity_date", "datatype": dbt.type_timestamp()},
    {"name": "activity_date_time", "datatype": dbt.type_timestamp()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "end_date", "datatype": dbt.type_timestamp()},
    {"name": "end_date_time", "datatype": dbt.type_timestamp()},
    {"name": "event_subtype", "datatype": dbt.type_string()},
    {"name": "group_event_type", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "is_archived", "datatype": "boolean"},
    {"name": "is_child", "datatype": "boolean"},
    {"name": "is_deleted", "datatype": "boolean"},
    {"name": "is_group_event", "datatype": "boolean"},
    {"name": "is_recurrence", "datatype": "boolean"},
    {"name": "last_modified_by_id", "datatype": dbt.type_string()},
    {"name": "last_modified_date", "datatype": dbt.type_timestamp()},
    {"name": "location", "datatype": dbt.type_string()},
    {"name": "owner_id", "datatype": dbt.type_string()},
    {"name": "start_date_time", "datatype": dbt.type_timestamp()},
    {"name": "subject", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "what_count", "datatype": dbt.type_int()},
    {"name": "what_id", "datatype": dbt.type_string()},
    {"name": "who_count", "datatype": dbt.type_int()},
    {"name": "who_id", "datatype": dbt.type_string()}
] %}

{{ salesforce_source.add_renamed_columns(columns) }}

{{ fivetran_utils.add_pass_through_columns(columns, var('salesforce__event_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
