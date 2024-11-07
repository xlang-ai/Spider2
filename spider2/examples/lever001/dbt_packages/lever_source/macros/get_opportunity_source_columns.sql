{% macro get_opportunity_source_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "opportunity_id", "datatype": dbt.type_string()},
    {"name": "source", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
