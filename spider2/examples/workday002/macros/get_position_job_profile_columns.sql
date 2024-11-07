{% macro get_position_job_profile_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "difficulty_to_fill_code", "datatype": dbt.type_string()},
    {"name": "is_critical_job", "datatype": dbt.type_boolean()},
    {"name": "job_category_code", "datatype": dbt.type_string()},
    {"name": "job_profile_id", "datatype": dbt.type_string()},
    {"name": "management_level_code", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "position_id", "datatype": dbt.type_string()},
    {"name": "work_shift_required", "datatype": dbt.type_boolean()}
] %}

{{ return(columns) }}

{% endmacro %}
