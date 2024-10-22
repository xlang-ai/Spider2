{% macro get_incoming_phone_number_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "address_id", "datatype": dbt.type_string()},
    {"name": "address_requirements", "datatype": dbt.type_string()},
    {"name": "beta", "datatype": "boolean"},
    {"name": "capabilities_mms", "datatype": "boolean"},
    {"name": "capabilities_sms", "datatype": "boolean"},
    {"name": "capabilities_voice", "datatype": "boolean"},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "emergency_address_id", "datatype": dbt.type_string()},
    {"name": "emergency_status", "datatype": dbt.type_string()},
    {"name": "friendly_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "origin", "datatype": dbt.type_string()},
    {"name": "phone_number", "datatype": dbt.type_string()},
    {"name": "trunk_id", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "voice_caller_id_lookup", "datatype": "boolean"},
    {"name": "voice_url", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
