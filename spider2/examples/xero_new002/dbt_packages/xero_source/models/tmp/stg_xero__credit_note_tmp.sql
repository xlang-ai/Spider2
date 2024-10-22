{{ config(enabled=var('xero__using_credit_note', True)) }}

{{
    fivetran_utils.union_data(
        table_identifier='credit_note', 
        database_variable='xero_database', 
        schema_variable='xero_schema', 
        default_database=target.database,
        default_schema='xero',
        default_variable='credit_note'
    )
}} 