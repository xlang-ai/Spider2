{% macro get_question_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "data_export_tag", "datatype": dbt.type_string()},
    {"name": "data_visibility_hidden", "datatype": "boolean"},
    {"name": "data_visibility_private", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "next_answer_id", "datatype": dbt.type_int()},
    {"name": "next_choice_id", "datatype": dbt.type_int()},
    {"name": "question_description", "datatype": dbt.type_string()},
    {"name": "question_description_option", "datatype": dbt.type_string()},
    {"name": "question_text", "datatype": dbt.type_string()},
    {"name": "question_text_unsafe", "datatype": dbt.type_string()},
    {"name": "question_type", "datatype": dbt.type_string()},
    {"name": "selector", "datatype": dbt.type_string()},
    {"name": "sub_selector", "datatype": dbt.type_string()},
    {"name": "survey_id", "datatype": dbt.type_string()},
    {"name": "validation_setting_force_response", "datatype": dbt.type_string()},
    {"name": "validation_setting_force_response_type", "datatype": dbt.type_string()},
    {"name": "validation_setting_type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
