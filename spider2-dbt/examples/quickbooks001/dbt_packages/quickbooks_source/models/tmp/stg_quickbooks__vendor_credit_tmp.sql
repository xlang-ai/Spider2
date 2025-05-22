--To disable this model, set the using_vendor_credit variable within your dbt_project.yml file to False.
{{ config(enabled=var('using_vendor_credit', True)) }}

{{
    fivetran_utils.union_data(
        table_identifier='vendor_credit', 
        database_variable='quickbooks_database', 
        schema_variable='quickbooks_schema', 
        default_database=target.database,
        default_schema='quickbooks',
        default_variable='vendor_credit',
        union_schema_variable='quickbooks_union_schemas',
        union_database_variable='quickbooks_union_databases'
    )
}}
