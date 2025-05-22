{% macro get_posting_interview_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "interview_id", "datatype": dbt.type_string()},
    {"name": "posting_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
