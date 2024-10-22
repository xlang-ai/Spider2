
with base as (

    select *
    from {{ ref('stg_recharge__subscription_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__subscription_tmp')),
                staging_columns = get_subscription_columns()
            )
        }}
    from base
),

final as (

    select
        id as subscription_id,
        customer_id,
        address_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as subscription_created_at,
        product_title,
        variant_title,
        sku,
        cast(price as {{ dbt.type_float() }}) as price,
        quantity,
        status as subscription_status,
        next_charge_scheduled_at as subscription_next_charge_scheduled_at,
        charge_interval_frequency,
        expire_after_specific_number_of_charges,
        order_interval_frequency,
        order_interval_unit,
        order_day_of_week,
        order_day_of_month,
        cast(updated_at as {{ dbt.type_timestamp() }}) as subscription_updated_at,
        external_product_id_ecommerce,
        external_variant_id_ecommerce,
        cast(cancelled_at as {{ dbt.type_timestamp() }}) as subscription_cancelled_at,
        cancellation_reason,
        cancellation_reason_comments

        {{ fivetran_utils.fill_pass_through_columns('recharge__subscription_passthrough_columns') }}

    from fields
    where not coalesce(_fivetran_deleted, false)
)

select *
from final