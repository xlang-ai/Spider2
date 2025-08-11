{% macro get_inventory_level_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "available", "datatype": dbt.type_int()},
    {"name": "inventory_item_id", "datatype": dbt.type_int()},
    {"name": "location_id", "datatype": dbt.type_int()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
