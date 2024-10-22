{% macro get_stats_store_performance_country_columns() %}

{% set columns = [
    {"name": "_file", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_line", "datatype": dbt.type_int()},
    {"name": "_modified", "datatype": dbt.type_timestamp()},
    {"name": "country_region", "datatype": dbt.type_string()},
    {"name": "date", "datatype": "date"},
    {"name": "package_name", "datatype": dbt.type_string()},
    {"name": "store_listing_acquisitions", "datatype": dbt.type_int()},
    {"name": "store_listing_conversion_rate", "datatype": dbt.type_float()},
    {"name": "store_listing_visitors", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
