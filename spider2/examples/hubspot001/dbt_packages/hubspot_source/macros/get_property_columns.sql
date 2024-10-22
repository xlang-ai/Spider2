{% macro get_property_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "calculated", "datatype": dbt.type_boolean()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "field_type", "datatype": dbt.type_string()},
    {"name": "group_name", "datatype": dbt.type_string()},
    {"name": "hubspot_defined", "datatype": dbt.type_boolean()},
    {"name": "hubspot_object", "datatype": dbt.type_string()},
    {"name": "label", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "show_currency_symbol", "datatype": dbt.type_boolean()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}