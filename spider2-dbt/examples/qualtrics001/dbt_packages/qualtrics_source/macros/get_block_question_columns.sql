{% macro get_block_question_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "block_id", "datatype": dbt.type_string()},
    {"name": "question_id", "datatype": dbt.type_string()},
    {"name": "survey_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
