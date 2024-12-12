{% macro get_email_event_sent_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "bcc", "datatype": dbt.type_string()},
    {"name": "cc", "datatype": dbt.type_string()},
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "reply_to", "datatype": dbt.type_string()},
    {"name": "subject", "datatype": dbt.type_string()}
] %}

{% if target.type == 'snowflake' %}
 {{ columns.append({"name": "FROM", "datatype": dbt.type_string(), "quote": True, "alias": "from_email"}) }}
{% else %}
 {{ columns.append({"name": "from", "datatype": dbt.type_string(), "quote": True, "alias": "from_email"}) }}
{% endif %}

{{ return(columns) }}

{% endmacro %}
