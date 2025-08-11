{% macro get_contact_history_columns() %}

{% set columns = [
    {"name": "_fivetran_active", "datatype": "boolean"},
    {"name": "_fivetran_start", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_end", "datatype": dbt.type_timestamp()},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "admin_id", "datatype": dbt.type_int()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "email", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "last_contacted_at", "datatype": dbt.type_timestamp()},
    {"name": "last_email_clicked_at", "datatype": dbt.type_timestamp()},
    {"name": "last_email_opened_at", "datatype": dbt.type_timestamp()},
    {"name": "last_replied_at", "datatype": dbt.type_timestamp()},
    {"name": "name", "datatype": dbt.type_string()},
    {"name": "role", "datatype": dbt.type_string()},
    {"name": "signed_up_at", "datatype": dbt.type_timestamp()},
    {"name": "unsubscribed_from_emails", "datatype": "boolean"},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}
] %}

{{ fivetran_utils.add_pass_through_columns(columns, var('intercom__contact_history_pass_through_columns')) }}

{{ return(columns) }}

{% endmacro %}
