{{ config(enabled=var('shopify_using_fulfillment_event', false)) }}

{{
    fivetran_utils.union_data(
        table_identifier='fulfillment_event', 
        database_variable='shopify_database', 
        schema_variable='shopify_schema', 
        default_database=target.database,
        default_schema='shopify',
        default_variable='fulfillment_event_source',
        union_schema_variable='shopify_union_schemas',
        union_database_variable='shopify_union_databases'
    )
}}