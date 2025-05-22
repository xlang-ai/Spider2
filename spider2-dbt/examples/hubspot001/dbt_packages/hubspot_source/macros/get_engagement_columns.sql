{% macro get_engagement_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "active", "datatype": "boolean", "alias": "is_active"},
    {"name": "created_at", "datatype": dbt.type_timestamp(), "alias": "created_timestamp"},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "owner_id", "datatype": dbt.type_int()},
    {"name": "portal_id", "datatype": dbt.type_int()},
    {"name": "timestamp", "datatype": dbt.type_timestamp(), "alias": "occurred_timestamp"},
    {"name": "type", "datatype": dbt.type_string(), "alias": "engagement_type"}
] %}

{{ return(columns) }}

{% endmacro %}
