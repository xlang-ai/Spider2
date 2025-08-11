{% macro get_survey_version_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "creation_date", "datatype": dbt.type_timestamp()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "published", "datatype": "boolean"},
    {"name": "survey_id", "datatype": dbt.type_string()},
    {"name": "user_id", "datatype": dbt.type_string()},
    {"name": "version_number", "datatype": dbt.type_int()},
    {"name": "was_published", "datatype": "boolean"}
] %}

{{ return(columns) }}

{% endmacro %}
