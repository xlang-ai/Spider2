{% macro get_engagement_task_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "engagement_id", "datatype": dbt.type_int()},
    {"name": "type", "datatype": dbt.type_string(), "alias": "engagement_type"},
    {"name": "property_hs_createdate", "datatype": dbt.type_timestamp(), "alias": "created_timestamp"},
    {"name": "property_hs_timestamp", "datatype": dbt.type_timestamp(), "alias": "occurred_timestamp"},
    {"name": "property_hubspot_owner_id", "datatype": dbt.type_int(), "alias": "owner_id"},
    {"name": "property_hubspot_team_id", "datatype": dbt.type_int(), "alias": "team_id"}
] %}

{{ return(columns) }}

{% endmacro %}
