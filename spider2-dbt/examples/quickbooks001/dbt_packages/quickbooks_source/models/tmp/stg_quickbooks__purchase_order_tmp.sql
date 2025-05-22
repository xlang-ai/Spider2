--To enable this model, set the using_invoice variable within your dbt_project.yml file to True.
{{ config(enabled=var('using_purchase_order', False)) }}

{{
    fivetran_utils.union_data(
        table_identifier='purchase_order', 
        database_variable='quickbooks_database', 
        schema_variable='quickbooks_schema', 
        default_database=target.database,
        default_schema='quickbooks',
        default_variable='purchase_order',
        union_schema_variable='quickbooks_union_schemas',
        union_database_variable='quickbooks_union_databases'
    )
}}
