{% macro get_activity_email_bounced_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "activity_date", "datatype": dbt.type_timestamp()},
    {"name": "activity_type_id", "datatype": dbt.type_int()},
    {"name": "campaign_id", "datatype": dbt.type_int()},
    {"name": "campaign_run_id", "datatype": dbt.type_int()},
    {"name": "category", "datatype": dbt.type_int()},
    {"name": "choice_number", "datatype": dbt.type_int()},
    {"name": "details", "datatype": dbt.type_string()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "email_template_id", "datatype": dbt.type_int()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "lead_id", "datatype": dbt.type_int()},
    {"name": "primary_attribute_value", "datatype": dbt.type_string()},
    {"name": "primary_attribute_value_id", "datatype": dbt.type_int()},
    {"name": "step_id", "datatype": dbt.type_int()},
    {"name": "subcategory", "datatype": dbt.type_int()},
    {"name": "test_variant", "datatype": dbt.type_int()}
] %}

{{ return(columns) }}

{% endmacro %}
