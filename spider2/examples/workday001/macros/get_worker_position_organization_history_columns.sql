{% macro get_worker_position_organization_history_columns() %}

{% set columns = [
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "index", "datatype": dbt.type_int()},
    {"name": "position_id", "datatype": dbt.type_string()},
    {"name": "worker_id", "datatype": dbt.type_string()},
    {"name": "date_of_pay_group_assignment", "datatype": "date"},
    {"name": "organization_id", "datatype": dbt.type_string()},
    {"name": "primary_business_site", "datatype": dbt.type_string()},
    {"name": "used_in_change_organization_assignments", "datatype": dbt.type_boolean()},
] %}

{{ return(columns) }}

{% endmacro %}
