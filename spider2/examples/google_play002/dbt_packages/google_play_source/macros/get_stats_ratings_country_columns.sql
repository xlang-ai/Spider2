{% macro get_stats_ratings_country_columns() %}

{% set columns = [
    {"name": "_file", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_line", "datatype": dbt.type_int()},
    {"name": "_modified", "datatype": dbt.type_timestamp()},
    {"name": "country", "datatype": dbt.type_string()},
    {"name": "daily_average_rating", "datatype": dbt.type_string()},
    {"name": "date", "datatype": "date"},
    {"name": "package_name", "datatype": dbt.type_string()},
    {"name": "total_average_rating", "datatype": dbt.type_float()}
] %}

{{ return(columns) }}

{% endmacro %}
