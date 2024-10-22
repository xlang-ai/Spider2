{% macro get_story_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "hearted", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "num_hearts", "datatype": dbt.type_int()},
    {"name": "source", "datatype": dbt.type_string()},
    {"name": "target_id", "datatype": dbt.type_string()},
    {"name": "text", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
