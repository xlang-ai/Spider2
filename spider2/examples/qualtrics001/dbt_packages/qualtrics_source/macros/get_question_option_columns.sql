{% macro get_question_option_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "key", "datatype": dbt.type_string()},
    {"name": "question_id", "datatype": dbt.type_string()},
    {"name": "recode_value", "datatype": dbt.type_string()},
    {"name": "survey_id", "datatype": dbt.type_string()},
    {"name": "text", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
