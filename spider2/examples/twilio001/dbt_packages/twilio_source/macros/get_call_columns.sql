{% macro get_call_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "annotation", "datatype": dbt.type_string()},
    {"name": "answered_by", "datatype": dbt.type_string()},
    {"name": "caller_name", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "direction", "datatype": dbt.type_string()},
    {"name": "duration", "datatype": dbt.type_string()},
    {"name": "end_time", "datatype": dbt.type_timestamp()},
    {"name": "forwarded_from", "datatype": dbt.type_string()},
    {"name": "from_formatted", "datatype": dbt.type_string()},
    {"name": "group_id", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "outgoing_caller_id", "datatype": dbt.type_string()},
    {"name": "parent_call_id", "datatype": dbt.type_string()},
    {"name": "price", "datatype": dbt.type_string()},
    {"name": "price_unit", "datatype": dbt.type_string()},
    {"name": "queue_time", "datatype": dbt.type_string()},
    {"name": "start_time", "datatype": dbt.type_timestamp()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "to_formatted", "datatype": dbt.type_string()},
    {"name": "trunk_id", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
] %}

{% if target.type == 'snowflake' %}
    {{ columns.append({"name": "FROM", "datatype": dbt.type_string(), "quote": True, "alias": "call_from"}) }}
    {{ columns.append({"name": "TO", "datatype": dbt.type_string(), "quote": True, "alias": "call_to"}) }}
    {% else %}
    {{ columns.append({"name": "from", "datatype": dbt.type_string(), "quote": True, "alias": "call_from"}) }}
    {{ columns.append({"name": "to", "datatype": dbt.type_string(), "quote": True, "alias": "call_to"}) }}
{% endif %}

{{ return(columns) }}

{% endmacro %}