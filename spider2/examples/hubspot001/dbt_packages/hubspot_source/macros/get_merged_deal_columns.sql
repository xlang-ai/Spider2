{% macro get_merged_deal_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "deal_id", "datatype": dbt.type_int()},
    {"name": "merged_deal_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
