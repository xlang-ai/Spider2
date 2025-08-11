
with base as (

    select *
    from {{ ref('stg_recharge__charge_order_attribute_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__charge_order_attribute_tmp')),
                staging_columns = get_charge_order_attribute_columns()
            )
        }}
    from base
),

final as (

    select
        charge_id,
        index,
        order_attribute
    from fields
)

select *
from final