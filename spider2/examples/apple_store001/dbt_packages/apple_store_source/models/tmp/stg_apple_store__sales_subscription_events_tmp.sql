{{ config(enabled=var('apple_store__using_subscriptions', False)) }}
{{
    fivetran_utils.union_data(
        table_identifier='sales_subscription_event_summary', 
        database_variable='apple_store_database', 
        schema_variable='apple_store_schema', 
        default_database=target.database,
        default_schema='apple_store',
        default_variable='sales_subscription_events',
        union_schema_variable='apple_store_union_schemas',
        union_database_variable='apple_store_union_databases'
    )
}}