--To disable this model, set the using_refund_receipt variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_refund_receipt', True)) }}

{{
    fivetran_utils.union_data(
        table_identifier='refund_receipt', 
        database_variable='quickbooks_database', 
        schema_variable='quickbooks_schema', 
        default_database=target.database,
        default_schema='quickbooks',
        default_variable='refund_receipt',
        union_schema_variable='quickbooks_union_schemas',
        union_database_variable='quickbooks_union_databases'
    )
}}