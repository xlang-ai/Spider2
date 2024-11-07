--To disable this model, set the using_address variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_address', True)) }}

{{
    fivetran_utils.union_data(
        table_identifier='address', 
        database_variable='quickbooks_database', 
        schema_variable='quickbooks_schema', 
        default_database=target.database,
        default_schema='quickbooks',
        default_variable='address',
        union_schema_variable='quickbooks_union_schemas',
        union_database_variable='quickbooks_union_databases'
    )
}}