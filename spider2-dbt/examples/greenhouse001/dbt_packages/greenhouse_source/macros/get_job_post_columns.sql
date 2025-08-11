{% macro get_job_post_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "content", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "external", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "internal", "datatype": "boolean"},
    {"name": "internal_content", "datatype": dbt.type_string()},
    {"name": "job_id", "datatype": dbt.type_int()},
    {"name": "live", "datatype": "boolean"},
    {"name": "location_name", "datatype": dbt.type_string()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
