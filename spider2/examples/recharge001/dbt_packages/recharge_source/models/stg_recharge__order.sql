
with base as (

    select *
    from {{ ref('stg_recharge__order_tmp') }}
),

fields as (

    select
        {{
            fivetran_utils.fill_staging_columns(
                source_columns = adapter.get_columns_in_relation(ref('stg_recharge__order_tmp')),
                staging_columns = get_order_columns()
            )
        }}
    from base
),

final as (

    select
        id as order_id,
        external_order_id_ecommerce,
        external_order_number_ecommerce,
        customer_id,
        email,
        cast(created_at as {{ dbt.type_timestamp() }}) as order_created_at,
        status as order_status,
        cast(updated_at as {{ dbt.type_timestamp() }}) as order_updated_at,
        charge_id,
        transaction_id,
        charge_status,
        is_prepaid,
        cast(total_price as {{ dbt.type_float() }}) as order_total_price,
        type as order_type,
        cast(processed_at as {{ dbt.type_timestamp() }}) as order_processed_at,
        cast(scheduled_at as {{ dbt.type_timestamp() }}) as order_scheduled_at,
        cast(shipped_date as {{ dbt.type_timestamp() }}) as order_shipped_date,
        address_id,
        is_deleted

        {{ fivetran_utils.fill_pass_through_columns('recharge__order_passthrough_columns') }}

    from fields
)

select *
from final