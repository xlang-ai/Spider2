{% macro get_comment_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "author_id", "datatype": dbt.type_string()},
    {"name": "body", "datatype": dbt.type_string()},
    {"name": "created", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "is_public", "datatype": "boolean"},
    {"name": "issue_id", "datatype": dbt.type_int()},
    {"name": "update_author_id", "datatype": dbt.type_string()},
    {"name": "updated", "datatype": dbt.type_timestamp()}
] %}

{{ return(columns) }}

{% endmacro %}
