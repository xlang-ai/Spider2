--To enable this model, set the using_credit_card_payment_txn variable within your dbt_project.yml file to True.
{{ config(enabled=var('using_credit_card_payment_txn', False)) }}

{{
    fivetran_utils.union_data(
        table_identifier='credit_card_payment_txn', 
        database_variable='quickbooks_database', 
        schema_variable='quickbooks_schema', 
        default_database=target.database,
        default_schema='quickbooks',
        default_variable='credit_card_payment_txn',
        union_schema_variable='quickbooks_union_schemas',
        union_database_variable='quickbooks_union_databases'
    )
}}
