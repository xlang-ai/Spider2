{{ config(enabled=var('recharge__checkout_enabled', false)) }}

with base as (

    select *
    from {{ ref('stg_recharge__checkout_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__checkout_tmp')),
                staging_columns = get_checkout_columns()
            )
        }}
    from base
),

final as (

    select
        token as checkout_id,
        charge_id,
        buyer_accepts_marketing,
        cast(completed_at as {{ dbt.type_timestamp() }}) as checkout_completed_at,
        cast(created_at as {{ dbt.type_timestamp() }}) as checkout_created_at,
        currency,
        discount_code,
        email,
        external_checkout_id,
        external_checkout_source,
        external_transaction_id_payment_processor,
        order_attributes,
        phone,
        requires_shipping,
        subtotal_price,
        taxes_included,
        total_price,
        total_tax,
        cast(updated_at as {{ dbt.type_timestamp() }}) as checkout_updated_at

    {{ fivetran_utils.fill_pass_through_columns('recharge__checkout_passthrough_columns') }}

    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final