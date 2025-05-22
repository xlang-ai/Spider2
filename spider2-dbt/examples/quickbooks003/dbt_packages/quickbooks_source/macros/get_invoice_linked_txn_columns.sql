{% macro get_invoice_linked_txn_columns() %}

{% set columns = [
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "charge_credit_id", "datatype": dbt.type_string()},
    {"name": "estimate_id", "datatype": dbt.type_string()},
    {"name": "index", "datatype": dbt.type_string()},
    {"name": "invoice_id", "datatype": dbt.type_string()},
    {"name": "payment_id", "datatype": dbt.type_string()},
    {"name": "reimburse_charge_id", "datatype": dbt.type_string()},
    {"name": "statement_charge_id", "datatype": dbt.type_string()},
    {"name": "time_activity_id", "datatype": dbt.type_string()}
] %}

{{ return(columns) }}

{% endmacro %}
