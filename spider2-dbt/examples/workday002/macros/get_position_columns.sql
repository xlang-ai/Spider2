{% macro get_position_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "academic_tenure_eligible", "datatype": dbt.type_boolean()},
    {"name": "availability_date", "datatype": "date"},
    {"name": "available_for_hire", "datatype": dbt.type_boolean()},
    {"name": "available_for_overlap", "datatype": dbt.type_boolean()},
    {"name": "available_for_recruiting", "datatype": dbt.type_boolean()},
    {"name": "closed", "datatype": dbt.type_boolean()},
    {"name": "compensation_grade_code", "datatype": dbt.type_string()},
    {"name": "compensation_grade_profile_code", "datatype": dbt.type_string()},
    {"name": "compensation_package_code", "datatype": dbt.type_string()},
    {"name": "compensation_step_code", "datatype": dbt.type_string()},
    {"name": "critical_job", "datatype": dbt.type_boolean()},
    {"name": "difficulty_to_fill_code", "datatype": dbt.type_string()},
    {"name": "earliest_hire_date", "datatype": "date"},
    {"name": "earliest_overlap_date", "datatype": "date"},
    {"name": "effective_date", "datatype": "date"},
    {"name": "hiring_freeze", "datatype": dbt.type_boolean()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "job_description", "datatype": dbt.type_string()},
    {"name": "job_description_summary", "datatype": dbt.type_string()},
    {"name": "job_posting_title", "datatype": dbt.type_string()},
    {"name": "position_code", "datatype": dbt.type_string()},
    {"name": "position_time_type_code", "datatype": dbt.type_string()},
    {"name": "primary_compensation_basis", "datatype": dbt.type_float()},
    {"name": "primary_compensation_basis_amount_change", "datatype": dbt.type_float()},
    {"name": "primary_compensation_basis_percent_change", "datatype": dbt.type_float()},
    {"name": "supervisory_organization_id", "datatype": dbt.type_string()},
    {"name": "work_shift_required", "datatype": dbt.type_boolean()},
    {"name": "worker_for_filled_position_id", "datatype": dbt.type_string()},
    {"name": "worker_position_id", "datatype": dbt.type_string()},
    {"name": "worker_type_code", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
