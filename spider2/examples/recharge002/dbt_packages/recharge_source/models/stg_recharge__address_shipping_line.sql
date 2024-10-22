
with base as (

    select *
    from {{ ref('stg_recharge__address_shipping_line_tmp') }}
),

fields as (
    
    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__address_shipping_line_tmp')),
                staging_columns = get_address_shipping_line_columns()
            )
        }}
    from base
),

final as (

    select
        address_id,
        index,
        price,
        code,
        title
    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final