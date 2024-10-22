{{ config(enabled=var('shopify_using_all_metafields', False) or var('shopify_using_product_metafields', False)) }}

{{ get_metafields( 
    source_object = "stg_shopify__product", 
    reference_value = 'product') 
}}