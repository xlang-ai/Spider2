{% macro get_eeoc_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "application_id", "datatype": dbt.type_int()},
    {"name": "disability_status_description", "datatype": dbt.type_string()},
    {"name": "disability_status_id", "datatype": dbt.type_int()},
    {"name": "gender_description", "datatype": dbt.type_string()},
    {"name": "gender_id", "datatype": dbt.type_int()},
    {"name": "race_description", "datatype": dbt.type_string()},
    {"name": "race_id", "datatype": dbt.type_int()},
    {"name": "submitted_at", "datatype": dbt.type_timestamp()},
    {"name": "veteran_status_description", "datatype": dbt.type_string()},
    {"name": "veteran_status_id", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
