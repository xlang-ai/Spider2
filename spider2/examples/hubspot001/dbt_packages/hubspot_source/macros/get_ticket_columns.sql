{% macro get_ticket_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int(), "alias": "ticket_id"},
    {"name": "_fivetran_deleted", "datatype": "boolean", "alias": "_fivetran_ticket_deleted"},
    {"name": "is_deleted", "datatype": "boolean", "alias": "is_ticket_deleted"},
    {"name": "property_closed_date", "datatype": dbt.type_timestamp(), "alias": "closed_date"},
    {"name": "property_createdate", "datatype": dbt.type_timestamp(), "alias": "created_date"},
    {"name": "property_first_agent_reply_date", "datatype": dbt.type_timestamp(), "alias": "first_agent_reply_at"},
    {"name": "property_hs_pipeline", "datatype": dbt.type_string(), "alias": "ticket_pipeline_id"},
    {"name": "property_hs_pipeline_stage", "datatype": dbt.type_string(), "alias": "ticket_pipeline_stage_id"},
    {"name": "property_hs_ticket_category", "datatype": dbt.type_string(), "alias": "ticket_category"},
    {"name": "property_hs_ticket_priority", "datatype": dbt.type_string(), "alias": "ticket_priority"},
    {"name": "property_hubspot_owner_id", "datatype": dbt.type_int(), "alias": "owner_id"},
    {"name": "property_subject", "datatype": dbt.type_string(), "alias": "ticket_subject"},
    {"name": "property_content", "datatype": dbt.type_string(), "alias": "ticket_content"}  
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('hubspot__ticket_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}