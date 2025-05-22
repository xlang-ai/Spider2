{% macro get_resume_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "file_download_url", "datatype": dbt.type_string()},
    {"name": "file_ext", "datatype": dbt.type_string()},
    {"name": "file_name", "datatype": dbt.type_string()},
    {"name": "file_uploaded_at", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "opportunity_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
