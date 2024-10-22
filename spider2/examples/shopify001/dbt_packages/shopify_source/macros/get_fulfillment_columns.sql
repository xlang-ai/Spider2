{% macro get_fulfillment_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "location_id", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "order_id", "datatype": dbt.type_int()},
    {"name": "service", "datatype": dbt.type_string()},
    {"name": "shipment_status", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "tracking_company", "datatype": dbt.type_string()},
    {"name": "tracking_number", "datatype": dbt.type_string()},
    {"name": "tracking_numbers", "datatype": dbt.type_string()},
    {"name": "tracking_urls", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
