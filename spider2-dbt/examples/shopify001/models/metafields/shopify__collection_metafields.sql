{{ config(enabled=var('shopify_using_all_metafields', False) or var('shopify_using_collection_metafields', False)) }}

{{ get_metafields( 
    source_object = "stg_shopify__collection", 
    reference_value = 'collection') 
}}