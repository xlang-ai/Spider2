{% macro get_lead_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_active", "datatype": dbt.type_boolean()},
    {"name": "annual_revenue", "datatype": dbt.type_float()},
    {"name": "city", "datatype": dbt.type_string()},
    {"name": "company", "datatype": dbt.type_string()},
    {"name": "converted_account_id", "datatype": dbt.type_string()},
    {"name": "converted_contact_id", "datatype": dbt.type_string()},
    {"name": "converted_date", "datatype": dbt.type_timestamp()},
    {"name": "converted_opportunity_id", "datatype": dbt.type_string()},
    {"name": "country", "datatype": dbt.type_string()},
    {"name": "country_code", "datatype": dbt.type_string()},
    {"name": "created_by_id", "datatype": dbt.type_string()},
    {"name": "created_date", "datatype": dbt.type_timestamp()},
    {"name": "description", "datatype": dbt.type_string()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "email_bounced_date", "datatype": dbt.type_timestamp()},
    {"name": "email_bounced_reason", "datatype": dbt.type_string()},
    {"name": "first_name", "datatype": dbt.type_string()},
    {"name": "has_opted_out_of_email", "datatype": "boolean"},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "individual_id", "datatype": dbt.type_string()},
    {"name": "industry", "datatype": dbt.type_string()},
    {"name": "is_converted", "datatype": "boolean"},
    {"name": "is_deleted", "datatype": "boolean"},
    {"name": "is_unread_by_owner", "datatype": "boolean"},
    {"name": "last_activity_date", "datatype": dbt.type_timestamp()},
    {"name": "last_modified_by_id", "datatype": dbt.type_string()},
    {"name": "last_modified_date", "datatype": dbt.type_timestamp()},
    {"name": "last_name", "datatype": dbt.type_string()},
    {"name": "last_referenced_date", "datatype": dbt.type_timestamp()},
    {"name": "last_viewed_date", "datatype": dbt.type_timestamp()},
    {"name": "lead_source", "datatype": dbt.type_string()},
    {"name": "master_record_id", "datatype": dbt.type_string()},
    {"name": "mobile_phone", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "number_of_employees", "datatype": dbt.type_int()},
    {"name": "owner_id", "datatype": dbt.type_string()},
    {"name": "phone", "datatype": dbt.type_string()},
    {"name": "postal_code", "datatype": dbt.type_string()},
    {"name": "state", "datatype": dbt.type_string()},
    {"name": "state_code", "datatype": dbt.type_string()},
    {"name": "status", "datatype": dbt.type_string()},
    {"name": "street", "datatype": dbt.type_string()},
    {"name": "title", "datatype": dbt.type_string()},
    {"name": "website", "datatype": dbt.type_string()},
] %}

{{ salesforce_source.add_renamed_columns(columns) }}

{{ fivetran_utils.add_pass_through_columns(columns, var('salesforce__lead_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
