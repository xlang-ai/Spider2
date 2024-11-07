{% macro get_scorecard_attribute_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "note", "datatype": dbt.type_string()},
    {"name": "rating", "datatype": dbt.type_string()},
    {"name": "scorecard_id", "datatype": dbt.type_int()},
    {"name": "type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
