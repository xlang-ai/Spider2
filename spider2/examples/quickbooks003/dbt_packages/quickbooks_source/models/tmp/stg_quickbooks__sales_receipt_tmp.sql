{{ config(enabled=var('using_sales_receipt', True)) }}

{{
    fivetran_utils.union_data(
        table_identifier='sales_receipt', 
        database_variable='quickbooks_database', 
        schema_variable='quickbooks_schema', 
        default_database=target.database,
        default_schema='quickbooks',
        default_variable='sales_receipt',
        union_schema_variable='quickbooks_union_schemas',
        union_database_variable='quickbooks_union_databases'
    )
}}
