
with base as (

    select *
    from {{ ref('stg_recharge__charge_line_item_tmp') }}
),

fields as (
    
    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__charge_line_item_tmp')),
                staging_columns = get_charge_line_item_columns()
            )
        }}
    from base
),

final as (
    
    select
        charge_id,
        index,
        vendor,
        title,
        variant_title,
        sku,
        grams,
        quantity,
        cast(total_price as {{ dbt.type_float() }}) as total_price,
        unit_price,
        tax_due,
        taxable,
        taxable_amount,
        unit_price_includes_tax,
        external_product_id_ecommerce,
        external_variant_id_ecommerce,
        purchase_item_id,
        purchase_item_type

        {{ fivetran_utils.fill_pass_through_columns('recharge__charge_line_item_passthrough_columns') }}

    from fields
)

select *
from final