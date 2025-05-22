-- this model will be all NULL until you create a discount code in Shopify

{{
    fivetran_utils.union_data(
        table_identifier='discount_code', 
        database_variable='shopify_database', 
        schema_variable='shopify_schema', 
        default_database=target.database,
        default_schema='shopify',
        default_variable='discount_code_source',
        union_schema_variable='shopify_union_schemas',
        union_database_variable='shopify_union_databases'
    )
}}