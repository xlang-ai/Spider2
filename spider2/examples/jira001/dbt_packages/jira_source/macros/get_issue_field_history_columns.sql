{% macro get_issue_field_history_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "field_id", "datatype": dbt.type_string()},
    {"name": "issue_id", "datatype": dbt.type_int()},
    {"name": "value", "datatype": dbt.type_string()}
] %}

{% if target.type == 'redshift' %}
 {{ columns.append( {"name": "time", "datatype": dbt.type_timestamp(), "quote": True } ) }}
{% elif target.type == 'snowflake' %}
 {{ columns.append( {"name": "TIME", "datatype": dbt.type_timestamp(), "quote": True } ) }}
{% else %}
 {{ columns.append( {"name": "time", "datatype": dbt.type_timestamp()} ) }}
{% endif %}


{{ return(columns) }}

{% endmacro %}