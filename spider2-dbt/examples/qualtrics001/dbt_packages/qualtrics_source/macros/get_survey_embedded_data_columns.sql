{% macro get_survey_embedded_data_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "import_id", "datatype": dbt.type_string()},
    {"name": "key", "datatype": dbt.type_string()},
    {"name": "response_id", "datatype": dbt.type_string()},
    {"name": "value", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
