{% macro get_credit_card_payment_txn_columns() %}

{% set columns = [    	
    {"name": "id", "datatype": dbt.type_string()},
    {"name": "_fivetran_deleted", "datatype": "boolean"},
    {"name": "_fivetran_synced", "datatype": dbt.type_timestamp()},
    {"name": "amount", "datatype": dbt.type_float()},
    {"name": "bank_account_id", "datatype": dbt.type_string()},
    {"name": "created_at", "datatype": dbt.type_timestamp()},
    {"name": "credit_card_account_id", "datatype": dbt.type_string()},
    {"name": "currency_id", "datatype": dbt.type_string()},
    {"name": "sync_token", "datatype": dbt.type_string()},
    {"name": "transaction_date", "datatype": "date"},
    {"name": "updated_at", "datatype": dbt.type_timestamp()}

] %}

{{ return(columns) }}

{% endmacro %}