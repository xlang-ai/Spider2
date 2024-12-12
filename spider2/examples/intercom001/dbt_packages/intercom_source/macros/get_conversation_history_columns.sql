{% macro get_conversation_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_active", "datatype": "boolean"},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "assignee_id", "datatype": dbt.type_int()},
    {"name": "assignee_type", "datatype": dbt.type_string()},
    {"name": "conversation_rating_remark", "datatype": dbt.type_int()},
    {"name": "conversation_rating_value", "datatype": dbt.type_int()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "first_contact_reply_created_at", "datatype": dbt.type_timestamp()},
    {"name": "first_contact_reply_type", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "read", "datatype": "boolean"},
    {"name": "sla_name", "datatype": dbt.type_int()},
    {"name": "sla_status", "datatype": dbt.type_int()},
    {"name": "snoozed_until", "datatype": dbt.type_timestamp()},
    {"name": "source_author_id", "datatype": dbt.type_string()},
    {"name": "source_author_type", "datatype": dbt.type_string()},
    {"name": "source_body", "datatype": dbt.type_string()},
    {"name": "source_delivered_as", "datatype": dbt.type_string()},
    {"name": "source_subject", "datatype": dbt.type_string()},
    {"name": "source_type", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "waiting_since", "datatype": dbt.type_timestamp()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('intercom__conversation_history_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
