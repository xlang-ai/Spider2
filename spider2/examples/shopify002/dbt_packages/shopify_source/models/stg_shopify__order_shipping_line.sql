
with base as (

    select * 
    from {{ ref('stg_shopify__order_shipping_line_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__order_shipping_line_tmp')),
                staging_columns=get_order_shipping_line_columns()
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
        id as order_shipping_line_id,
        order_id,
        carrier_identifier,
        code,
        delivery_category,
        discounted_price,
        discounted_price_set,
        phone,
        price,
        price_set,
        requested_fulfillment_service_id is not null as is_third_party_required,
        source,
        title,
        {{ dbt_date.convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation
        
    from fields
)

select *
from final
