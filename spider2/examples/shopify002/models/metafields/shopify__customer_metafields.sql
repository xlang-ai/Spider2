{{ config(enabled=var('shopify_using_all_metafields', False) or var('shopify_using_customer_metafields', False)) }}

{{ get_metafields( 
    source_object = "stg_shopify__customer", 
    reference_value = 'customer') 
}}