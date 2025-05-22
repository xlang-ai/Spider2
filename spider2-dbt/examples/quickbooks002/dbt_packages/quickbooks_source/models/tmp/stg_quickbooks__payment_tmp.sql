--To enable this model, set the using_payment variable within your dbt_project.yml file to True.
{{ config(enabled=var('using_payment', True)) }}

{{
    fivetran_utils.union_data(
        table_identifier='payment', 
        database_variable='quickbooks_database', 
        schema_variable='quickbooks_schema', 
        default_database=target.database,
        default_schema='quickbooks',
        default_variable='payment',
        union_schema_variable='quickbooks_union_schemas',
        union_database_variable='quickbooks_union_databases'
    )
}}