{% macro get_contact_mailing_list_membership_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "contact_id", "datatype": dbt.type_string()},
    {"name": "contact_lookup_id", "datatype": dbt.type_string()},
    {"name": "directory_id", "datatype": dbt.type_string()},
    {"name": "mailing_list_id", "datatype": dbt.type_string()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "owner_id", "datatype": dbt.type_string()},
    {"name": "unsubscribe_date", "datatype": dbt.type_timestamp()},
    {"name": "unsubscribed", "datatype": "boolean"}
] %}

{{ return(columns) }}

{% endmacro %}
