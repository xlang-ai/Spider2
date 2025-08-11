{% macro get_survey_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "auto_scoring_category", "datatype": dbt.type_string()},
    {"name": "brand_base_url", "datatype": dbt.type_string()},
    {"name": "brand_id", "datatype": dbt.type_string()},
    {"name": "bundle_short_name", "datatype": dbt.type_string()},
    {"name": "composition_type", "datatype": dbt.type_string()},
    {"name": "creator_id", "datatype": dbt.type_string()},
    {"name": "default_scoring_category", "datatype": dbt.type_string()},
    {"name": "division_id", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_accessed", "datatype": dbt.type_timestamp()},
    {"name": "last_activated", "datatype": dbt.type_timestamp()},
    {"name": "last_modified", "datatype": dbt.type_timestamp()},
    {"name": "owner_id", "datatype": dbt.type_string()},
    {"name": "project_category", "datatype": dbt.type_string()},
    {"name": "project_type", "datatype": dbt.type_string()},
    {"name": "registry_sha", "datatype": dbt.type_string()},
    {"name": "registry_version", "datatype": dbt.type_string()},
    {"name": "schema_version", "datatype": dbt.type_string()},
    {"name": "scoring_summary_after_questions", "datatype": "boolean"},
    {"name": "scoring_summary_after_survey", "datatype": "boolean"},
    {"name": "scoring_summary_category", "datatype": dbt.type_string()},
    {"name": "survey_name", "datatype": dbt.type_string()},
    {"name": "survey_status", "datatype": dbt.type_string()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('qualtrics__survey_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
