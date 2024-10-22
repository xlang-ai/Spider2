{% macro get_usage_record_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_id", "datatype": dbt.type_string()},
    {"name": "as_of", "datatype": dbt.type_timestamp()},
    {"name": "category", "datatype": dbt.type_string()},
    {"name": "count", "datatype": dbt.type_string()},
    {"name": "count_unit", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "end_date", "datatype": "date"},
    {"name": "price", "datatype": dbt.type_string()},
    {"name": "price_unit", "datatype": dbt.type_string()},
    {"name": "start_date", "datatype": "date"},
    {"name": "usage", "datatype": dbt.type_string()},
    {"name": "usage_unit", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
