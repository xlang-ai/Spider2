{% macro get_feedback_form_field_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "code_language", "datatype": dbt.type_string()},
    {"name": "currency", "datatype": dbt.type_string()},
    {"name": "feedback_form_id", "datatype": dbt.type_string()},
    {"name": "field_index", "datatype": dbt.type_int()},
    {"name": "value_date", "datatype": dbt.type_timestamp()},
    {"name": "value_decimal", "datatype": dbt.type_numeric()},
    {"name": "value_file_id", "datatype": dbt.type_string()},
    {"name": "value_index", "datatype": dbt.type_int()},
    {"name": "value_number", "datatype": dbt.type_int()},
    {"name": "value_text", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
