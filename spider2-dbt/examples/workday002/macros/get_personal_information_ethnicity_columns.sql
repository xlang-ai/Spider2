{% macro get_personal_information_ethnicity_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "ethnicity_code", "datatype": dbt.type_string()},
    {"name": "ethnicity_id", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "personal_info_system_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
