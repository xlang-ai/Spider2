with products as (

    select *
    from {{ var('shopify_product') }}
), 

collection_product as (

    select *
    from {{ var('shopify_collection_product') }}
),

collection as (

    select *
    from {{ var('shopify_collection') }}
    where not coalesce(is_deleted, false) -- limit to only active collections
),

product_tag as (

    select *
    from {{ var('shopify_product_tag') }}
),

product_variant as (

    select *
    from {{ var('shopify_product_variant') }}
),

product_image as (

    select *
    from {{ var('shopify_product_image') }}
),


collections_aggregated as (

    select
        collection_product.product_id,
        collection_product.source_relation,
        {{ fivetran_utils.string_agg(field_to_agg='collection.title', delimiter="', '") }} as collections
    from collection_product 
    join collection 
        on collection_product.collection_id = collection.collection_id
        and collection_product.source_relation = collection.source_relation
    group by 1,2
),

tags_aggregated as (

    select 
        product_id,
        source_relation,
        {{ fivetran_utils.string_agg(field_to_agg='value', delimiter="', '") }} as tags
    
    from product_tag
    group by 1,2
),

variants_aggregated as (

    select 
        product_id,
        source_relation,
        count(variant_id) as count_variants

    from product_variant
    group by 1,2

),

images_aggregated as (

    select 
        product_id,
        source_relation,
        count(*) as count_images
    from product_image
    group by 1,2
),

joined as (

    select
        products.*,
        collections_aggregated.collections,
        tags_aggregated.tags,
        variants_aggregated.count_variants,
        coalesce(images_aggregated.count_images, 0) > 0 as has_product_image

    from products
    left join collections_aggregated
        on products.product_id = collections_aggregated.product_id
        and products.source_relation = collections_aggregated.source_relation
    left join tags_aggregated
        on products.product_id = tags_aggregated.product_id
        and products.source_relation = tags_aggregated.source_relation
    left join variants_aggregated
        on products.product_id = variants_aggregated.product_id
        and products.source_relation = variants_aggregated.source_relation
    left join images_aggregated
        on products.product_id = images_aggregated.product_id
        and products.source_relation = images_aggregated.source_relation
)

select *
from joined