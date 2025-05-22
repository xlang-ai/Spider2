{% macro get_posting_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "categories_commitment", "datatype": dbt.type_string()},
    {"name": "categories_department", "datatype": dbt.type_string()},
    {"name": "categories_level", "datatype": dbt.type_string()},
    {"name": "categories_location", "datatype": dbt.type_string()},
    {"name": "categories_team", "datatype": dbt.type_string()},
    {"name": "content_closing", "datatype": dbt.type_string()},
    {"name": "content_closing_html", "datatype": dbt.type_string()},
    {"name": "content_description", "datatype": dbt.type_string()},
    {"name": "content_description_html", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "creator_id", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "owner_id", "datatype": dbt.type_string()},
    {"name": "requisition_code", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "text", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
