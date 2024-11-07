--To disable this model, set the using_department variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_department', True)) }}

{{
    fivetran_utils.union_data(
        table_identifier='department', 
        database_variable='quickbooks_database', 
        schema_variable='quickbooks_schema', 
        default_database=target.database,
        default_schema='quickbooks',
        default_variable='department',
        union_schema_variable='quickbooks_union_schemas',
        union_database_variable='quickbooks_union_databases'
    )
}}