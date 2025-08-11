{% macro get_product_2_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "display_url", "datatype": dbt.type_string()},
    {"name": "external_id", "datatype": dbt.type_string()},
    {"name": "family", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "is_active", "datatype": "boolean"},
    {"name": "is_archived", "datatype": "boolean"},
    {"name": "is_deleted", "datatype": "boolean"},
    {"name": "last_modified_by_id", "datatype": dbt.type_string()},
    {"name": "last_modified_date", "datatype": dbt.type_timestamp()},
    {"name": "last_referenced_date", "datatype": dbt.type_timestamp()},
    {"name": "last_viewed_date", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "number_of_quantity_installments", "datatype": dbt.type_int()},
    {"name": "number_of_revenue_installments", "datatype": dbt.type_int()},
    {"name": "product_code", "datatype": dbt.type_string()},
    {"name": "quantity_installment_period", "datatype": dbt.type_string()},
    {"name": "quantity_schedule_type", "datatype": dbt.type_string()},
    {"name": "quantity_unit_of_measure", "datatype": dbt.type_string()},
    {"name": "record_type_id", "datatype": dbt.type_string()},
    {"name": "revenue_installment_period", "datatype": dbt.type_string()},
    {"name": "revenue_schedule_type", "datatype": dbt.type_string()},
] %}

{{ salesforce_source.add_renamed_columns(columns) }}

{{ fivetran_utils.add_pass_through_columns(columns, var('salesforce__product_2_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
