{% macro get_organization_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "apikey", "datatype": dbt.type_string()},
    {"name": "base_currency", "datatype": dbt.type_string()},
    {"name": "class", "datatype": dbt.type_string()},
    {"name": "country_code", "datatype": dbt.type_string()},
    {"name": "created_date_utc", "datatype": dbt.type_timestamp()},
    {"name": "default_purchases_tax", "datatype": dbt.type_string()},
    {"name": "default_sales_tax", "datatype": dbt.type_string()},
    {"name": "edition", "datatype": dbt.type_string()},
    {"name": "employer_identification_number", "datatype": dbt.type_string()},
    {"name": "end_of_year_lock_date", "datatype": "date"},
    {"name": "financial_year_end_day", "datatype": dbt.type_int()},
    {"name": "financial_year_end_month", "datatype": dbt.type_int()},
    {"name": "is_demo_company", "datatype": "boolean"},
    {"name": "legal_name", "datatype": dbt.type_string()},
    {"name": "line_of_business", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "organisation_entity_type", "datatype": dbt.type_string()},
    {"name": "organisation_id", "datatype": dbt.type_string()},
    {"name": "organisation_status", "datatype": dbt.type_string()},
    {"name": "organisation_type", "datatype": dbt.type_string()},
    {"name": "pays_tax", "datatype": "boolean"},
    {"name": "period_lock_date", "datatype": "date"},
    {"name": "registration_number", "datatype": dbt.type_string()},
    {"name": "sales_tax_basis", "datatype": dbt.type_string()},
    {"name": "sales_tax_period", "datatype": dbt.type_string()},
    {"name": "short_code", "datatype": dbt.type_string()},
    {"name": "tax_number", "datatype": dbt.type_string()},
    {"name": "tax_number_name", "datatype": dbt.type_string()},
    {"name": "timezone", "datatype": dbt.type_string()},
    {"name": "version", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
