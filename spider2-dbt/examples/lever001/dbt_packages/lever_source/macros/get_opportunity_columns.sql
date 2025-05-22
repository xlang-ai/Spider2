{% macro get_opportunity_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "archived_at", "datatype": dbt.type_timestamp()},
    {"name": "archived_reason_id", "datatype": dbt.type_string()},
    {"name": "contact", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "data_protection_contact_allowed", "datatype": "boolean"},
    {"name": "data_protection_contact_expires_at", "datatype": dbt.type_timestamp()},
    {"name": "data_protection_store_allowed", "datatype": "boolean"},
    {"name": "data_protection_store_expires_at", "datatype": dbt.type_timestamp()},
    {"name": "headline", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "is_anonymized", "datatype": "boolean"},
    {"name": "last_advanced_at", "datatype": dbt.type_timestamp()},
    {"name": "last_interaction_at", "datatype": dbt.type_timestamp()},
    {"name": "location", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "origin", "datatype": dbt.type_string()},
    {"name": "owner_id", "datatype": dbt.type_string()},
    {"name": "snoozed_until", "datatype": dbt.type_timestamp()},
    {"name": "stage_id", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
