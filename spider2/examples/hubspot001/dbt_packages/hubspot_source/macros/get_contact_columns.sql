{% macro get_contact_columns() %}

{% set columns = [
    {"name": "_fivetran_deleted", "datatype": "boolean", "alias": "is_contact_deleted"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "id", "datatype": dbt.type_int(), "alias": "contact_id"},
    {"name": "property_hs_calculated_merged_vids", "datatype": dbt.type_string(), "alias": "calculated_merged_vids"},
    {"name": "property_email", "datatype": dbt.type_string(), "alias": "email"},
    {"name": "property_company", "datatype": dbt.type_string(), "alias": "contact_company"},
    {"name": "property_firstname", "datatype": dbt.type_string(), "alias": "first_name"},
    {"name": "property_lastname", "datatype": dbt.type_string(), "alias": "last_name"},
    {"name": "property_createdate", "datatype": dbt.type_timestamp(), "alias": "created_date"},
    {"name": "property_jobtitle", "datatype": dbt.type_string(), "alias": "job_title"},
    {"name": "property_annualrevenue", "datatype": dbt.type_int(), "alias": "company_annual_revenue"}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('hubspot__contact_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
