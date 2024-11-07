{% macro get_lead_describe_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "data_type", "datatype": dbt.type_string()},
    {"name": "display_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "length", "datatype": dbt.type_int()},
    {"name": "restname", "datatype": dbt.type_string()},
    {"name": "restread_only", "datatype": "boolean"},
    {"name": "soapname", "datatype": dbt.type_string()},
    {"name": "soapread_only", "datatype": "boolean"}
] %}

{{ return(columns) }}

{% endmacro %}
