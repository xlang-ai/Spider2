{% macro get_person_name_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "academic_suffix", "datatype": dbt.type_string()},
    {"name": "additional_name_type", "datatype": dbt.type_string()},
    {"name": "country", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "full_name_singapore_malaysia", "datatype": dbt.type_string()},
    {"name": "hereditary_suffix", "datatype": dbt.type_string()},
    {"name": "honorary_suffix", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "local_first_name", "datatype": dbt.type_string()},
    {"name": "local_first_name_2", "datatype": dbt.type_string()},
    {"name": "local_last_name", "datatype": dbt.type_string()},
    {"name": "local_last_name_2", "datatype": dbt.type_string()},
    {"name": "local_middle_name", "datatype": dbt.type_string()},
    {"name": "local_middle_name_2", "datatype": dbt.type_string()},
    {"name": "local_secondary_last_name", "datatype": dbt.type_string()},
    {"name": "local_secondary_last_name_2", "datatype": dbt.type_string()},
    {"name": "middle_name", "datatype": dbt.type_string()},
    {"name": "personal_info_system_id", "datatype": dbt.type_string()},
    {"name": "prefix_salutation", "datatype": dbt.type_string()},
    {"name": "prefix_title", "datatype": dbt.type_string()},
    {"name": "prefix_title_code", "datatype": dbt.type_string()},
    {"name": "professional_suffix", "datatype": dbt.type_string()},
    {"name": "religious_suffix", "datatype": dbt.type_string()},
    {"name": "royal_suffix", "datatype": dbt.type_string()},
    {"name": "secondary_last_name", "datatype": dbt.type_string()},
    {"name": "social_suffix", "datatype": dbt.type_string()},
    {"name": "social_suffix_id", "datatype": dbt.type_string()},
    {"name": "tertiary_last_name", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
