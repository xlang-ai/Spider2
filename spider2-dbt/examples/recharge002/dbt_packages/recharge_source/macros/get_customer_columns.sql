
{% macro get_customer_columns() %}

{% set columns = [
    {"name": "id", "datatype": dbt.type_int()},
    {"name": "external_customer_id_ecommerce", "datatype": dbt.type_int()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "first_charge_processed_at", "datatype": dbt.type_timestamp()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "subscriptions_active_count", "datatype": dbt.type_int()},
    {"name": "subscriptions_total_count", "datatype": dbt.type_int()},
    {"name": "has_valid_payment_method", "datatype": dbt.type_boolean()},
    {"name": "has_payment_method_in_dunning", "datatype": dbt.type_boolean()},
    {"name": "tax_exempt", "datatype": dbt.type_boolean()},
    {"name": "_fivetran_deleted", "datatype": dbt.type_boolean()},
    {"name": "billing_first_name", "datatype": dbt.type_string()},
    {"name": "billing_last_name", "datatype": dbt.type_string()},
    {"name": "billing_company", "datatype": dbt.type_string()},
    {"name": "billing_city", "datatype": dbt.type_string()},
    {"name": "billing_country", "datatype": dbt.type_string()}
] %}

{% if target.type == 'bigquery' %}
{{ columns.append( {"name": "hash", "datatype": dbt.type_string(), "alias": "customer_hash", "quote": true} ) }}
{% else %}
{{ columns.append( {"name": "hash", "alias": "customer_hash", "datatype": dbt.type_string()} ) }}
{% endif %} ,

{{ return(columns) }}

{% endmacro %}