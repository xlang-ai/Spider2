{% macro get_job_profile_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "additional_job_description", "datatype": dbt.type_string()},
    {"name": "compensation_grade_id", "datatype": dbt.type_string()},
    {"name": "critical_job", "datatype": dbt.type_boolean()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "difficulty_to_fill", "datatype": dbt.type_string()},
    {"name": "effective_date", "datatype": "date"},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "inactive", "datatype": dbt.type_boolean()},
    {"name": "include_job_code_in_name", "datatype": dbt.type_boolean()},
    {"name": "job_category_id", "datatype": dbt.type_string()},
    {"name": "job_profile_code", "datatype": dbt.type_string()},
    {"name": "level", "datatype": dbt.type_string()},
    {"name": "management_level", "datatype": dbt.type_string()},
    {"name": "private_title", "datatype": dbt.type_string()},
    {"name": "public_job", "datatype": dbt.type_boolean()},
    {"name": "referral_payment_plan", "datatype": dbt.type_string()},
    {"name": "summary", "datatype": dbt.type_string()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "union_code", "datatype": dbt.type_string()},
    {"name": "union_membership_requirement", "datatype": dbt.type_string()},
    {"name": "work_shift_required", "datatype": dbt.type_boolean()},
    {"name": "work_study_award_source_code", "datatype": dbt.type_string()},
    {"name": "work_study_requirement_option_code", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
