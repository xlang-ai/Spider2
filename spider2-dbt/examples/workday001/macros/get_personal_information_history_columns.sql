{% macro get_personal_information_history_columns() %}

{% set columns = [
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "additional_nationality", "datatype": dbt.type_string()},
    {"name": "blood_type", "datatype": dbt.type_string()},
    {"name": "citizenship_status", "datatype": dbt.type_string()},
    {"name": "city_of_birth", "datatype": dbt.type_string()},
    {"name": "city_of_birth_code", "datatype": dbt.type_string()},
    {"name": "country_of_birth", "datatype": dbt.type_string()},
    {"name": "date_of_birth", "datatype": "date"},
    {"name": "date_of_death", "datatype": "date"},
    {"name": "gender", "datatype": dbt.type_string()},
    {"name": "hispanic_or_latino", "datatype": dbt.type_boolean()},
    {"name": "hukou_locality", "datatype": dbt.type_string()},
    {"name": "hukou_postal_code", "datatype": dbt.type_string()},
    {"name": "hukou_region", "datatype": dbt.type_string()},
    {"name": "hukou_subregion", "datatype": dbt.type_string()},
    {"name": "hukou_type", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_medical_exam_date", "datatype": "date"},
    {"name": "last_medical_exam_valid_to", "datatype": "date"},
    {"name": "local_hukou", "datatype": dbt.type_boolean()},
    {"name": "marital_status", "datatype": dbt.type_string()},
    {"name": "marital_status_date", "datatype": "date"},
    {"name": "medical_exam_notes", "datatype": dbt.type_string()},
    {"name": "native_region", "datatype": dbt.type_string()},
    {"name": "native_region_code", "datatype": dbt.type_string()},
    {"name": "personnel_file_agency", "datatype": dbt.type_string()},
    {"name": "political_affiliation", "datatype": dbt.type_string()},
    {"name": "primary_nationality", "datatype": dbt.type_string()},
    {"name": "region_of_birth", "datatype": dbt.type_string()},
    {"name": "region_of_birth_code", "datatype": dbt.type_string()},
    {"name": "religion", "datatype": dbt.type_string()},
    {"name": "social_benefit", "datatype": dbt.type_string()},
    {"name": "tobacco_use", "datatype": dbt.type_boolean()},
    {"name": "type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
