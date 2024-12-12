{% macro get_company_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int(), "alias": "company_id"},
    {"name": "is_deleted", "datatype": "boolean", "alias": "is_company_deleted"},
    {"name": "property_name", "datatype": dbt.type_string(), "alias": "company_name"},
    {"name": "property_description", "datatype": dbt.type_string(), "alias": "description"},
    {"name": "property_createdate", "datatype": dbt.type_timestamp(), "alias": "created_date"},
    {"name": "property_industry", "datatype": dbt.type_string(), "alias": "industry"},
    {"name": "property_address", "datatype": dbt.type_string(), "alias": "street_address"},
    {"name": "property_address_2", "datatype": dbt.type_string(), "alias": "street_address_2"},
    {"name": "property_city", "datatype": dbt.type_string(), "alias": "city"},
    {"name": "property_state", "datatype": dbt.type_string(), "alias": "state"},
    {"name": "property_country", "datatype": dbt.type_string(), "alias": "country"},
    {"name": "property_annualrevenue", "datatype": dbt.type_int(), "alias": "company_annual_revenue"}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('hubspot__company_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}