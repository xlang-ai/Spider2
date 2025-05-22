--To disable this model, set the using_estimate variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_estimate', True)) }}

{{
    fivetran_utils.union_data(
        table_identifier='estimate_line', 
        database_variable='quickbooks_database', 
        schema_variable='quickbooks_schema', 
        default_database=target.database,
        default_schema='quickbooks',
        default_variable='estimate_line',
        union_schema_variable='quickbooks_union_schemas',
        union_database_variable='quickbooks_union_databases'
    )
}}