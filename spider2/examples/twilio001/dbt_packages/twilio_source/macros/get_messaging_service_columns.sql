{% macro get_messaging_service_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "area_code_geomatch", "datatype": "boolean"},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "fallback_method", "datatype": dbt.type_string()},
    {"name": "fallback_to_long_code", "datatype": "boolean"},
    {"name": "fallback_url", "datatype": dbt.type_string()},
    {"name": "friendly_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "inbound_method", "datatype": dbt.type_string()},
    {"name": "inbound_request_url", "datatype": dbt.type_string()},
    {"name": "mms_converter", "datatype": "boolean"},
    {"name": "scan_message_content", "datatype": dbt.type_string()},
    {"name": "smart_encoding", "datatype": "boolean"},
    {"name": "status_callback", "datatype": dbt.type_string()},
    {"name": "sticky_sender", "datatype": "boolean"},
    {"name": "synchronous_validation", "datatype": "boolean"},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "us_app_to_person_registered", "datatype": "boolean"},
    {"name": "use_inbound_webhook_on_number", "datatype": "boolean"},
    {"name": "usecase", "datatype": dbt.type_string()},
    {"name": "validity_period", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
