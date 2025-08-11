
{% macro get_charge_tax_line_columns() %}

{% set columns = [
    {"name": "charge_id", "datatype": dbt.type_int()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "price", "datatype": dbt.type_float()},
    {"name": "rate", "datatype": dbt.type_float()},
    {"name": "title", "datatype": dbt.type_string()}

] %}

{{ return(columns) }}

{% endmacro %}