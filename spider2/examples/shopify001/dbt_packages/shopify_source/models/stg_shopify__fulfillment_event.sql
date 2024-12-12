{{ config(enabled=var('shopify_using_fulfillment_event', false)) }}

with base as (

    select * 
    from {{ ref('stg_shopify__fulfillment_event_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__fulfillment_event_tmp')),
                staging_columns=get_fulfillment_event_columns()
            )
        }}
        
        {{ fivetran_utils.source_relation(
            union_schema_variable='shopify_union_schemas', 
            union_database_variable='shopify_union_databases') 
        }}

    from base
),

final as (
    
    select 
        id as fulfillment_event_id,
        fulfillment_id,
        shop_id,
        order_id,
        status,
        message,
        {{ dbt_date.convert_timezone(column='cast(estimated_delivery_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as estimated_delivery_at,
        {{ dbt_date.convert_timezone(column='cast(happened_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as happened_at,
        address_1,
        city,
        province,
        country,
        zip,
        latitude,
        longitude,
        {{ dbt_date.convert_timezone(column='cast(created_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as created_at,
        {{ dbt_date.convert_timezone(column='cast(updated_at as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as updated_at,
        {{ dbt_date.convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation

    from fields

    where not coalesce(_fivetran_deleted, false)
)

select *
from final
