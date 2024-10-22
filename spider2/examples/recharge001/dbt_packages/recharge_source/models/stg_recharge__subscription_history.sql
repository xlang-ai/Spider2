
with base as (

    select *
    from {{ ref('stg_recharge__subscription_history_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__subscription_history_tmp')),
                staging_columns = get_subscription_history_columns()
            )
        }}
    from base
),

final as (

    select
        coalesce(cast(id as {{ dbt.type_int() }}), cast(subscription_id as {{ dbt.type_int() }})) as subscription_id,
        customer_id,
        address_id,
        cast(created_at as {{ dbt.type_timestamp() }}) as subscription_created_at,
        external_product_id_ecommerce,
        external_variant_id_ecommerce,
        product_title,
        variant_title,
        sku,
        cast(price as {{ dbt.type_float() }}) as price,
        quantity,
        status as subscription_status,
        charge_interval_frequency,
        order_interval_unit,
        order_interval_frequency,
        order_day_of_month,
        order_day_of_week,
        expire_after_specific_number_of_charges,
        cast(updated_at as {{ dbt.type_timestamp() }}) as subscription_updated_at,
        cast(next_charge_scheduled_at as {{ dbt.type_timestamp() }}) as subscription_next_charge_scheduled_at,
        cast(cancelled_at as {{ dbt.type_timestamp() }}) as subscription_cancelled_at,
        cancellation_reason,
        cancellation_reason_comments,
        _fivetran_synced

        {{ fivetran_utils.fill_pass_through_columns('recharge__subscription_history_passthrough_columns') }}

    from fields
)

select
    *,
    row_number() over (partition by subscription_id order by subscription_updated_at desc) = 1 as is_most_recent_record
from final