{% macro get_requisition_offer_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "offer_id", "datatype": dbt.type_string()},
    {"name": "requisition_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
