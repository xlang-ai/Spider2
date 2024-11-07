{% macro get_organization_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "availability_date", "datatype": dbt.type_timestamp()},
    {"name": "available_for_hire", "datatype": dbt.type_boolean()},
    {"name": "code", "datatype": dbt.type_string()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "external_url", "datatype": dbt.type_string()},
    {"name": "hiring_freeze", "datatype": dbt.type_boolean()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "inactive", "datatype": dbt.type_boolean()},
    {"name": "inactive_date", "datatype": "date"},
    {"name": "include_manager_in_name", "datatype": dbt.type_boolean()},
    {"name": "include_organization_code_in_name", "datatype": dbt.type_boolean()},
    {"name": "last_updated_date_time", "datatype": dbt.type_timestamp()},
    {"name": "location", "datatype": dbt.type_string()},
    {"name": "manager_id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "organization_code", "datatype": dbt.type_string()},
    {"name": "organization_owner_id", "datatype": dbt.type_string()},
    {"name": "staffing_model", "datatype": dbt.type_string()},
    {"name": "sub_type", "datatype": dbt.type_string()},
    {"name": "superior_organization_id", "datatype": dbt.type_string()},
    {"name": "supervisory_position_availability_date", "datatype": "date"},
    {"name": "supervisory_position_earliest_hire_date", "datatype": "date"},
    {"name": "supervisory_position_time_type", "datatype": dbt.type_string()},
    {"name": "supervisory_position_worker_type", "datatype": dbt.type_string()},
    {"name": "top_level_organization_id", "datatype": dbt.type_string()},
    {"name": "type", "datatype": dbt.type_string()},
    {"name": "visibility", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
