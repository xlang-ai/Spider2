{% macro get_directory_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "deduplication_criteria_email", "datatype": "boolean"},
    {"name": "deduplication_criteria_external_data_reference", "datatype": "boolean"},
    {"name": "deduplication_criteria_first_name", "datatype": "boolean"},
    {"name": "deduplication_criteria_last_name", "datatype": "boolean"},
    {"name": "deduplication_criteria_phone", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "is_default", "datatype": "boolean"},
    {"name": "name", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('qualtrics__directory_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
