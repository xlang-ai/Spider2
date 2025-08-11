{% macro get_message_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "body", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "date_sent", "datatype": dbt.type_timestamp()},
    {"name": "direction", "datatype": dbt.type_string()},
    {"name": "error_code", "datatype": dbt.type_string()},
    {"name": "error_message", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "messaging_service_sid", "datatype": dbt.type_string()},
    {"name": "num_media", "datatype": dbt.type_string()},
    {"name": "num_segments", "datatype": dbt.type_string()},
    {"name": "price", "datatype": dbt.type_string()},
    {"name": "price_unit", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
] %}

{% if target.type == 'snowflake' %}
    {{ columns.append({"name": "FROM", "datatype": dbt.type_string(), "quote": True, "alias": "message_from"}) }}
    {{ columns.append({"name": "TO", "datatype": dbt.type_string(), "quote": True, "alias": "message_to"}) }}
{% else %}
    {{ columns.append({"name": "from", "datatype": dbt.type_string(), "quote": True, "alias": "message_from"}) }}
    {{ columns.append({"name": "to", "datatype": dbt.type_string(), "quote": True, "alias": "message_to"}) }}
{% endif %}

{{ return(columns) }}

{% endmacro %}