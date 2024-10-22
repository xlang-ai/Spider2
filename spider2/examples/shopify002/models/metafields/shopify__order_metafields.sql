{{ config(enabled=var('shopify_using_all_metafields', False) or var('shopify_using_order_metafields', False)) }}

{{ get_metafields( 
    source_object = "stg_shopify__order", 
    reference_value = 'order') 
}}