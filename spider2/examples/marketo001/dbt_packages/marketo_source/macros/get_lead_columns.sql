{% macro get_lead_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp(), "alias": "created_timestamp"},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int(), "alias": "lead_id"},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp(), "alias": "updated_timestamp"},
    {"name": "phone", "datatype": dbt.type_string()},
    {"name": "main_phone", "datatype": dbt.type_string()},
    {"name": "mobile_phone", "datatype": dbt.type_string()},
    {"name": "company", "datatype": dbt.type_string()},
    {"name": "inferred_company", "datatype": dbt.type_string()},
    {"name": "address_lead", "datatype": dbt.type_string()},
    {"name": "address", "datatype": dbt.type_string()},
    {"name": "city", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "state_code", "datatype": dbt.type_string()},
    {"name": "country", "datatype": dbt.type_string()},
    {"name": "country_code", "datatype": dbt.type_string()},
    {"name": "postal_code", "datatype": dbt.type_string()},
    {"name": "billing_street", "datatype": dbt.type_string()},
    {"name": "billing_city", "datatype": dbt.type_string()},
    {"name": "billing_state", "datatype": dbt.type_string()},
    {"name": "billing_state_code", "datatype": dbt.type_string()},
    {"name": "billing_country", "datatype": dbt.type_string()},
    {"name": "billing_country_code", "datatype": dbt.type_string()},
    {"name": "billing_postal_code", "datatype": dbt.type_string()},
    {"name": "inferred_city", "datatype": dbt.type_string()},
    {"name": "inferred_state_region", "datatype": dbt.type_string()},
    {"name": "inferred_country", "datatype": dbt.type_string()},
    {"name": "inferred_postal_code", "datatype": dbt.type_string()},
    {"name": "inferred_phone_area_code", "datatype": dbt.type_string()},
    {"name": "anonymous_ip", "datatype": dbt.type_string()},
    {"name": "unsubscribed", "datatype": dbt.type_boolean(), "alias": "is_unsubscribed"},
    {"name": "email_invalid", "datatype": dbt.type_boolean(), "alias": "is_email_invalid"},
    {"name": "do_not_call", "datatype": dbt.type_boolean()}
] %}

{{ return(columns) }}

{% endmacro %}