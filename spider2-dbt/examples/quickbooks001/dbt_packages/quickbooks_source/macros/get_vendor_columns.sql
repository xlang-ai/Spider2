{% macro get_vendor_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "account_number", "datatype": dbt.type_string()},
    {"name": "active", "datatype": "boolean"},
    {"name": "alternate_phone", "datatype": dbt.type_string()},
    {"name": "balance", "datatype": dbt.type_float()},
    {"name": "billing_address_id", "datatype": dbt.type_string()},
    {"name": "company_name", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "currency_id", "datatype": dbt.type_string()},
    {"name": "display_name", "datatype": dbt.type_string()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "family_name", "datatype": dbt.type_string()},
    {"name": "fax_number", "datatype": dbt.type_string()},
    {"name": "given_name", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "middle_name", "datatype": dbt.type_string()},
    {"name": "mobile_phone", "datatype": dbt.type_string()},
    {"name": "other_contacts", "datatype": dbt.type_string()},
    {"name": "primary_phone", "datatype": dbt.type_string()},
    {"name": "print_on_check_name", "datatype": dbt.type_string()},
    {"name": "suffix", "datatype": dbt.type_string()},
    {"name": "sync_token", "datatype": dbt.type_string()},
    {"name": "tax_identifier", "datatype": dbt.type_string()},
    {"name": "term_id", "datatype": dbt.type_string()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "updated_at", "datatype": dbt.type_timestamp()},
    {"name": "vendor_1099", "datatype": "boolean"},
    {"name": "web_url", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}