with base as (

    select * 
    from {{ ref('stg_shopify__order_line_tmp') }}

),

fields as (

    select
    
        {{
            fivetran_utils.fill_staging_columns(
                source_columns=adapter.get_columns_in_relation(ref('stg_shopify__order_line_tmp')),
                staging_columns=get_order_line_columns()
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
        id as order_line_id,
        index,
        name,
        order_id,
        fulfillable_quantity,
        fulfillment_status,
        gift_card as is_gift_card,
        grams,
        pre_tax_price,
        pre_tax_price_set,
        price,
        price_set,
        product_id,
        quantity,
        requires_shipping as is_shipping_required,
        sku,
        taxable as is_taxable,
        tax_code,
        title,
        total_discount,
        total_discount_set,
        variant_id,
        variant_title,
        variant_inventory_management,
        vendor,
        properties,
        {{ dbt_date.convert_timezone(column='cast(_fivetran_synced as ' ~ dbt.type_timestamp() ~ ')', target_tz=var('shopify_timezone', "UTC"), source_tz="UTC") }} as _fivetran_synced,
        source_relation

        {{ fivetran_utils.fill_pass_through_columns('order_line_pass_through_columns') }}

    from fields

)

select * 
from final