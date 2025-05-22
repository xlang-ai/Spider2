{% macro get_attachment_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "candidate_id", "datatype": dbt.type_int()},
    {"name": "filename", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "url", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
