{% macro get_deal_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "deal_id", "datatype": dbt.type_int()},
    {"name": "deal_pipeline_id", "datatype": dbt.type_string()},
    {"name": "deal_pipeline_stage_id", "datatype": dbt.type_string()},
    {"name": "is_deleted", "datatype": "boolean", "alias": "is_deal_deleted"},
    {"name": "owner_id", "datatype": dbt.type_int()},
    {"name": "portal_id", "datatype": dbt.type_int()},
    {"name": "property_dealname", "datatype": dbt.type_string(), "alias": "deal_name"},
    {"name": "property_description", "datatype": dbt.type_string(), "alias": "description"},
    {"name": "property_amount", "datatype": dbt.type_int(), "alias": "amount"},
    {"name": "property_closedate", "datatype": dbt.type_timestamp(), "alias": "closed_date"},
    {"name": "property_createdate", "datatype": dbt.type_timestamp(), "alias": "created_date"}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('hubspot__deal_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}