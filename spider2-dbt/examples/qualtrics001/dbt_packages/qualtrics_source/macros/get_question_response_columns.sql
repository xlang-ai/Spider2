{% macro get_question_response_columns() %}

{% set columns = [
    {"name": "_fivetran_id", "datatype": dbt.type_string()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "loop_id", "datatype": dbt.type_string()},
    {"name": "question", "datatype": dbt.type_string()},
    {"name": "question_id", "datatype": dbt.type_string()},
    {"name": "question_option_key", "datatype": dbt.type_string()},
    {"name": "response_id", "datatype": dbt.type_string()},
    {"name": "sub_question_key", "datatype": dbt.type_string()},
    {"name": "sub_question_text", "datatype": dbt.type_string()},
    {"name": "value", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
