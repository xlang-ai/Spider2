{{ config(enabled=var('recharge__one_time_product_enabled', True)) }}
with base as (

    select *
    from {{ ref('stg_recharge__one_time_product_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__one_time_product_tmp')),
                staging_columns = get_one_time_product_columns()
            )
        }}
    from base
),

final as (
    
    select
        id as one_time_product_id,
        address_id,
        customer_id,
        is_deleted,
        cast(created_at as {{ dbt.type_timestamp() }}) as one_time_created_at,
        cast(updated_at as {{ dbt.type_timestamp() }}) as one_time_updated_at,
        next_charge_scheduled_at as one_time_next_charge_scheduled_at,
        product_title,
        variant_title,
        price,
        quantity,
        external_product_id_ecommerce,
        external_variant_id_ecommerce,
        sku
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final