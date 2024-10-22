{% macro get_property_option_columns() %}

{% set columns = [
    {"name": "label", "datatype": dbt.type_string()},
    {"name": "property_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "display_order", "datatype": dbt.type_int()},
    {"name": "hidden", "datatype": dbt.type_boolean()},
    {"name": "value", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}